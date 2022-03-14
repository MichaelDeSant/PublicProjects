#The following is a data cleaning process attempting to output a data set with three distinct ground combat programs (Abrams, Bradley, and Stryker)

mydata <- read.csv("ground_vehicles_full.csv")
mydata

#Dependencies
library(dplyr)
library(tidyverse)
library(stringr)

#Pain Point 1 Solution (Standardizing Names)
#This function can be used to replace problematic vendor names with something more standard Ex. General Dynamics
mydata<- mydata %>%
  #filter(grepl('General Dynamics',Vendor..Top.Name)) %>%
  mutate(Vendor..Top.Name = str_replace_all(Vendor..Top.Name, 'General Dynamics Corporation','General Dynamics Corp.'))

# Filter out 2021 from the data (We only want these 5 years)

mydata <- filter(mydata,Fiscal.Year %in% c(2016,2017,2018,2019,2020))

#Select the two GCS programs that are more clearly identifiable through their titles
#ABRAMS TANKS
AbramsData <- mydata %>% 
  filter(grepl('M1A1|M1 ABRAMS',Title))

AbramsData <- cbind(identify='Abrams',AbramsData)

#Bradley fighting vehicle
BradleyData <- mydata %>% 
  filter(grepl('BRADLEY FIGHTING VEHICLE|BFV',Title))

BradleyData <- cbind(identify='Bradley',BradleyData)

# The methodology here is I'm making the assumption that PSC skews for the M1A1 are representative of the skews across each of the other GCS programs
# Basically we take the PSCs for the M1A1 and BFV and filter on those to solve the unique issue with Stryker vehicles
# The issue being that many unwanted transactions appear when we search by title using 'Stryker'

# Search for PSC Skews relevant to GCS 
PSCValues <- unique(AbramsData$PSC.Name)

PSCValues2 <- unique(BradleyData$PSC.Name)

PSCValues <- union(PSCValues,PSCValues2)

#This process could be run again in combination with other features fairly easily like contracting agency for example in order to further weed out potential outliers

AgencyValues <- unique(AbramsData$Contracting.Agency)

AgencyValues2 <- unique(BradleyData$Contracting.Agency)

AgencyValues <- union(AgencyValues,AgencyValues2)

PSCData<- mydata %>%
  filter(PSC.Name %in% PSCValues) %>%
  filter(Contracting.Agency %in% AgencyValues)

#PAIN POINT 2: How do we remove unwanted transactions from the query
# TotalValues <- unique(mydata$PSC.Name)
# Interested <- setdiff(union(mydata,PSCData),intersect(mydata,PSCData))
# ^ These are the PSCs and contracting agencies that we should look into that could be non-GCS related

#Stryker Data
StrykerData<- PSCData %>%
  filter(grepl('STRYKER',Title))

StrykerData <- cbind(identify='Stryker',StrykerData)


CombinedData <- rbind(AbramsData,StrykerData,BradleyData)


write.csv(CombinedData,"C:\\Users\\Michael\\Downloads\\GSCDataFinal.csv", row.names = FALSE)


#Solution for NA's in Award Column
#M1A1data[is.na(M1A1data)] <- 0
#NewFrame <- M1A1data



# Testing out Visualizations:

#barchart of awarded amount/ year
library(ggplot2)
BarchartData <- mydata %>%
  group_by(Fiscal.Year) %>%
  summarise(Awarded.Amount = sum(Awarded.Amount))

p <- ggplot(data=BarchartData, aes(x=Fiscal.Year, y=Awarded.Amount)) +
  geom_bar(stat="identity")

p

#distribution of PSC titles and by year
PscData <- AbramsData %>%
  count(PSC.Name)

d <- ggplot(data = PscData, aes(y=PSC.Name, x=n)) +
  geom_bar(stat="identity")

d


#Most common titles in the data
TitleData <- M1A1data %>%
  count(Title)

l <- ggplot(data = TitleData, aes(y=n, x=Title)) +
  geom_bar(stat="identity")

l

