library(tidyverse)

gdp_data <- readxl::read_xls("gdp.xls", skip = 3) #gdp
gdp_data <- gdp_data[1:31, ]

clearn_data <- gdp_data %>% reshape2::melt(id.vars = '地区') %>% 
  mutate(variable = as.numeric(str_remove(variable, "年"))) 

colnames(clearn_data) <- c("region", "year", "gdp")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clearn_data %>% ggplot(aes(x = year, y = gdp,color = region)) + 
  geom_point(show.legend = FALSE) + 
  geom_path(show.legend = FALSE) +
  geom_text(data = clearn_data %>% filter(year == 2018),
            aes(x = year, y = gdp, label = region), 
            show.legend = FALSE, 
            color = 'red', hjust = 0, angle = 45,
            size = 3) +
  theme_bw() + scale_x_continuous(expand = c(0, 1.5))
ggsave("gzh001.png")  

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clearn_data %>% ggplot(aes(x = year, y = gdp,color = region)) + 
  geom_point(show.legend = FALSE) + 
  geom_path(show.legend = FALSE) + facet_grid(~ region) + 
  theme(axis.text.x = element_blank())
ggsave("gzh002.png")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(gganimate)


anim <- clearn_data %>% 
  mutate(x_id = as.numeric(factor(region, levels = unique(clearn_data$region)))) %>% 
  ggplot(aes(x = x_id, y = gdp)) + geom_col(aes(fill = x_id), show.legend = FALSE) + 
  theme_bw() + scale_x_continuous(breaks = 1:31, 
                                  labels = as.factor(unique(clearn_data$region))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  transition_time(year) + 
  labs(title = "year {round(frame_time)}",  caption = '公众号: pypi',
       x = "data from http://www.stats.gov.cn/") +
  view_follow(fixed_x = TRUE)

anim_gif <- animate(anim, width = 600, height = 600)
anim_save(filename = 'test.gif', animation = anim_gif)
# 
# anim_av <- animate(anim, renderer = ffmpeg_renderer(), 
#                 width = 600, height = 600)
# anim_save(filename = "test.mp4", animation = anim_av) 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fdi_data <- readxl::read_xls("fdi.xls", skip = 3) #fdi
fdi_data <- fdi_data[1:31, ]

clearn_gdp <- gdp_data %>% reshape2::melt(id.vars = '地区') %>% 
  mutate(variable = as.numeric(str_remove(variable, "年"))) 
colnames(clearn_gdp) <- c("region", "year", "gdp")

clearn_fdi <- fdi_data %>% reshape2::melt(id.vars = '地区') %>% 
  mutate(variable = as.numeric(str_remove(variable, "年"))) 
colnames(clearn_fdi) <- c("region", "year", "fdi")

fdi_gdp_data <- left_join(clearn_gdp, clearn_fdi,
                       by.x = c("region", "year"),
                       by.y = c("region", "year"))

anim2 <- fdi_gdp_data %>% 
  ggplot(aes(x = gdp, y = fdi, color = region)) + 
  geom_point(show.legend = FALSE) + 
  geom_text(aes(label = region), show.legend = FALSE) + theme_bw() + 
  transition_time(year) + 
  labs(title = "year {round(frame_time)}",
       caption = 'data from http://www.stats.gov.cn/ \n 公众号: pypi') +
  view_follow(fixed_x = TRUE, fixed_y = TRUE)

anim2_gif <- animate(anim2, width = 600, height = 600)
anim_save(filename = 'test2.gif', animation = anim2_gif)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfcz_data <- readxl::read_xls("地方财政.xls", skip = 3) #地方财政
dfcz_data <- dfcz_data[1:31, ]

clearn_dfcz <- dfcz_data %>% reshape2::melt(id.vars = '地区') %>% 
  mutate(variable = as.numeric(str_remove(variable, "年"))) 
colnames(clearn_dfcz) <- c("region", "year", "dfcz")

dfcz_gdp_data <- left_join(clearn_gdp, clearn_dfcz,
                          by.x = c("region", "year"),
                          by.y = c("region", "year"))

anim3 <- dfcz_gdp_data %>% 
  ggplot(aes(x = gdp, y = dfcz, color = region)) + 
  geom_point(show.legend = FALSE) + 
  geom_text(aes(label = region), show.legend = FALSE) + theme_bw() + 
  transition_time(year) + 
  labs(title = "year {round(frame_time)}",
       caption = 'data from http://www.stats.gov.cn/ \n 公众号: pypi') +
  view_follow(fixed_x = TRUE, fixed_y = TRUE)

anim3_gif <- animate(anim3, width = 600, height = 600)
anim_save(filename = 'test3.gif', animation = anim3_gif)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
people_data <- readxl::read_xls("人口.xls", skip = 3) #人口这里指的是年末人口
people_data <- people_data[1:31, ]

clearn_people <- people_data %>% reshape2::melt(id.vars = '地区') %>% 
  mutate(variable = as.numeric(str_remove(variable, "年"))) 
colnames(clearn_people) <- c("region", "year", "people")

people_gdp_data <- left_join(clearn_gdp, clearn_people,
                           by.x = c("region", "year"),
                           by.y = c("region", "year"))

anim4 <- people_gdp_data %>% 
  ggplot(aes(x = gdp, y = people, color = region)) + 
  geom_point(show.legend = FALSE) + 
  geom_text(aes(label = region), show.legend = FALSE) + theme_bw() + 
  transition_time(year) + 
  labs(title = "year {round(frame_time)}",
       caption = 'data from http://www.stats.gov.cn/ \n 公众号: pypi') +
  view_follow(fixed_x = TRUE, fixed_y = TRUE)

anim4_gif <- animate(anim4, width = 600, height = 600)
anim_save(filename = 'test4.gif', animation = anim4_gif)
