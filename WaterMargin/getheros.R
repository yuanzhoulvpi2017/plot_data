# 获得人物内容 ------------------------------------------------------------------

# 这里是从水浒传的百度百科下载人物，然后将提出出来，
# 已经保存到allheros.csv这个数据里面，如果代码运行不成功，可以直接使用
# allheros.csv的数据。


library(rvest)
library(tidyverse)



# 打开水浒传的百度百科 --------------------------------------------------------------


heros_from_baidu <- read_html("https://baike.baidu.com/item/%E6%B0%B4%E6%B5%92%E4%BC%A0/348#3_3")

# 提取两个人物表格，然后合并，
heros_part1 <- heros_from_baidu %>% 
  html_nodes(xpath = "//html//body//div[3]//div[2]//div//div[2]//table[4]") %>% 
  html_nodes("tr") %>% html_nodes("td") %>% html_text()

heros_part2 <- heros_from_baidu %>% html_nodes(xpath = "//html/body/div[3]/div[2]/div/div[2]/table[5]") %>% 
  html_nodes("tr") %>% html_nodes("td") %>% html_text()



all_heros <- c(heros_part1, heros_part2) 

# 提取出每个人物的序号，对应的绰号，和人物的名字
id <- all_heros[seq(from=1, to = length(all_heros), by = 4)]
xingxiu <- all_heros[seq(from=2, to = length(all_heros), by = 4)]
hunming <- all_heros[seq(from=3, to = length(all_heros), by = 4)]
name <- all_heros[seq(from=4, to = length(all_heros), by = 4)]


# 保存为数据框，然后保存到csv文件里面
all_heros <- tibble(id, xingxiu,hunming, name) %>% mutate(id = as.integer(id))
write_csv(x = all_heros, file = "allheros.csv")



