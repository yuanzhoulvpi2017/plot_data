# 这个是计算水浒传中108个英雄的人物之间的关系，依据的法则是看两个人物是否都在
# 一行话里面，如果一行话里面两个英雄都在，那么就标记为1.统计频数

library(tidyverse)

# 获得小说内容 ------------------------------------------------------------------

# 这个小说内容是从网络上下载下来的。alltxt是整个水浒传的内容。每一行是一句话。

alltxt <- read_table("shz_good.txt", col_names = FALSE)

# 获得人物名称 ------------------------------------------------------------------

# 先看看getheros.R的文件，这个是下载人物名称，然后导出了一个人物数据

allheros <- read_csv("allheros.csv")

# 人物匹配关系 ------------------------------------------------------------------

str_detect(string = alltxt$X1, pattern = "宋江") %>% which() # test function


# 计算各个人物出场的位置

heros_location_f <- function(herosid){
  part1 <- str_detect(string = alltxt$X1, pattern = allheros[herosid, ] %>% pull("hunming")) %>% which()
  part2 <- str_detect(string = alltxt$X1, pattern = allheros[herosid, ] %>% pull("name")) %>% which()
  allpart <- unique(c(part1, part2))
  return(allpart)
}

heros_location <- lapply(X = 1:108, FUN = heros_location_f)

# 接下来计算两个人物之间的出场关系。 如果两个人都在一句话里面，那么就是有关系的。然后统计频数

herosgird <- expand_grid(x = 1:108, y = 1:108) %>% 
  # filter(x != y) %>% 
  filter(x > y)
herosgird$value <- apply(X = herosgird, MARGIN = 1, FUN = function(x){
  intersect(x = heros_location[[x[1]]], y = heros_location[[x[2]]]) %>% length()})



# 保存人物关系 ------------------------------------------------------------------

write_csv(x = herosgird, file = "herosrelation.csv")
