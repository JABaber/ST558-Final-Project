# ST558 Final Project (Server Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")

# Read in packages

library(shiny)
library(tidyverse)
library(GGally)
library(DT)
library(caret)
library(psych)
library(rpart)
library(rpart.plot)
library(randomForest)

# Read in data from GitHub
fullSeason <- read_csv("../2022Season.csv")

# Start writing server code
shinyServer(function(input, output, session) {
    
    # Output the DGPT Schedule Image from the GitHub using renderImage() and customize size
    output$DGPT <- renderImage({
      list(src = "../DGPT.jpg", width = "60%", height = "60%")
    }, deleteFile = FALSE)
    
    
    ################################################################################################################################################
    
    
                                                                        # EDA Page
    
    
    ################################################################################################################################################
    
    # Create a reactive context to filter the data for the plot based on the Place variable (Player's Ranking)
    filterPlotData <- reactive({
      if(input$filterPlotData){
        discData <- fullSeason %>% filter(Place <= input$filterPlotRank)
      }
      else{
        discData <- fullSeason
      }
    })
    
    # Create a reactive context to filter the data for the summary table based on the Place variable (Player's Ranking)
    filterTabData <- reactive({
      # If filter checkbox was clicked, filter the data to contain the selected variables
      if(input$filterTabData){
        discData <- fullSeason %>% filter(Place <= input$filterTabRank)
      }
      # If no filter, just use the full data
      else{
        discData <- fullSeason
      }
    })
    
    # Code for the Plot section of the EDA
    output$EDAPlot <- renderPlot({
      # If the user selected "Box Plot" from the radio buttons
      if(input$plotType == 'Box Plot'){
        # Create a boxplot for the selected variable, customize the title and color of the plot.  Make sure to use the filtered Data
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotBoxVar)) + geom_boxplot(fill = "lightskyblue") + 
          labs(title = paste("Boxplot of", input$plotBoxVar))
      }
      # If the user selected "Histogram" from the radio buttons
      else if(input$plotType == 'Histogram'){
        # Create a histogram for the selected variable, customize title and colors and add a verticle line where the mean is
        dataPlot <- ggplot(data = filterPlotData(), aes_string(x = input$plotHistVar)) + geom_histogram(bins = input$bins, color = "black",
                                                                                                        fill = "seagreen", alpha = 0.6) +
          geom_vline(aes(xintercept = mean(!!sym(input$plotHistVar))), color = "maroon", size = 1) +
          labs(title = paste("Histogram of", input$plotHistVar, "With Line at Mean"))
      }
      # If the user selected "Scatter Plot" from the radio buttons
      else if(input$plotType == "Scatter Plot"){
        # Filter the data
        plotData <- filterPlotData()
        # Use ggpairs() on just the selected variables for the plot, customize the colors and contents of the graphs with lower, diag, and upper args
        dataPlot <- ggpairs(data = plotData[,c(input$plotScatVars)], lower = list(continuous = wrap("smooth", color = "darksalmon")),
                            diag = list(continuous = wrap("densityDiag", fill = "lavender")), upper = list(continuous = wrap("cor", color = "blue")))
      }
      # Return the selected plot
      return(dataPlot)
    })
    
    # Code for the summaries table in the EDA section
    output$EDATable <- renderDataTable({
      # Grab the filtered data
      tabData <- filterTabData()
      # Subset the filtered data to contain the selected variables
      newTabData <- tabData[,c(input$tableVars)]
      # Use the describe() function from the psych package to get summary stats of all selected variables
      discSummary <- describe(newTabData)
      # Subset to contain the summaries that the user selected and round the numbers to four digits
      newDiscSummary <- round(discSummary[,c(input$summaries)], digits = 4)
      # Rename the columns in the table for appearance's sake
      colnames(newDiscSummary) <- c("Mean", "Standard Deviation", "Min", "Median", "Max")
      # Return the data table
      return(newDiscSummary)
    })
    
    ################################################################################################################################################
    
    
                                                                          # Modeling Page
    
    
    ################################################################################################################################################
    
    # Code for mathJax expression for the equation for a Multiple Linear Regression
    output$MLREquation <- renderUI({
      withMathJax(
        helpText(
          '$$\\hat{Y} = \\beta_0 + \\beta_1 x_1 + \\beta_2 x_2 + ... + \\beta_n x_n$$'
        )
      )
    })
    
    # Code for mathJax expression for the equation for the Residual Sum of Squares
    output$squaresEquation <- renderUI({
      withMathJax(
        helpText(
          '$$\\textit{min}_{\\beta_0 , \\beta_1} = \\displaystyle\\sum_{i = 1} ^{n} (y_i - \\beta_0 - \\beta_1 x_1 - ... - \\beta_n x_n)^2$$'
        )
      )
    })
    
    # Check if the action button to fit the models was clicked
    observeEvent(input$fit, {
      
      # Pop up message when the button is clicked while the code below runs
      showModal(modalDialog("Fitting Models...", footer = NULL))
      
      # Split the data using createDataPartition() based on the user-selected proportions
      split <- createDataPartition(fullSeason$Points, p = input$dataSplit, list = FALSE)
      # Save the training set
      trainScores <- fullSeason[split,]
      # Save the testing set
      testScores <- fullSeason[-split,]
      
      # Subset the training and testing sets to contain the variables selected as well as the response variable, Points, for MLR model fitting
      mlrTrain <- trainScores[,c(input$MLRVars, "Points")]
      mlrTest <- testScores[,c(input$MLRVars, "Points")]
      
      # Subset the training and testing sets to contain the variables selected and Points for the regression tree fitting
      treeTrain <- trainScores[,c(input$treeVars, "Points")]
      treeTest <- testScores[,c(input$treeVars, "Points")]
      
      # Subset the training and testing sets to contain the variables selected and Points for the random forest model fitting
      rfTrain <- trainScores[,c(input$rfVars, "Points")]
      rfTest <- testScores[,c(input$rfVars, "Points")]
      
      # Create a string for each model that is the right side of the model fitting formulas from the respective selected vars
      mlrNames <- paste0(input$MLRVars, collapse = "+")
      treeNames <- paste0(input$treeVars, collapse = "+")
      rfNames <- paste0(input$rfVars, collapse = "+")
      response <- "Points"
      
      # Check if the user selected the interaction checkbox to include interaction terms in the MLR model
      if(input$interaction){
        # If so, put parentheses around the predictor string and square it too
        intNames <- paste0("(", mlrNames, ")^2")
        # Train the MLR model on the training set using as.formula() to set up the first argument
        # Perform cross validation with the number of folds the user chose using trainControl(), and standardize the data too with preProcess
        MLR <<- train(as.formula(paste(response, intNames, sep = " ~ ")),
                               data = mlrTrain, method = "lm", 
                               trControl = trainControl(method = "cv", number = input$folds),
                               preProcess = c("center", "scale"))
      }
      # If the user did not select the interaction checkbox, meaning they do not want interaction terms
      else{
        # Train the MLR model on the training set using as.formula() to set up the first argument
        # Perform cross validation with the number of folds the user chose using trainControl(), and standardize the data with preProcess
        MLR <<- train(as.formula(paste(response, mlrNames, sep = " ~ ")),
                     data = mlrTrain, method = "lm", 
                     trControl = trainControl(method = "cv", number = input$folds),
                     preProcess = c("center", "scale"))
      }
      
      # Fit the regression tree model using the same as.formula() technique, but this time with the variables selected for the tree model
      # Here we say method = "rpart", and we perform cross validation using however many folds the user selected with trainControl(), standardize the data
      # with preProcess().  We also have to use the values of min, max, and step size that the user chose for the cp tuning parameter using tuneGrid
      regTree <<- train(as.formula(paste(response, treeNames, sep = " ~ ")),
                       data = treeTrain, method = "rpart",
                       trControl = trainControl(method = "cv", number = input$folds),
                       preProcess = c("center", "scale"),
                       tuneGrid = expand.grid(cp = seq(from = input$cpMin, to = input$cpMax, by = input$cpStep)))
      
      # Fit the random forest model using as.formula(), method = "rf", standardize and cross validate the data same as before.
      # Here we have the tuning parameter m, which the user selects a minimum and maximum of values to try using tuneGrid
      RF <<- train(as.formula(paste(response, rfNames, sep = " ~ ")), data = rfTrain, method = "rf",
                  trControl = trainControl(method = "cv", number = input$folds),
                  preProcess = c("center", "scale"),
                  tuneGrid = expand.grid(mtry = c(input$mMin : input$mMax)))
      
      # Once this code has run, we can stop the message that says the models are running
      removeModal()
      
      # Create an output table that contains the RMSEs of all three model fits
      output$RMSEs <- renderDataTable({
        # Get the best RMSEs from all three models and put it in a tibble
        RMSETable <- tibble(MLR$results$RMSE, min(regTree$results$RMSE), min(RF$results$RMSE))
        # Rename the columns of the table so that we know which value is which
        colnames(RMSETable) <- c("MLR", "RegressionTree", "RandomForest")
        # Round all values to four digits
        RMSETable <- round(RMSETable, digits = 4)
        # Transpose the table for readability
        RMSETablePivot <- t(RMSETable)
        # Name the single column "RMSE"
        colnames(RMSETablePivot) <- c("RMSE")
        # Return the transposed table of RMSEs
        return(RMSETablePivot)
      })
      
      # Output that is just the MLR summary from the console output
      output$MLRfit <- renderPrint({
        summary(MLR)
      })
      
      # Output that is a plot of the regression tree that was fit, this uses the rpart.plot() function on the best model that was fit
      output$treePlot <- renderPlot({
        rpart.plot(regTree$finalModel)
      })
      
      # Output of variable importances from the random forest model.  Round all values to four digits and change default to display all 12 predictors
      output$importance <- renderDataTable({
        rfImp <- datatable(round(varImp(RF)$importance, digits = 4), options = list(pageLength = 12))
        return(rfImp)
      })
      
      # Create a table that contains the RMSE and other fit statistics of the models on the testing set
      output$testFit <- renderDataTable({
        # Make predictions for each of the three models using the testing set
        mlrPred <- predict(MLR, newdata = mlrTest)
        regTreePred <- predict(regTree, newdata = treeTest)
        rfPred <- predict(RF, newdata = rfTest)
        # Evaluate the predictions on the testing set and create a data frame from the resulting fit statistics
        errorTab <- data.frame(
          postResample(mlrPred, obs = mlrTest$Points),
          postResample(regTreePred, obs = treeTest$Points),
          postResample(rfPred, obs = rfTest$Points)
        )
        # Rename the columns so that we know which column is which model
        colnames(errorTab) <- c("MLR", "Regression Tree", "Random Forest")
        # Round all values in the table to four digits
        errorTab <- round(errorTab, digits = 4)
        # Return the table
        return(errorTab)
      })
    })
    
    # Check if the action button was clicked for predictions
    observeEvent(input$predict, {
      
      # Create the data frame that contains the values for each predictor
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
      
      # Make a prediction from the chosen model using if/then/else logic on the type of model that is selected
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
      
      # Print out the value of the predicted Point total
      output$PointsPrediction <- renderPrint(predictedPoints())
      
      # Print out a message to help interpret what that number means
      output$points <- renderText(paste("A player with these statistics is predicted to have", round(predictedPoints(), digits = 4), "points."))
    })
    
    
    
    ################################################################################################################################################
    
    
                                                                          # Data Page
    
    
    ################################################################################################################################################
    
    # Create reactive context for data, filtered or not
    filterDTData <- reactive({
      # Check if the filter checkbox was selected
      if(input$filterDT){
        # If so, filter the data to contain the variables the user selected and the top x players selected
        discData <- fullSeason %>% filter(Place <= input$filterDTRank) %>% select(c(input$DTVars))
      }
      else{
        # If not, the user can still choose the columns they want
        discData <- fullSeason %>% select(c(input$DTVars))
      }
    })
    
    # Output the filtered data table
    output$dataTable <- renderDataTable({
      filterDTData()
    })
    
    # The user can download the output data table, with selected columns and filtered by rank
    output$downloadData <- downloadHandler(
      # Make file name
      filename = "DiscData.csv",
      # Write a function that writes the filtered data table to a CSV
      content = function(file){
        write.csv(filterDTData(), file, row.names = FALSE)
      }
    )

})
