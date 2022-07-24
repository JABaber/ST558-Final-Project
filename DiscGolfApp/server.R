# ST558 Final Project (Server Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")


library(shiny)
library(tidyverse)
library(GGally)
library(DT)

fullSeason <- read_csv("../2022Season.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    output$DGPT <- renderImage({
      list(src = "../DGPT.jpg", width = "60%", height = "60%")
    }, deleteFile = FALSE)
    
    
    ################################################################################################################################################
    
    
                                                                        # EDA Page
    
    
    ################################################################################################################################################
    
    output$EDAPlot <- renderPlot({
      plotData <- fullSeason
      if(input$filterPlotData){
        if(input$filterPlotDirection == "Above"){
          plotData <- plotData %>% filter(noquote(input$filterPlotVar) > input$filterPlotCutoff)
        }
        else if(input$filterPlotDirection == "Below"){
          plotData <- plotData %>% filter(noquote(input$filterPlotVar) <= input$filterPlotCutoff)
        }
      }
      if(input$plotType == 'Box Plot'){
        dataPlot <- ggplot(data = plotData, aes_string(x = input$plotBoxVar)) + geom_boxplot()
      }
      else if(input$plotType == 'Histogram'){
        dataPlot <- ggplot(data = plotData, aes_string(x = input$plotHistVar)) + geom_histogram()
      }
      else if(input$plotType == "Bar Plot"){
        dataPlot <- ggplot() + geom_bar()
      }
      else if(input$plotType == "Scatter Plot"){
        dataPlot <- ggpairs(data = plotData[,c(input$plotScatVars)])
      }
      return(dataPlot)
    })
    
    output$EDATable <- renderDataTable({
      tabData <- fullSeason
      if(input$filterTabData){
        if(input$filterTabDirection == "Above"){
          tabData <- plotData %>% filter(input$filterTabVar > input$filterTabCutoff)
        }
        else if(input$filterDirection == "Below"){
          tabData <- plotData %>% filter(input$filterTabVar <= input$filterTabCutoff)
        }
      }
      if(input$tableType == "Numeric Summaries"){
        newTabData <- tabData[,c(input$tableVars)]

        dataTab <- colMeans(newTabData)
      }
      if(input$tableType == "Contingency Table"){
        
      }
      return(dataTab)
    })
    
    ################################################################################################################################################
    
    
                                                                          # Modeling Page
    
    
    ################################################################################################################################################
    
    
    
    
    
    ################################################################################################################################################
    
    
                                                                          # Data Page
    
    
    ################################################################################################################################################
    
    output$dataTable <- renderDataTable({
      discData <- fullSeason
      return(discData)
    })
    
    output$downloadData <- downloadHandler(
      filename = function(){
        paste("DiscData.csv")
      },
      content = function(file){
        write.csv(fullSeason, file, row.names = FALSE)
      }
    )

})
