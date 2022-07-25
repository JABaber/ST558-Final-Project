# ST558 Final Project (UI Side)
# Josh Baber
# shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")

library(shiny)
library(shinydashboard)
library(DT)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "aboutSection"),
    menuItem("Data Exploration", tabName = "EDASection"),
    menuItem("Modeling", tabName = "modelSection"),
    menuItem("Data", tabName = "dataSection")
  )
)

# Define UI for application that draws a histogram
body <- dashboardBody(
    tabItems(
      
      ################################################################################################################################################
      
      
                                                                         # About Page
      
      
      ################################################################################################################################################
      
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
                
                
                "In short, I was able to use ", tags$a("this data scraper Chrome extension", href = "https://chrome.google.com/webstore/detail/instant-data-scraper/ofaokhiedipichpaobibbnahnkdoiiah?hl=en-US"), " to grab the data from the UDisc webpage as a CSV file.  It took some cleaning to do, like dropping irrelevant columns, renaming the columns, and scaling them.  Most of the data is given as percentages with a % symbol, so I had to use lapply() to remove them and convert them from decimals since whole numbers are easier to interpret.  Also, the total points each player had were not available on the 2022 Season Stats Webpage, so I had to go to the ", tags$a("2022 Season Standings Webpage", href = "https://www.udisclive.com/standings?d=MPO"), " to again scrape the data into a CSV.  I then performed a left join on the player's names in R to create the final data set.  The code to create the data set can be found", tags$a("here.", href = "https://github.com/JABaber/ST558-Final-Project/blob/main/DiscGolfDataCleaning.Rmd"),  "An image of the 2022 Pro Tour Schedule can be found below:", br(), imageOutput("DGPT", inline = TRUE), br(), 
                
                h3("Explanation of Tabs"), br(),
                h5("Data Exploration Tab"), br(),
                h5("Modeling Tab"), br(),
                h5("Data Tab")
              )
      ),
      
      ################################################################################################################################################
      
      
                                                                          # EDA Page
      
      
      ################################################################################################################################################
      
      tabItem(tabName = "EDASection",
              fluidRow(
                box(width = 4,
                  selectInput("plotType", "Select Plot Type", choices = c("Box Plot", "Histogram", "Scatter Plot")),
                  conditionalPanel(
                    condition = "input.plotType == 'Box Plot'",
                    radioButtons("plotBoxVar", "Choose Variable for Box Plot", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                              "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                              "Circle2Putting", "ThrowInRate", "OBRate", "Points"))
                  ),
                  conditionalPanel(
                    condition = "input.plotType == 'Histogram'",
                    radioButtons("plotHistVar", "Choose Variable for Histogram", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                  "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                  "Circle2Putting", "ThrowInRate", "OBRate", "Points")),
                    numericInput("bins", "Set Number of Bins", value = 30)
                  ),
                  conditionalPanel(
                    condition = "input.plotType == 'Scatter Plot'",
                    checkboxGroupInput("plotScatVars", "Choose Variables for Scatter Plot", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                             "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                             "Circle2Putting", "ThrowInRate", "OBRate", "Points"),
                                       selected = c("Circle1XPutting", "Points"))
                  )
                ),
                box(width = 4,
                    checkboxGroupInput("tableVars", "Choose Variables to Summarize In Table (Choose At Least 2)", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                          "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                          "Circle2Putting", "ThrowInRate", "OBRate", "Points"),
                                       selected = c("Birdie", "Circle1XPutting")),
                    checkboxGroupInput("summaries", "Choose Summary Statistics", choiceNames = c("Mean", "Standard Deviation", "Minimum", "Median", "Maximum"),
                                       choiceValues = c("mean", "sd", "min", "median", "max"),
                                       selected = c("mean", "sd", "min", "median", "max"))
                ),
                box(width = 4,
                    checkboxInput("filterPlotData", "Filter Players Based on Rank in Plot", value = FALSE),
                    checkboxInput("filterTabData", "Filter Players Based on Rank in Summaries", value = FALSE),
                    conditionalPanel(
                      condition = "input.filterPlotData == 1",
                      numericInput("filterPlotRank", "Select Top X Players for Plot", value = 420, min = 1, max = 420),
                    ),
                    conditionalPanel(
                      condition = "input.filterTabData == 1",
                      numericInput("filterTabRank", "Select Top X Players for Summaries", value = 420, min = 1, max = 420)
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
      
      ################################################################################################################################################
      
      
                                                                       # Modeling Page
      
      
      ################################################################################################################################################
      
      tabItem(tabName = "modelSection",
        tabsetPanel(
          tabPanel("Modeling Info",
                      h1("About the Models"), br(),
                   "There are three different types of models that the user will be able to fit on the data.  Not only this, but they will be able to select certain rules for fitting the model as well as which variables to use.  The user will at the end be able to use their fitted model to predict a set of new data that they provide.  The three models that we are going to fit are", strong("a Multiple Linear Regression, a Regression Tree, and a Random Forest."), "I will describe them in more detail below:",
                   tags$ul(
                     tags$li(strong("Multiple Linear Regression"), "- uses a linear combination of predictors in an equation to predict the response variable, which is a continuous numeric variable.", strong("insert equation here"), "the values for these coefficients are found using linear algebra to find the solution of Beta values that minimize the sum of squared residuals.", strong("insert next equation here"), "These beta coefficients can be interpreted as the change in the response value for a one unit increase in the predictor x.  Multiple Linear Regression can also feature polynomial and interaction terms.  A polynomial term is simply when we raise a predictor's x value in that equation to some power other than 1.  An interaction term takes the product of two Xs (predictors) and finds a beta coefficient for that product.  This complicates the interpretation a bit, but essentially the beta represents the change in the response variable when we increase the product of two predictors by 1, which represents the effect they have on each other as well as the response.  The Multiple Linear Regression model is usually quick to solve with a computer and is one of the older prediction models around.  It has plenty of extensions that can improve prediction power or predictor selection.  The major downside of this type of model is that they require some pretty strong assumptions to be made about the data, most of which are usually not true.  These assumptions include having normally distributed errors with equal variances across all values of independent variables and a lack of collinearity (or correlation) between predictors.  Most of the time, these are stretches to assume, but when it is relatively safe to assume they are true, or it can be proven, the Multiple Linear Regression model can be a great, somewhat easy to interpret choice."),
                     tags$li(strong("Regression Tree"), "- evalutates at every possible value of each predictor and performs some measure of error, usually the Residual Sum of Squares like in Multiple Linear Regression.  It chooses the value that minimizes the error and creates a split there.  A split essentially just divides the data into two groups, and the algorithm again will continue to look for splits in these groups based on the predictors and so on.  Many splits may be done, leading to many branches for the data to fall into.  The Regression Tree model will eventually create too many of these branches, which can lead to overfitting.  This essentially makes the model really good at predicting for the data that it was trained on, but really bad at predicting new data.  The model then prunes itself back to a reasonable amount of splits/branches.  The statistician fitting these models can decide how many groups they want in the end, which determines how far the model prunes itself back.  An advantage of the Regression Tree is that it is super easy to interpret, you just follow the line for a data point down the branches to a prediction.  The first few splits usually make sense intuitively as well.  They are also pretty quick to fitting with a computer.  The major disadvantage of these models is that they can be heavily biased towards the data they were trained on.  Small changes in the data may lead to huge differences in splits.  They might create a few splits, and those splits are good for the data they used but not for new data.  They also suffer heavily from collinearity between predictors.  If two or more predictors are highly correlated, they might create bad splits or lead to less information obtained from the data, however, this will not affect prediction as much."),
                     tags$li(strong("Random Forest"), "- is essentially an average of many, many regression trees.  It creates random (bootstrapped) samples from the data and fits a tree to each of these samples.  It then averages across all of these trees to find optimal splits that are more reliable and less variant than had a single tree been fit.  When predicting, the Random Forest model predicts the mean of predictions across all models.  The Random Forest, however, does one more major step.  Had it used the process I just described, if there existed a really strong predictor then many of the trees would create an early split using the predictor at similar values.  This can result in an omission of much of the information that comes from the other predictors, since they won't be as likely to get a split.  The Random Forest circumvents this by randomly subsetting the predictors every time it fits a tree.  The statistician fitting the model is responsible for deciding how many predictors to use each time, or may use cross-validation to decide.  The advantage of this is that it can get more even splits for prediction, largely avoiding collinearity.  This leads to better overall predictions with fewer assumptions compared to the Multiple Linear Regression model.  However, this process can take an extremely long time to run, especially with cross-validation.  For large data sets that have tons of observations and tons of predictors, this may end up taking too long to fit.")
                   )
          ),
          
          tabPanel("Model Fitting",
                   fluidRow(
                     box(width = 3,
                         h3("Universal Model Settings"),
                         sliderInput("dataSplit", "Select Proportion of Data To Send to the Training Set", min = 0.5, max = 0.95, value = 0.8),
                         sliderInput("folds", "Select How Many Folds to Use for Cross Validation", min = 1, max = 10, value = 5)
                         ),
                     box(width = 3,
                         h3("MLR Settings"),
                         checkboxGroupInput("MLRVars", "Select the Variables To Use In MLR Model", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                                     "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                                     "Circle2Putting", "ThrowInRate", "OBRate")),
                         checkboxInput("interaction", "Include Interaction Terms in Model?", value = FALSE)
                         
                         ),
                     box(width = 3,
                         h3("Regression Tree Settings"),
                         checkboxGroupInput("treeVars", "Select the Variables To Use In the Tree Model", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                                     "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                                     "Circle2Putting", "ThrowInRate", "OBRate")),
                         h5("Adjust the Complexity Parameter Values to Try"), br(),
                         "This determines how much improvement is need in the error at each node.  It essentially controls how many nodes the model has at the end.  We can choose a range of values to try and cross-validation will help us choose the best one.  The inputs below are min, max, and step size.  For example, if min = 0, max = 0.1, and step size = 0.001.  It will try values 0, 0.001, 0.002, 0.003, ..., 0.098, 0.099, 0.1.",
                         numericInput("cpMin", "Set Minimum cp Value to Try", value = 0),
                         numericInput("cpMax", "Set Maximum cp Value to Try", value = 0.1),
                         numericInput("cpStep", "Set cp Step Size", value = 0.001)
                         
                         ),
                     box(width = 3,
                         h3("Random Forest Settings"),
                         checkboxGroupInput("rfVars", "Select the Variables To Use In the Tree Model", c("Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                                          "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting"                                                                                                           , "Circle2Putting", "ThrowInRate", "OBRate")),
                         h5("Adjust the Parameter That Determines the Number of Variables To Randomly Subset To"), br(),
                         "We can again use cross-validation to help us determine how many variable to subset to (m).  We can choose a range of values to try from our 12 predictors.",
                         numericInput("mMin", "Set Minimum m Value to Try", value = 1),
                         numericInput("mMax", "Set Maximum cp Value to Try", value = 12)
                         )
                   ),
                   actionButton("fit", "Click Here When Ready To Fit Models"), br(),
                   "Put Progress Bar Here"
          ),
          tabPanel("Prediction",
                    fluidRow(
                      box(width = 4,
                          radioButtons("predModel", "Choose A Model To Use For Prediction", c("Multiple Linear Regression", "Regression Tree", "Random Forest")),
                          ), br(),
                      "Choose Predictor Values"
                    )
          )
        )
      ),
      
      ################################################################################################################################################
      
      
                                                                         # Data Page
      
      
      ################################################################################################################################################
      
    
      tabItem(tabName = "dataSection",
        fluidRow(
                box(width = 4,
                    checkboxInput("filterDT", "Filter Players Based on Rank", value = FALSE),
                    conditionalPanel(
                      condition = "input.filterDT == 1",
                      numericInput("filterDTRank", "Select Top X Players", value = 420, min = 1, max = 420)
                      ),
                    ),
                box(width = 4,
                    checkboxGroupInput("DTVars", "Choose Columns To View/Save", choices = c("Place", "Name", "Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                                                            "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                                                            "Circle2Putting", "ThrowInRate", "OBRate", "Points"),
                                       selected = c("Place", "Name", "Birdie", "Par", "Bogey", "Fairway", "Parked", 
                                                    "Circle1InReg", "Circle2InReg", "Scramble", "Circle1XPutting", 
                                                    "Circle2Putting", "ThrowInRate", "OBRate", "Points"))
                    )
                ),
                dataTableOutput("dataTable"),
                downloadButton("downloadData", "Download")
      )
  )
)

dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Disc Golf Data App"),
  sidebar,
  body
)
