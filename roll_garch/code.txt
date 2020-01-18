library(rugarch) 
library(tseries)  
library(zoo) 
library(readxl)
library(quantmod)


raw_data <- read_xlsx('沪深300交易日收益率.xlsx') 
time<-as.Date(raw_data$'date',format="%Y/%m/%d")  
return<-raw_data$'return'  
data<-zoo(return,time)  
chartSeries(data)


# 下面这段for循环代码太慢了，用并行计算

# result_1 <- data.frame()
# 
# for (i in c(1:(2919-100+1))) {
# 
#   data_temp <- data[(i):(99+i)]
#   ug_spec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
#                         mean.model = list(armaOrder = c(0, 1)),
#                         distribution.model = "std")
#   ugfit <- ugarchfit(ug_spec, data = data_temp)
#   fit_temp <- ugarchforecast(ugfit, data = data_temp, n.ahead = 1)
# 
#   temp_data <- data.frame(t(fit_temp@forecast[["sigmaFor"]]),t(fit_temp@forecast[["seriesFor"]]))
#   colnames(temp_data) <- c("sigma", 'series')
#   cat(round(i/(2919-100+1), 3), '\t')
#   result_1 <- rbind(result_1, temp_data)
# 
# }



#######################################################
#并行运算更加的快

#设置函数
my_series_sigma <- function(i) {
  library(rugarch)
  data_temp <- data[(i):(99+i)]
  ug_spec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), #这个是必须要加
                        mean.model = list(armaOrder = c(0, 1)), #这个不要随便改，不然有错误
                        distribution.model = "std")
  ugfit <- ugarchfit(ug_spec, data = data_temp)
  fit_temp <- ugarchforecast(ugfit, data = data_temp, n.ahead = 1)
  
  temp_data <- data.frame(t(fit_temp@forecast[["sigmaFor"]]),t(fit_temp@forecast[["seriesFor"]]))
  colnames(temp_data) <- c("sigma", 'series')
  return(temp_data)
}


######################################
library(doParallel)


cl <- makeCluster(detectCores())
registerDoParallel(cl) #注册并开始并行计算
result_parallel <- foreach(x=c(1:(2919-100+1)),.combine='rbind') %dopar% my_series_sigma(x)
stopCluster(cl)

write.csv(result_parallel, file = "my_result_sigma_series.csv")
