# ST558 Final Project (Server Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")


library(shiny)
library(tidyverse)
library(GGally)
library(DT)
library(caret)
library(psych)

fullSeason <- read_csv("../2022Season.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    output$DGPT <- renderImage({
      list(src = "../DGPT.jpg", width = "60%", height = "60%")
    }, deleteFile = FALSE)
    
    
    ################################################################################################################################################
    
    
                                                                        # EDA Page
    
    
    ################################################################################################################################################
    
    filterPlotData <- reactive({
      if(input$filterPlotData){
        discData <- fullSeason %>% filter(Place <= input$filterPlotRank)
      }
      else{
        discData <- fullSeason
      }
    })
    
    filterTabData <- reactive({
      if(input$filterTabData){
        discData <- fullSeason %>% filter(Place <= input$filterTabRank)
      }
      else{
        discData <- fullSeason
      }
    })
    
    output$EDAPlot <- renderPlot({
      if(input$plotType == 'Box Plot'){
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotBoxVar)) + geom_boxplot()
      }
      else if(input$plotType == 'Histogram'){
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotHistVar)) + geom_histogram(bins = input$bins)
      }
      else if(input$plotType == "Scatter Plot"){
        plotData <- filterPlotData()
        dataPlot <- ggpairs(data = plotData[,c(input$plotScatVars)])
      }
      return(dataPlot)
    })
    
    output$EDATable <- renderDataTable({
      tabData <- filterTabData()
      newTabData <- tabData[,c(input$tableVars)]
      discSummary <- describe(newTabData)
      newDiscSummary <- round(discSummary[,c(input$summaries)], digits = 4)
      return(newDiscSummary)
    })
    
    ################################################################################################################################################
    
    
                                                                          # Modeling Page
    
    
    ################################################################################################################################################
    
    
    observeEvent(input$fit, {
      
      split <- createDataPartition(fullSeason$Points, p = input$dataSplit, list = FALSE)
      trainScores <- fullSeason[split,]
      testScores <- fullSeason[-split,]
      
      mlrTrain <- trainScores[,c(input$MLRVars, "Points")]
      mlrTest <- testScores[,c(input$MLRVars, "Points")]
      
      treeTrain <- trainScores[,c(input$treeVars, "Points")]
      treeTest <- testScores[,c(input$treeVars, "Points")]
      
      rfTrain <- trainScores[,c(input$rfVars, "Points")]
      rfTest <- testScores[,c(input$rfVars, "Points")]
      
      mlrNames <- paste0(input$MLRVars, collapse = "+")
      treeNames <- paste0(input$treeVars, collapse = "+")
      rfNames <- paste0(input$rfVars, collapse = "+")
      response <- "Points"
      
      if(input$interaction){
        intNames <- paste0("(", mlrNames, ")^2")
        MLR <- train(as.formula(paste(response, intNames, sep = " ~ ")),
                               data = mlrTrain, method = "lm", 
                               trControl = trainControl(method = "cv", number = input$folds),
                               preProcess = c("center", "scale"))
      }
      else{
        MLR <- train(as.formula(paste(response, mlrNames, sep = " ~ ")),
                     data = mlrTrain, method = "lm", 
                     trControl = trainControl(method = "cv", number = input$folds),
                     preProcess = c("center", "scale"))
      }
      
      regTree <- train(as.formula(paste(response, treeNames, sep = " ~ ")),
                       data = treeTrain, method = "rpart",
                       trControl = trainControl(method = "cv", number = input$folds),
                       preProcess = c("center", "scale"),
                       tuneGrid = expand.grid(cp = seq(from = input$cpMin, to = input$cpMax, by = input$cpStep)))
      
      rf <- train(as.formula(paste(response, rfNames, sep = " ~ ")), data = rfTrain, method = "rf",
                  trControl = trainControl(method = "cv", number = input$folds),
                  preProcess = c("center", "scale"),
                  tuneGrid = expand.grid(mtry = c(input$mMin : input$mMax)))
      output$RMSEs <- renderDataTable({
        tibble(MLR$results$RMSE, min(regTree$results$RMSE), min(rf$results$RMSE))
      })
      
    })
    
    
    
    ################################################################################################################################################
    
    
                                                                          # Data Page
    
    
    ################################################################################################################################################
    
    filterDTData <- reactive({
      if(input$filterDT){
        discData <- fullSeason %>% filter(Place <= input$filterDTRank)
      }
      else{
        discData <- fullSeason
      }
    })
    
    output$dataTable <- renderDataTable({
      dt <- filterDTData()
      newdt <- dt[,c(input$DTVars)]
      return(newdt)
    })
    
    output$downloadData <- downloadHandler(
      filename = function(){
        paste("DiscData.csv")
      },
      content = function(file){
        write.csv(newdt, file, row.names = FALSE)
      }
    )

})
