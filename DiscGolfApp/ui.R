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
                "In short, I was able to use ", tags$a("this data scraper Chrome extension", href = "https://chrome.google.com/webstore/detail/instant-data-scraper/ofaokhiedipichpaobibbnahnkdoiiah?hl=en-US"), " to grab the data from the UDisc webpage as a CSV file.  It took some cleaning to do, like dropping irrelevant columns, renaming the columns, and scaling them.  Most of the data is given as percentages with a % symbol, so I had to use lapply() to remove them and convert them from decimals for interpretation's sake.  Also, the total points each player had were not available on the 2022 Season Stats Webpage, so I had to go to the ", tags$a("2022 Season Standings Webpage", href = "https://www.udisclive.com/standings?d=MPO"), " to again scrape the data into a CSV.  I then performed a left join on the player's names in R to create the final data set.  An image of the 2022 Pro Tour Schedule can be found below:", br(), imageOutput("DGPT", inline = TRUE), br(), 
                h3("Explanation of Tabs"), br()
                
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
