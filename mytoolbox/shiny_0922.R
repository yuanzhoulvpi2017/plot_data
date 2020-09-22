library(shiny)
library(tidyverse)

cal_each_t_test <- function(temp_colnames, all_data) {
  # cat(temp_colnames, '\n')
  temp_data <- all_data %>% select(c("group", temp_colnames)) %>% na.omit()
  
  out <- tryCatch({
    temp_t_test_result <- t.test(formula(paste0("`", temp_colnames,"`~group")), data = temp_data)
    t_value <- temp_t_test_result$statistic
    df_value <- temp_t_test_result$parameter
    p_value <- temp_t_test_result$p.value
    low_conf_value <- temp_t_test_result$conf.int[1]
    upper_conf_value <- temp_t_test_result$conf.int[2]
    mean_in_group_1 <- temp_t_test_result$estimate[1]
    mean_in_group_2 <- temp_t_test_result$estimate[2]
    difference_in_means <- temp_t_test_result$null.value
    result <- data.frame('colunames' = temp_colnames,
                         't' = t_value,
                         "df_value" = df_value,
                         "p_value" = p_value,
                         "low_conf_value" = low_conf_value,
                         "upper_conf_value" = upper_conf_value,
                         "mean_in_group_1" = mean_in_group_1,
                         "mean_in_group_2" = mean_in_group_2,
                         "difference_in_means" = difference_in_means)
    result
  },
  error=function(cond) {
    message(paste("colnames caused a warning:", temp_colnames))
    # message("Here's the original error message:")
    # message(cond)
    # Choose a return value in case of error
    result <- data.frame('colunames' = temp_colnames,
                         't' = NA,
                         "df_value" = NA,
                         "p_value" = NA,
                         "low_conf_value" = NA,
                         "upper_conf_value" = NA,
                         "mean_in_group_1" = NA,
                         "mean_in_group_2" = NA,
                         "difference_in_means" = NA)
    return(result)
  },
  warning=function(cond) {
    message(paste("colnames caused a warning:", temp_colnames))
    # message("Here's the original warning message:")
    # message(cond)
    result <- data.frame('colunames' = temp_colnames,
                         't' = NA,
                         "df_value" = NA,
                         "p_value" = NA,
                         "low_conf_value" = NA,
                         "upper_conf_value" = NA,
                         "mean_in_group_1" = NA,
                         "mean_in_group_2" = NA,
                         "difference_in_means" = NA)
    return(result)
  },
  finally={
    message(paste("Processing colnames: ", temp_colnames))
  })
  
  return(out)
}
opendir <- function(dir = getwd()){
  if (.Platform['OS.type'] == "windows"){
    shell.exec(dir)
  } else {
    system(paste(Sys.getenv("R_BROWSER"), dir))
  }
}


ui <- fluidPage(
  titlePanel("欢迎关注微信公众号：pypi"),
  tags$a(href = "https://zhuanlan.zhihu.com/p/258119118", "请点击这个链接获得使用方法 当前版本为：20200923"),
  tags$head(tags$style(HTML(".shiny-notification {
    position:fixed;
    top: calc(50%);
    left: calc(50%);}"))),
  navbarPage("批量计算",
             tabPanel("计算t检验",
                      sidebarLayout(
                        sidebarPanel(
                          fileInput(inputId = "ttest_file", label = "choose a file to t.test"),
                          selectInput(inputId = "sel_colname", label = "select a colname to cal", choices = NULL),
                          actionButton("clickttest", "start to cal t.test", class = "btn-success")
                        ),
                        mainPanel(
                          div(style="width:700px;",verbatimTextOutput(outputId = "small_ttest", placeholder = TRUE)),
                          dataTableOutput("clean_ttest"),
                          dataTableOutput("start_cal_ttest")
                        ))),
             tabPanel("持续更新中",
                      tags$div("如果有好的想法，欢迎和我联系：yuanzhoulvpi@outlook.com"))),
  
  
)

server <- function(input, output, session) {
  
  need_to_t_test_data <- reactive({
    req(input$ttest_file)
    id <- showNotification("Reading data...", duration = NULL, closeButton = FALSE)
    on.exit(removeNotification(id), add = TRUE)
    data <- read_csv(input$ttest_file$datapath)
  })
  
  observeEvent(need_to_t_test_data(),
               {all_colname <- colnames(need_to_t_test_data())
               all_colname <- all_colname[all_colname != "group"]
               updateSelectInput(session, "sel_colname", choices = all_colname)})
  
  output$small_ttest <- renderPrint({
    req(input$ttest_file)
    req(input$sel_colname)
    temp_data <- need_to_t_test_data() %>% select(c("group", input$sel_colname))
    t.test(formula(paste0("`", input$sel_colname,"`~group")), data = temp_data)
  })
  
  output$clean_ttest <- renderDataTable({
    req(need_to_t_test_data())
    req(input$sel_colname)
    cal_each_t_test(input$sel_colname, all_data = need_to_t_test_data())
  })
  
  
  result_ttest <- reactive({
    req(need_to_t_test_data)
    req(input$clickttest)
    
    all_data <- need_to_t_test_data()
    all_colname2 <- colnames(need_to_t_test_data())
    all_colname2 <- all_colname2[all_colname2 != "group"]
    
    progress <- Progress$new(max = length(all_colname2))
    on.exit(progress$close())
    
    progress$set(message = "正在计算中，起飞～")
    final_result <- data.frame()
    for (i in seq_along(all_colname2)) {
      progress$inc(1)
      temp_colnames <- all_colname2[i]
      temp_result <- cal_each_t_test(temp_colnames = temp_colnames, all_data = all_data)
      final_result <- rbind(final_result, temp_result)
      
    }
    final_result
  })
  
  output$start_cal_ttest <- renderDataTable({
    req(need_to_t_test_data)
    final_ttest <- result_ttest()
    # save data to pypi dir
    if (!dir.exists("pypi_result")) {
      dir.create("pypi_result")
    }
    currenttime <- Sys.time()
    currenttime <- str_replace_all(str_replace_all(currenttime, pattern = ":", replacement = "_"), pattern = " ", replacement = "_")

    ttest_filename <- paste0(getwd(), "/pypi_result/", currenttime, ".csv")
    write_csv(x = final_ttest, path = ttest_filename)
    showNotification(paste0("data has been saved in: ", ttest_filename), duration = 1000, closeButton = TRUE)
    
    opendir()
    final_ttest
    
  })
  
}

shinyApp(ui, server)


