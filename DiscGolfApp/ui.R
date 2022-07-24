# ST558 Final Project (UI Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")

library(shiny)
library(shinydashboard)
library(DT)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Example", tabName = "exampleSection"),
    menuItem("About", tabName = "aboutSection"),
    menuItem("Data Exploration", tabName = "EDASection"),
    menuItem("Modeling", tabName = "modelSection"),
    menuItem("Data", tabName = "dataSection")
  )
)

# Define UI for application that draws a histogram
body <- dashboardBody(
    tabItems(
      tabItem(tabName = "exampleSection",
              fluidPage(
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
      ),
      
      tabItem(tabName = "aboutSection",
              fluidPage(
                h1("Disc Golf Pro Tour 2022 Season Statistics and Modeling"), br(),
                h3("Purpose"), br(),
                "This is an app created with R Shiny to explore data from the 2022 DGPT Season and fit models to predict total points in standings and what stats are most important when it comes to finishing highly in the DGPT standings.  The user of the app can select variables to look at in graphs and tables to visualize data.  The user can fit a model on the data with a selection of variables that they choose.  They can then use that model to make predictions based on chosen values for each variable.", strong("Please note that this data is only from the 2022 season as of July 20th, thus predictions should only be interpreted for that timeframe."), br(),
                
                h3("Data Origin"), br(),
                "The data comes from UDisc's website.  UDisc is an app that provides a service that is essential to the disc golf community.  Users can use it to find disc golf courses on the map, create scorecards for themselves and friends, and keep track of many different statistics much like the ones we will see in this analysis.  UDisc has recently become responsible for keeping track of the Disc Golf Pro Tour's statistics.  Pro player's statistics can be found on the UDisc Live webpage at", tags$a("UDisc Live", href = "https://www.udisclive.com/"),  ".  UDisc makes it easy to see the statistics for every player at just about any Disc Golf Pro Tour event since 2016, or the statistics for each player for an entire season.  This data specifically focuses on the cumulative data from this year's DGPT season, which can be found at the", tags$a("DGPT 2022 Season Stats Webpage.", href = "https://www.udisclive.com/stats?d=MPO&t=stats&y=2022&z=dgpt"), br(), 
                
                "There 12 predictors to choose from in this data set, with the response variable being the total points a player has in the standings.  I can explain them briefly here, but more detail can be found at the", tags$a("UDisc About Stats Webpage.", href = "https://www.udisclive.com/about"), 
                tags$ul(
                  tags$li(strong("Birdie, Par, and Bogey Rates"), "- are the percent of holes played that each player got birdies or better, pars, or bogeys on."),
                  tags$li(strong("Fairway in Reg"), "- is essentially the percent of holes a player is on the fairway or better with two shots remaining for par.  The technical definition of this changes for pars 3, 4, or 5.  Parked in Reg, Circle1 in Reg, and Circle2 in Reg all may contribute to this stat."),
                  tags$li(strong("Parked in Reg"), "- is the percent of holes a player has a tap-in putt for birdie or better.  A shot is defined as", strong("Parked"), "if the shot is within 10 feet of the basket. Circle 1 in Reg may contribute to this stat."),
                  tags$li(strong("Circle1 in Reg"), "- is the percent of holes a player is in circle 1, which is defined as being within 10 meters of the basket, with two shots remaining for par."), 
                  tags$li(strong("Circle2 in Reg"), "- is the percent of holes a player is in circle 2, which is defined as being within 20 meters of the basket, with two shots remaining for par."),
                  tags$li(strong("Scramble Rate"), "- is the percent of times a player is able to recover a par or better after having a shot go Out of Bounds or off the Fairway."), 
                  tags$li(strong("Circle1x Putting Rate"), "- is simply the percent of putts a player has made within Circle 1, excluding shots that are parked.  In disc golf, there is a major distinction between putting in circle 1 and anywhere else.  If a player is in circle 1, they must putt without taking a step or jumping, essentially they must putt standing still or only raising one leg and may not lose balance until the putt is made."), 
                  tags$li(strong("Circle2 Putting Rate"), "- is the percent of putts a player has made within Circle 1."),
                  tags$li(strong("Throw In Rate"), "- is defined as the percent of holes a player has made a shot outside of Circle 2.  This is generally unlikely so these will be very low values, but still may be interesting to include."),
                  tags$li(strong("OB Rate"), "- is the total Out of Bounds strokes a player has divided by the total number of holes played."),
                  tags$li(strong("Points"), "- are the total number of points a player has in the 2022 DGPT standings, as of July 20th.  Players get points based on how well they place at tournaments.  The amount of points represents a player's average placement during the season, much like standings points in the MLB, NHL, or NBA.  We can predict the number of points a player has based on these other predictors, or see which predictors are most contribute the highest to placements via modeling.")
                ),
                
                
                "In short, I was able to use ", tags$a("this data scraper Chrome extension", href = "https://chrome.google.com/webstore/detail/instant-data-scraper/ofaokhiedipichpaobibbnahnkdoiiah?hl=en-US"), " to grab the data from the UDisc webpage as a CSV file.  It took some cleaning to do, like dropping irrelevant columns, renaming the columns, and scaling them.  Most of the data is given as percentages with a % symbol, so I had to use lapply() to remove them and convert them from decimals for interpretation's sake.  Also, the total points each player had were not available on the 2022 Season Stats Webpage, so I had to go to the ", tags$a("2022 Season Standings Webpage", href = "https://www.udisclive.com/standings?d=MPO"), " to again scrape the data into a CSV.  I then performed a left join on the player's names in R to create the final data set.  The code to create the data set can be found", tags$a("here.", href = "https://github.com/JABaber/ST558-Final-Project/blob/main/DiscGolfDataCleaning.Rmd"),  "An image of the 2022 Pro Tour Schedule can be found below:", br(), imageOutput("DGPT", inline = TRUE), br(), 
                
                h3("Explanation of Tabs"), br(),
                h5("Data Exploration Tab"), br(),
                h5("Modeling Tab"), br(),
                h5("Data Tab")
              )
      ),
      
      tabItem(tabName = "EDASection",
              fluidRow(
                box(width = 4,
                  selectInput("plotType", "Select Plot Type", choices = list("Box Plot", "Histogram", "Scatter Plot", "Bar Plot")),
                  conditionalPanel(
                    condition = "input.plotType == 'Box Plot'",
                    radioButtons("plotBoxVar", "Choose Variable for Box Plot", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                              "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                              "Circle2Putting", "ThrowInRate", "OBRate"))
                  ),
                  conditionalPanel(
                    condition = "input.plotType == 'Histogram'",
                    radioButtons("plotHistVar", "Choose Variable for Histogram", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                  "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                  "Circle2Putting", "ThrowInRate", "OBRate"))
                  ),
                  conditionalPanel(
                    condition = "input.plotType == 'Scatter Plot'",
                    checkboxGroupInput("plotScatVars", "Choose Variables for Scatter Plot", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                             "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                             "Circle2Putting", "ThrowInRate", "OBRate"))
                  ),
                  conditionalPanel(
                    condition = "input.plotType == 'Bar Plot'",
                    radioButtons("plotBarVar", "Choose Variable for Bar Plot", c("test1", "test2"))
                  )
                ),
                box(width = 4,
                  selectInput("tableType", "Select Table Type", choices = c("Numeric Summaries", "Contingency Table")),
                  conditionalPanel(
                    condition = "input.tableType == 'Numeric Summaries'",
                    checkboxGroupInput("tableVars", "Choose Variables to Summarize", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                          "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                          "Circle2Putting", "ThrowInRate", "OBRate")),
                    checkboxGroupInput("summaries", "Choose Summary Statistics", c("Mean", "Standard Deviation", "Minimum", "Median", "Maximum"))
                  ),
                  conditionalPanel(
                    condition = "input.tableType == 'Contingency Table'",
                    radioButtons("tableVar", "Choose Variable to Count Players Above Or Below a Certain Threshold", c("test1", "test2")),
                    sliderInput("countsCutoff", "Value to Cutoff At (In %)", min = 0, max = 100, value = 50)
                  )
                ),
                box(width = 4,
                  checkboxInput("filterPlotData", "Choose a Variable and Threshold to Filter Data For the Plot On"),
                  checkboxInput("filterTabData", "Choose a Variable and Threshold to Filter Data For the Summary Table On"),
                  conditionalPanel(
                    condition = "input.filterPlotData == 1",
                    radioButtons("filterPlotVar", "Variable to Filter the Plot On", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                "Circle2Putting", "ThrowInRate", "OBRate")),
                    sliderInput("filterPlotCutoff", "Value to Cutoff Plot Data At (In %)", min = 0, max = 100, value = 50),
                    radioButtons("filterPlotDirection", "Filter Plot Data that is Above or Below this Cutoff?", c("Above", "Below"))
                  ),
                  conditionalPanel(
                    condition = "input.filterTabData == 1",
                    radioButtons("filterTabVar", "Variable to Filter the Table On", list("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                         "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                         "Circle2Putting", "ThrowInRate", "OBRate")),
                    sliderInput("filterTabCutoff", "Value to Cutoff Table Data At (In %)", min = 0, max = 100, value = 50),
                    radioButtons("filterTabDirection", "Filter Table Data that is Above or Below this Cutoff?", c("Above", "Below"))
                  )
                ),
                box(
                  plotOutput("EDAPlot")
                ),
                box(
                  dataTableOutput("EDATable")
                )
              )
      ),
      
      tabItem(tabName = "modelSection",
        tabsetPanel(
          tabPanel("Modeling Info",
                      "Boooooop"
          ),
          tabPanel("Model Fitting",
                   "beeeeeep"
          ),
          tabPanel("Prediction",
                    "bam"
          )
        )
      ),
      
      tabItem(tabName = "dataSection",
        fluidPage(
              titlePanel("2022 Disc Golf Pro Tour Data Set"),
              mainPanel(
                box(width = 4,
                    checkboxInput("filterDT", "Choose a Variable and Threshold to Filter Data On"),
                    conditionalPanel(
                      condition = "input.filterDT == 1",
                      radioButtons("filterDTVar", "Variable to Filter On", c("test1", "test2")),
                      sliderInput("filterDTCutoff", "Value to Cutoff At (In %)", min = 0, max = 100, value = 50),
                      radioButtons("filterDTDirection", "Filter Data that is Above or Below this Cutoff?", c("Above", "Below"))
                    )
                ),
                dataTableOutput("dataTable"),
                downloadButton("downloadData", "Download")
                )
              )
      )
  )
)

dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Example Histogram"),
  sidebar,
  body
)
