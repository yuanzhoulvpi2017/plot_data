install.packages(c("devtools", "dplyr", "oz", "ozmaps", "readxl")) 
#下面通过library安装的包都要安装
devtools::install_github("thomasp85/transformr")


library(oz)
library(ozmaps)
library(ggplot2)
library(sf)
library(readxl)
library(dplyr)
library(gganimate)
library(tweenr)

#地图数据
sf_oz <- ozmap_data("states")
sf_oz <- sf_oz[-9, ]

#你发的文件，
data_state <- read_xlsx("中国留学生澳洲地区分布.xlsx")
names(data_state) <- c("year", (tibble::as_tibble(sf_oz))[, 1]$NAME)
data_state <- data_state[c(1:11), ]


value = as.matrix(data_state[, -1])
dim(value) <- 88
tidy_data <- tibble(value = value, 
                    year = rep(data_state$year, time = 8),
                    NAME = rep(unlist(names(data_state)[-1]), each = 11)
)
test_data <- left_join(sf_oz, tidy_data, by = "NAME")


anim <- ggplot(data = test_data) + geom_sf(aes(fill = value)) + 
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_continuous(low = "white", high = "darkblue") + 
  transition_states(year) + ggtitle("第{closest_state}年中国留澳学生分布")

animate(anim, 100, fps = 20,  width = 1200, height = 1000, 
        renderer = gifski_renderer("australia.gif"))  #改变第一100，可以改变帧数





