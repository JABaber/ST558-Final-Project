# ST558 Final Project (UI Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")

library(shiny)
library(shinydashboard)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Example", tabName = "exampleSection"),
    menuItem("About", tabName = "aboutSection"),
    menuItem("Data Exploration", tabName = "EDASection"),
    menuItem("Modeling Info", tabName = "modelingInfoSection"),
    menuItem("Model Fitting", tabName = "modelFittingSection"),
    menuItem("Prediction", tabName = "predictionSection"),
    menuItem("Data", tabName = "dataSection")
  )
)

# Define UI for application that draws a histogram
body <- dashboardBody(
    tabItems(
      tabItem(tabName = "exampleSection",
              fluidRow(
                box(
                    "Box content here", br(), "More box content",
                    sliderInput("bins",
                                "Number of bins:",
                                min = 1,
                                max = 50,
                                value = 30),
                    textInput("test", "Text Input:")
                ),
    
                box(
                    plotOutput("distPlot")
                )
              )
      )
    )
)

dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "Example Histogram"),
  sidebar,
  body
)
