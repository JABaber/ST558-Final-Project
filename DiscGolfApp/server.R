# ST558 Final Project (Server Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")


library(shiny)
library(tidyverse)
library(GGally)
library(DT)

fullSeason <- read_csv("../2022Season.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
    
    output$DGPT <- renderImage({
      list(src = "../DGPT.jpg", width = "60%", height = "60%")
    }, deleteFile = FALSE)
    
    output$dataTable <- renderDataTable({
      fullSeason
    })

})
