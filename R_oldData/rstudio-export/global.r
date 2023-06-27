# 1. specify packages you need
# 2. load any data required for all sessions
list.of.packages <- c(
  "dplyr", 
  "formattable",
  "ggplot2",
  "shiny",
  "shinydashboard",
  "shinyscreenshot",
  "shinyWidgets",
  "stringr",
  "utils",
  "rsconnect",
  "shinyjs",
  "reshape2",
  "shinyjqui",
  "rintrojs",
  "shinycssloaders"
  )
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(dplyr)
library(formattable)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(shinyscreenshot)
library(shinyWidgets)
library(stringr)
library(utils)
library(rsconnect)
library(shinyjs)
library(reshape2)
library(shinyjqui)
library(rintrojs)
library(shinycssloaders)

remove.packages(c("ggplot2", "data.table"))
install.packages('Rcpp', dependencies = TRUE)
install.packages('ggplot2', dependencies = TRUE)
install.packages('data.table', dependencies = TRUE)

###look back over new all answers report and see what else you want to grab from it
Raw <- read.csv("Raw Data.csv")
SubsetAA <- function (Raw){
  plotTable <- cbind(Raw$Experiment.Id,
                     Raw$Experiment.Name,
                     Raw$Block.Id,
                     Raw$Question.Code,
                     Raw$Secondary.Answer.1,
                     Raw$Secondary.Answer.2,
                     Raw$Secondary.Answer.3,
                     Raw$Secondary.Answer.4,
                     Raw$Secondary.CSV,
                     Raw$Treatment.Number,
                     Raw$Treatment.Id,
                     Raw$Variable.1.Condensed,
                     Raw$Entity.Type.Code,
                     Raw$Value,
                     Raw$Uom.Code,
                     Raw$Overall.Deactivated.Status
  )
  plotTable <- data.frame(plotTable)
  colnames(plotTable) <- c(
    "experimentID",
    "experimentName",
    "blockID",
    "questionCode",
    "secondary1",
    "secondary2",
    "secondary3",
    "secondary4",
    "secondaryCombined",
    "treatmentNumber",
    "treatmentID",
    "fullTreatment",
    "entityType",
    "value",
    "uom",
    "deactivated"
  )
  
  #remove deactivated values
  plotTable<-plotTable[plotTable$deactivated != "TRUE", ] 
  
}

  
Cleanup <- function(Raw){
CS <- Raw$fullTreatment
CS <- data.frame(CS)
#changing the name of the column so when Envision keeps changing it, it is one fix. 
colnames(CS) <- "CS"

CS$CS <- gsub("\n","", CS$CS)
#beautifying treatment list
#realizing that single treatments have a carriage return at every column -.-
#right now mix size can work, but need to find a longer term solution
CHEM<- str_split_fixed(CS$CS, "Fungicide",4)
CHEM <- CHEM[,-1]
CHEM <- data.frame(CHEM)

# .* means 'before' or 'after' the pattern you are giving
CHEM$X1 <- sub("Application Rate.*","",CHEM$X1)
CHEM$X1 <- gsub(",","",CHEM$X1)
CHEM$X1 <- gsub(" ","",CHEM$X1)
CHEM$X2 <- sub("Application Rate.*","",CHEM$X2)

CHEM <- sapply(CHEM, as.character)
CHEM <- data.frame(CHEM)

#creating rate column
RATE<- str_split_fixed(CS$CS, "Fungicide",5)
RATE<-RATE[,-1]
RATE <- data.frame(RATE)
RATE <- RATE$X1

RATE <- str_extract(RATE, "(?<=(ppm)).*(?=Timing)")
RATE <- gsub(",","",RATE)
RATE <- gsub(")","",RATE)
RATE <- gsub(" ","",RATE)
RATE <-as.data.frame(RATE)

shortTreatmentName <- paste(CHEM$X1,"@",RATE$RATE,"ppm")
shortTreatmentName <- as.data.frame(shortTreatmentName)
shortTreatmentName <- mutate_if(shortTreatmentName, 
                                is.character, 
                                str_replace_all, 
                                pattern = "No @ No ppm", 
                                replacement = "Untreated Control")
Raw$value <- as.numeric(Raw$value)
plotTable<-cbind(Raw,shortTreatmentName)
plotTable<-plotTable %>% filter(entityType == "SET_ENTRY")
}

#Means <- read.csv("Means Report.csv")

Means <- function(Means){
Means <- cbind(Means$Experiment.Id, 
                Means$Block.Id, 
                Means$Factor.1.Treatment, 
                Means$Value, 
                Means$Equality.Groups, 
                Means$Factor.1.Condensed.String)
Means <- as.data.frame(Means)
colnames(Means) <- c("experimentID",
                     "blockID",
                     "treatmentNumber",
                     "value", 
                     "letterGrouping", 
                     "fullTreatment")
  CS <- Means$fullTreatment
  CS <- data.frame(CS)
  #changing the name of the column so when Envision keeps changing it, it is one fix. 
  colnames(CS) <- "CS"
  
  CS$CS <- gsub("\n","", CS$CS)
  #beautifying treatment list
  #realizing that single treatments have a carriage return at every column -.-
  #right now mix size can work, but need to find a longer term solution
  CHEM<- str_split_fixed(CS$CS, "Fungicide",4)
  CHEM <- CHEM[,-1]
  CHEM <- data.frame(CHEM)
  
  # .* means 'before' or 'after' the pattern you are giving
  CHEM$X1 <- sub("Application Rate.*","",CHEM$X1)
  CHEM$X1 <- gsub(",","",CHEM$X1)
  CHEM$X1 <- gsub(" ","",CHEM$X1)
  CHEM$X2 <- sub("Application Rate.*","",CHEM$X2)
  
  CHEM <- sapply(CHEM, as.character)
  CHEM <- data.frame(CHEM)
  
  #creating rate column
  RATE<- str_split_fixed(CS$CS, "Fungicide",5)
  RATE<-RATE[,-1]
  RATE <- data.frame(RATE)
  RATE <- RATE$X1
  
  RATE <- str_extract(RATE, "(?<=(ppm)).*(?=Timing)")
  RATE <- gsub(",","",RATE)
  RATE <- gsub(")","",RATE)
  RATE <- gsub(" ","",RATE)
  RATE <-as.data.frame(RATE)
  
  shortTreatmentName <- paste(CHEM$X1,"@",RATE$RATE,"ppm")
  shortTreatmentName <- as.data.frame(shortTreatmentName)
  shortTreatmentName <- mutate_if(shortTreatmentName, 
                                  is.character, 
                                  str_replace_all, 
                                  pattern = "No @ No ppm", 
                                  replacement = "Untreated Control")
  Means$value <- as.numeric(Means$value)
  plotTable<-cbind(Means,shortTreatmentName)
}

MyColour <- c("#00617F", "#66B512", "#D30F4B") 
names(MyColour) <- c("Test", "Positive Control", "Negative Control")
 