#  这个网络图就是一个最基础的。


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




# 开始画图 --------------------------------------------------------------------


network <- visNetwork(nodes = nodes, edges = edges, height = "900px", width = "120%") %>% 
  # visNodes(size = 700) %>% 
  visPhysics(solver = "barnesHut",maxVelocity = 2)
  # visIgraphLayout()
  # visInteraction(hideEdgesOnDrag = TRUE) %>%
  # visLayout(randomSeed = 123)
  # visPhysics(solver = "forceAtlas2Based", 
  #            forceAtlas2Based = list(gravitationalConstant = -500))
network %>% visSave(file = "network.html")
