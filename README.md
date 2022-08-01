# ST558 Final Project
## Josh Baber

### Description
This repo contains the .R files for running an app that analyzes data about disc golf from UDisc.  The data contains important disc golf statistics, such as putting percentages or putting percentages, for the top players on the Disc Golf Pro Tour.  The app allows its user to create graphs and summary tables with the data, to get a good understanding of it.  The user can also fit a Multiple Linear Regression model, a regression tree model, and a random forest model on the data.  The user also will see measures of each model's error so that they can compare and decide which one is the best.  This also helps in understanding which variables are the most important when it comes to prediction of the points a player has in the standings.  In other words, which disc golf statistics are the most important in determining how good a professional player is.  The user can select one of the three models to create a prediction.  They choose values for each statistic that is in the model, and predict how many Points a hypothetical player with those values has.  Lastly, the user can view the data in a table, subset it to their liking, and download it to their device as a CSV file.

### Packages

The following packages were used in the app:  

- [shiny](https://shiny.rstudio.com/) - to create shiny app with render functions, unique syntaxes, etc.
- [shinydashboard](https://rstudio.github.io/shinydashboard/) - provides a sidebar tab layout for the app and things like boxes for outputs and inputs.
- [DT](https://rstudio.github.io/DT/) - allows us to use the renderDataTable() and outputDataTable() functions when outputting data.
- [tidyverse](https://www.tidyverse.org/) - for easy data manipulation like filtering and GGplot for plotting
- [GGally](https://cran.r-project.org/web/packages/GGally/GGally.pdf) - for the ggpairs() function, which I use when making scatter plots
- [caret](https://topepo.github.io/caret/) - for fitting the three models, cross-validation, predicting, splitting test/training data, etc.
- [psych](https://cran.r-project.org/web/packages/psych/psych.pdf) - for the describe() function to easily get a summary statistics table.
- [rpart](https://cran.r-project.org/web/packages/rpart/rpart.pdf) - a dependency for the caret package to fit the regression tree.
- [rpart.plot](https://cran.r-project.org/web/packages/rpart.plot/rpart.plot.pdf) - for rpart.plot() to plot the regression tree.
- [randomForest](https://cran.r-project.org/web/packages/randomForest/randomForest.pdf) - a dependency for the caret package to fit the random forest model.

The following code can be ran to install all of these packages:

`install.packages(c("shiny", "shinydashboard", "DT", "tidyverse", "GGally", "caret", "psych", "rpart", "rpart.plot", "randomForest"))`

### Submit This Code To R Console After Installing Packages to Run The App

`shiny::runGitHub("JABaber/ST558-Final-Project", subdir = "DiscGolfApp/")`
