# https://github.com/jpawlata/TidyTuesday/blob/master/2020/2020-02-18/food_consumption_CO2_emission.R
library(tidyverse)
require(maps)
library(wesanderson)
names(wes_palettes)


# Get the Data
food_consumption <- readr::read_csv('food_consumption.csv')
#Countries' centroids:
#https://developers.google.com/public-data/docs/canonical/countries_csv 
countries_centroids <- read.csv('countries_centroids.txt', sep = '\t', stringsAsFactors = FALSE)
meat <- c('Pork', 'Poultry', 'Beef', 'Lamb & Goat')

centroids <- countries_centroids %>%
  rename(region = name, long_cen = longitude, lat_cen = latitude) %>%
  select(-c(country)) %>%
  arrange(region)

df <- food_consumption %>%
  drop_na() %>%
  group_by(country) %>%
  arrange(country) %>%
  filter(food_category %in% meat)

df_aggr <- aggregate(list(consumption = df$consumption, co2_emmission = df$co2_emmission), by = list(region = df$country) , FUN = sum)

world_map <- map_data("world")

meat_consumption_by_region <- left_join(world_map, df_aggr, by = "region")

centroids$region_new <- recode(centroids$region, `Congo [DRC]` = "Congo", 
                               `Hong Kong` = "Hong Kong SAR. China",
                               `Macedonia [FYROM]` = "Macedonia", 
                               `Myanmar [Burma]` = "Myanmar",
                               `Taiwan` = "Taiwan. ROC",
                               `United States` =  "USA")

centroids <- centroids %>% select(-c(region)) %>%
  rename(region = region_new) %>%
  left_join(df_aggr, by = "region") %>% drop_na()

centroids_top10 <- centroids 
centroids_top10 <- drop_na(centroids_top10) %>%
  arrange(desc(consumption)) %>%
  top_n(10)




# Plot

caption_text = expression(paste("Data source: ", bold("nu3"), " & ", bold("Kasia Kulma"), " | Graphic: ", bold("Justyna Pawlata")))

# Fonts
font_family = 'Verdana'

# Colors:
text_color = '#595959'
palette <- wes_palette("Zissou1", 100, type = "continuous")
str(centroids_top10)
centroids_top10$long_cen <- as.numeric(centroids_top10$long_cen)
ggplot() + 
  geom_polygon(data = meat_consumption_by_region, aes(x = long, y = lat, group = group)) +
  geom_polygon(data = meat_consumption_by_region, aes(x = long, y = lat, 
                                                      group = group, fill = consumption), colour = "white") + 
  scale_fill_gradientn(colours = palette) + 
  geom_text(data = centroids_top10, x = centroids_top10$long_cen, y = centroids_top10$lat_cen, 
            label = centroids_top10$co2_emmission, vjust = 2, size = 3, fontface = "italic", color = text_color, family = "Verdana") + 
  geom_text(data = centroids_top10, x = centroids_top10$long_cen, y = centroids_top10$lat_cen, 
            label = centroids_top10$region, size = 4, fontface = 4, color = text_color, family = "Verdana") +
  theme_void() + 
  theme(
    legend.position="bottom",
    legend.key.width = unit(1, "cm"),
    plot.title = element_text(hjust = 0.5, face = 'bold', size = 20, family = font_family, color = text_color, margin=margin(10,0,0,0)),
    plot.subtitle = element_text(hjust = 0.5, family = font_family, color = text_color, margin=margin(15,0,0,0)),
    plot.caption = element_text(hjust = 1, family = font_family, color = text_color, margin=margin(10,100, 0, 0)),
    legend.text = element_text(family = font_family, color = text_color),
    legend.title = element_text(family = font_family, color = text_color)
  ) +
  labs(
    title = 'Which countries have the highest meat consumption?*',
    subtitle = expression(atop("Top 10 countries are highlighted together with the amount of its CO2 emission**", atop(scriptstyle(italic("* total kg/person/year, fish are not considered as a meat")), scriptstyle(italic("** total kg CO2/person/year"))))),
    caption = caption_text,
    x = element_blank(),
    y = element_blank(),
    fill='Meat consumption:'
  )
