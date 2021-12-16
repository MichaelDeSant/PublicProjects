library(readxl)
library(dplyr)
library(magrittr)

#Read in input data
my.data = read.csv("input_data_team_12.csv", header=T)
my.data = my.data[,-1]


#Change to Factors
my.data[,"IsHoliday"] <- my.data[,"IsHoliday"] %>% as.factor()
my.data[,"Type"] <- my.data[,"Type"] %>%  as.factor()

#Partioninong data by hand for the our different time sequences
my.datatest <- my.data %>% slice(106:143)

my.datatrain <-  my.data %>% slice(1:105)


salests=ts(my.data[,("Store_sales")],frequency=52, start = c(2010,6), end=c(2012,43))
plot(salests)

salests_train = window(salests,frequency=52, start = c(2010,6),end = c(2012,6))
salests_train

salests_test = window(salests,frequency=52,start = c(2012,7))
salests_test



#neural net try

library(tidyverse)
library(tidymodels)
library(data.table)
library(tidyposterior)
library(tsibble)  #tsibble for time series based on tidy principles
library(fable)  #for forecasting based on tidy principles
library(ggfortify)  #for plotting timeseries
library(forecast)  #for forecast function
library(tseries)
library(chron)
library(lubridate)
library(directlabels)
library(zoo)
library(lmtest)
library(TTR)  #for smoothing the time series
library(MTS)
library(vars)
library(fUnitRoots)
library(lattice)
library(grid)

set.seed(34)


# Commented out plots for the knitted document becasue it causes errors when ploting when using some of the required packages for our NN model

fit = nnetar(salests_train)
nnetforecast <- forecast(fit, h = 37, PI = F)  #Prediction intervals do not come by default in neural net forecasts, in constrast to ARIMA or exponential smoothing model
nnetforecast
#plot(nnetforecast, main = "NeuralNet Model Forecast")
#lines(salests_test,col="red")
accuracy(fit)
accuracy(nnetforecast, salests_test)
checkresiduals(fit)

#With ex regs need to create ex reg data when forecasting

testreg <- matrix(c(my.datatest$IsHoliday,my.datatest$Temperature,my.datatest$Fuel_Price,my.datatest$CPI,my.datatest$Unemployment),nrow = 38,ncol=5, byrow = FALSE)
testreg

trainreg <- matrix(c(my.datatrain$IsHoliday,my.datatrain$Temperature,my.datatrain$Fuel_Price,my.datatrain$CPI,my.datatrain$Unemployment),nrow = 105,ncol=5, byrow = FALSE)
trainreg

## Using an external regressor in a neural net
fit2 = nnetar(salests_train,xreg=trainreg,scale.inputs = TRUE,repeats = 100)


# Defining the vector which we want to forecast
nnetforecast2 <- forecast(fit2, xreg = testreg, PI = TRUE)
#autoplot(nnetforecast2,main="Neural Net Model with External Regressors")
#lines(salests_test, col="red")
accuracy(fit2)
checkresiduals(fit2)

nnetforecast2

#Make CSV
ForecastData <- as.data.frame(nnetforecast2)
write.csv(ForecastData, file="NNforecastData.csv")


accuracy(nnetforecast2, salests_test)#RMSE 74315.44

