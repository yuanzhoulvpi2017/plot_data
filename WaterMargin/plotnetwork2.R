# 这代码也是制作一个网络图，但是可以显示每个人物的图片
# 就是加了一个代码，这个代码是根据人物的名字从百度图片上下载对应的人物的图片的，
# 但是大概有几个人物的照片是找不到的




library(tidyverse)
library(visNetwork)


# 创建nodes -----------------------------------------------------------------

nodes_base <- read_csv("allheros.csv") %>% mutate(id = id, label = name) %>% select(id, label) %>% 
  mutate(shape = "circle")

# 创建edges -----------------------------------------------------------------

edges_base <- read_csv("herosrelation.csv")  %>% mutate(from = x, to = y) 



# 进一步处理nodes和edges --------------------------------------------------------


nodes <- nodes_base %>% left_join(y = edges_base %>% group_by(to) %>% summarise(value = sum(value)),
                                  by = c("id" = "to")) %>% mutate(color = ifelse(value > 1000, "red", "green"))

edges <- edges_base %>% select(from, to) %>% sample_n(400)


# 添加照片 --------------------------------------------------------------------
library(jsonlite)
gethero_photo <- function(heroname) {
  base_url <- paste0("https://image.baidu.com/search/acjson?tn=resultjson_com&ipn=rj&ct=201326592&is=&fp=result&queryWord=tesla&cl=2&lm=-1&ie=utf-8&oe=utf-8&adpicid=&st=-1&z=&ic=&hd=&latest=&copyright=&word=",
                     URLencode(heroname))
  
  image_url_on_page <- fromJSON(base_url)[["data"]][["thumbURL"]]
  image_url_on_page <- image_url_on_page[which(!is.na(image_url_on_page))]
  return(image_url_on_page[3])
}


heroname <- "关胜" # test function 
gethero_photo("宋江") # test function
gethero_photo("武松") # test function
# gethero_photo("阮小七水浒传照片") # test function

safely(gethero_photo, "null")("阮小七水浒传照片")$result


# 开始下载各个英雄的照片 -------------------------------------------------------------



heros_photos <- c()
for (i in seq_along(nodes$label)) {
  # Sys.sleep(2)
  cat(nodes$label[i], '\n')
  tempphoto <- safely(gethero_photo, 'NA')(nodes$label[i])$result
  heros_photos <- c(heros_photos, tempphoto)
}

nodes_photo <- nodes %>% mutate(shape = "image", image = heros_photos)

# 开始画图 --------------------------------------------------------------------


network <- visNetwork(nodes = nodes_photo, edges = edges, 
                      height = "900px", width = "100%", 
                      main = "水浒传关系图<br>由公众号：pypi制作 <br>") %>% 
  visPhysics(solver = "barnesHut",maxVelocity = 2)
network %>% visSave(file = "network2.html")
