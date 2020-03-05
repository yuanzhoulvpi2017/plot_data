
library(tidyverse)
library(gganimate)
library(tweenr)
x <- rep(c(1:100), each = 100)

y <- 10*sin(x) + rnorm(length(x), mean = x, sd = 10)


data_right_box <- data.frame(xmin = 1:100 + 5,
                             ymin = 0,
                             xmax = 100,
                             ymax=100,
                             state = c(1:length(1:100 + 5)))
data_left_box <- data.frame(xmin = 0, ymin=0,
                            xmax=1:100 - 5, ymax=100,
                            state = c(1:length(1:100 + 5)))




data_base <- data.frame(x = x, y = y)

data_fit <- data_base %>% group_by(x) %>% summarise(y = mean(x))
data_fit$state <- c(1:100)
base_plot <- ggplot() + geom_jitter(data = data_base, 
                       aes(x = x, y = y)) + 
  geom_rect(data = data_right_box, 
            aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax), 
            alpha = 0.4, color='gray60') +
  geom_rect(data = data_left_box, 
            aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
            alpha = 0.4, color='gray60') + 
  geom_point(data = data_fit, aes(x =x, y=y), color = 'red', size = 4) + 
  geom_path(data = data_fit,aes(x = x, y=y), color = 'red') + 
  ggtitle("公众号：pypi") +
  xlim(0, 100) + ylim(0, 100)
 
my_gif <- base_plot + transition_reveal(along = state) 
animate(my_gif, 
        width = 900, # 900px wide
        height = 600, # 600px high
        nframes = 200, # 200 frames
        fps = 10) # 10 frames per second
anim_save("公众号_pypi.gif")

