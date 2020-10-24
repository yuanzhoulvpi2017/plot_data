library(sf)
library(tidyverse)

# load shp file
country_shp <- sf::st_read("/Users/huzheng/Downloads/shp/全国数据.shp")
province_shp <- sf::st_read("/Users/huzheng/Downloads/shp/省级数据-带标签.shp")


library(ncdf4)
ncvariable <- nc_open("/Users/huzheng/Downloads/model.nc")
lon <- ncvar_get(ncvariable, "lon")
lat <- ncvar_get(ncvariable, "lat")
time <- ncvar_get(ncvariable, "time")
tas <- ncvar_get(ncvariable, "tas")


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 判断每一点的位置在不在中国，在不在中国的某个省

all_lon_lat <- expand.grid("lon" = lon, "lat" = lat)
lon_lat_with_locaion <- data.frame(matrix(ncol = length(province_shp$ENAME)+1))
colnames(lon_lat_with_locaion) <- c(province_shp$SNAME, "china_boundary")
lon_lat_with_locaion <- all_lon_lat %>% bind_cols(lon_lat_with_locaion)

lon_lat_to_st_point <- st_sfc(lapply(1:nrow(all_lon_lat), 
                                     FUN = function(i){return(st_point(c(all_lon_lat$lon[i], all_lon_lat$lat[i])))}), 
                              crs = 4326)


for (temp_province in c(province_shp$SNAME, "china_boundary")) {
  if (temp_province == "china_boundary") {
    temp_geometry <- country_shp$geometry[1]
  } else {
    temp_geometry <- province_shp %>% filter(SNAME == temp_province) %>% pull(geometry) 
  }
  
  temp_result <- st_intersects(lon_lat_to_st_point, st_transform(temp_geometry, crs = 4326), sparse=FALSE)
  lon_lat_with_locaion[, temp_province] <- temp_result[, 1]

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 将每一层的数据都保存起来，然后合并
all_tas_matrix <- matrix(nrow = (dim(tas)[1]) * (dim(tas)[2]), ncol = (dim(tas)[3]))
for (temp_layer in c(1:(dim(tas)[3]))) {
  all_tas_matrix[, temp_layer] <- c(tas[, , temp_layer])
  
}

colnames(all_tas_matrix) <- paste0("layer_",c(1:(dim(tas)[3])))

all_tas_matrix <- as.data.frame.matrix(all_tas_matrix)

# 这里包含每一个点的对应层的数据对应是否在中国的数据，以及对应的坐标，是否在国内等
final_data <- all_tas_matrix %>% bind_cols(lon_lat_with_locaion)



write_csv(final_data, path = "final.csv")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 画图


final_data %>% filter(china_boundary == TRUE) %>% 
  select(-c(contains("layer"), "lon", "lat", "china_boundary")) %>% 
  mutate(id = row_number()) %>% 
  pivot_longer(cols = -id, names_to = "province", values_to = "contain") %>% 
  filter(contain == TRUE) %>% 
  group_by(province) %>% summarise(n = n()) %>% 
  ungroup() %>% 
  mutate(province = reorder(province, n)) %>% 
  ggplot(aes(province, n)) + geom_col(aes(fill = n))+
  geom_label(aes(label = n), color = 'red') +
  theme_bw() + 
  theme(text=element_text(family="STKaiti",size=14)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 你想要的数据
clean_data <- final_data %>% filter(china_boundary == TRUE) %>% 
  select(-c("lon", "lat", "china_boundary")) %>% 
  pivot_longer(cols = -c(contains("layer")), names_to = "province", values_to = "contain") %>% 
  filter(contain == TRUE) %>% select(-contain) %>% 
  pivot_longer(cols = -province)


summarize_data <- clean_data %>% group_by(name, province) %>% summarise(sum = sum(value), n = n(), mean = mean(value))

summarize_data %>% ggplot(aes(x = province, y = sum)) + 
  geom_col(aes(fill = sum)) + 
  facet_wrap(~ name) +
  theme(text=element_text(family="STKaiti",size=3)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

