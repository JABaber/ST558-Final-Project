# ST558 Final Project (Server Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")


library(shiny)
library(tidyverse)
library(GGally)
library(DT)
library(caret)
library(psych)
library(rpart)
library(rpart.plot)
library(randomForest)

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
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotBoxVar)) + geom_boxplot(fill = "lightskyblue") + 
          labs(title = paste("Boxplot of", input$plotBoxVar))
      }
      else if(input$plotType == 'Histogram'){
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotHistVar)) + geom_histogram(bins = input$bins, color = "black",
                                                                                                        fill = "seagreen", alpha = 0.6) +
          geom_vline(aes(xintercept = mean(!!sym(input$plotHistVar))), color = "maroon", size = 1) +
          labs(title = paste("Histogram of", input$plotHistVar, "With Line at Mean"))
      }
      else if(input$plotType == "Scatter Plot"){
        plotData <- filterPlotData()
        dataPlot <- ggpairs(data = plotData[,c(input$plotScatVars)], lower = list(continuous = wrap("smooth", color = "darksalmon")),
                            diag = list(continuous = wrap("densityDiag", fill = "lavender")), upper = list(continuous = wrap("cor", color = "blue")))
      }
      return(dataPlot)
    })
    
    output$EDATable <- renderDataTable({
      tabData <- filterTabData()
      newTabData <- tabData[,c(input$tableVars)]
      discSummary <- describe(newTabData)
      newDiscSummary <- round(discSummary[,c(input$summaries)], digits = 4)
      colnames(newDiscSummary) <- c("Mean", "Standard Deviation", "Min", "Median", "Max")
      return(newDiscSummary)
    })
    
    ################################################################################################################################################
    
    
                                                                          # Modeling Page
    
    
    ################################################################################################################################################
    
    output$MLREquation <- renderUI({
      withMathJax(
        helpText(
          '$$\\hat{Y} = \\beta_0 + \\beta_1 x_1 + \\beta_2 x_2 + ... + \\beta_n x_n$$'
        )
      )
    })
    
    output$squaresEquation <- renderUI({
      withMathJax(
        helpText(
          '$$\\textit{min}_{\\beta_0 , \\beta_1} = \\displaystyle\\sum_{i = 1} ^{n} (y_i - \\beta_0 - \\beta_1 x_1 - ... - \\beta_n x_n)^2$$'
        )
      )
    })
    
    
    observeEvent(input$fit, {
      
      showModal(modalDialog("Fitting Models...", footer = NULL))
      
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
        MLR <<- train(as.formula(paste(response, intNames, sep = " ~ ")),
                               data = mlrTrain, method = "lm", 
                               trControl = trainControl(method = "cv", number = input$folds),
                               preProcess = c("center", "scale"))
      }
      else{
        MLR <<- train(as.formula(paste(response, mlrNames, sep = " ~ ")),
                     data = mlrTrain, method = "lm", 
                     trControl = trainControl(method = "cv", number = input$folds),
                     preProcess = c("center", "scale"))
      }
      
      regTree <<- train(as.formula(paste(response, treeNames, sep = " ~ ")),
                       data = treeTrain, method = "rpart",
                       trControl = trainControl(method = "cv", number = input$folds),
                       preProcess = c("center", "scale"),
                       tuneGrid = expand.grid(cp = seq(from = input$cpMin, to = input$cpMax, by = input$cpStep)))
      
      RF <<- train(as.formula(paste(response, rfNames, sep = " ~ ")), data = rfTrain, method = "rf",
                  trControl = trainControl(method = "cv", number = input$folds),
                  preProcess = c("center", "scale"),
                  tuneGrid = expand.grid(mtry = c(input$mMin : input$mMax)))
      
      removeModal()
      
      output$RMSEs <- renderDataTable({
        RMSETable <- tibble(MLR$results$RMSE, min(regTree$results$RMSE), min(RF$results$RMSE))
        colnames(RMSETable) <- c("MLR", "RegressionTree", "RandomForest")
        RMSETable <- round(RMSETable, digits = 4)
        RMSETablePivot <- t(RMSETable)
        colnames(RMSETablePivot) <- c("RMSE")
        return(RMSETablePivot)
      })
      
      output$MLRfit <- renderPrint({
        summary(MLR)
      })
      
      output$treePlot <- renderPlot({
        rpart.plot(regTree$finalModel)
      })
      
      output$importance <- renderDataTable({
        rfImp <- datatable(round(varImp(RF)$importance, digits = 4), options = list(pageLength = 12))
        return(rfImp)
      })
      
      output$testFit <- renderDataTable({
        mlrPred <- predict(MLR, newdata = mlrTest)
        regTreePred <- predict(regTree, newdata = treeTest)
        rfPred <- predict(RF, newdata = rfTest)
        errorTab <- data.frame(
          postResample(mlrPred, obs = mlrTest$Points),
          postResample(regTreePred, obs = treeTest$Points),
          postResample(rfPred, obs = rfTest$Points)
        )
        colnames(errorTab) <- c("MLR", "Regression Tree", "Random Forest")
        errorTab <- round(errorTab, digits = 4)
        return(errorTab)
      })
    })
    
    observeEvent(input$predict, {
      
      predData <- reactive({
        data.frame(Birdie = input$predBirdie,
                   Par = input$predPar,
                   Bogey = input$predBogey,
                   Fairway = input$predFairway,
                   Parked = input$predParked,
                   Circle1InReg = input$predCircle1InReg,
                   Circle2InReg = input$predCircle2InReg,
                   Scramble = input$predScramble,
                   Circle1XPutting = input$predCircle1XPutting,
                   Circle2Putting = input$predCircle2Putting,
                   ThrowInRate = input$predThrowInRate,
                   OBRate = input$predOBRate)
      })
      
      predictedPoints <- reactive({
        if(input$predModel == "Multiple Linear Regression"){
          predict(MLR, predData())
        }
        else if(input$predModel == "Regression Tree"){
          predict(regTree, predData())
        }
        else if(input$predModel == "Random Forest"){
          predict(RF, predData())
        }
      })
      
      output$PointsPrediction <- renderPrint(predictedPoints())
      
      output$points <- renderText(paste("A player with these statistics is predicted to have", round(predictedPoints(), digits = 4), "points."))
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
