#************************************************************************************
#title: "Integrated Factor Surveillance Avian Influenza Intelligence - Create clean and portable data for weekly reporting"
#author: "WHIP - C. Robertson"
#date: March 2018
#This report outlinings key environmental indicators in our Alberta and BC Study Regions. This is for the week ending 
#************************************************************************************

library("RPostgreSQL")
library("raster")
library("ggplot2")
library("ggmap")
library("plyr")
library("leaflet")
library("stringr")
library("rgdal")

#ENVRIONMENTAL SURVEILLANCE
#************************************************************************************
### Ebird observations in the reporting period
#************************************************************************************
# ALREADY DONE IN PROCESSING FOR WEEKLY - cleaned-ebird.csv
df2 <- read.csv("cleaned-ebird.csv", stringsAsFactors = FALSE)
df2$obsdt2 <- as.Date(df2$obsdt2, "%Y-%m-%d")
df2$week <- as.numeric(format(df2$obsdt2, "%w"))
o <- as.Date("2017-08-06", "%Y-%m-%d")
df2$weekNum <- 1 + as.integer(df2$obsdt2 - o - df2$week) %/% 7
write.csv(df2, "cleaned-ebird-app.csv")
#************************************************************************************
### Ebird observations in the reporting period
#************************************************************************************

#************************************************************************************
### Snow Cover 
#************************************************************************************
#These data represent recent counts of poultry slaughtered in Canada, obtained from AAFC
#snow ice data key
#0	Outside the coverage area
#1	Sea
#2	Land (without snow)
#3, 164 Sea Ice
#4, 165	Snow covered land
dateStart <- as.Date("08/06/2017", "%m/%d/%Y")   #Aug 6 2017 - starting date for monitoring period
dateEnd <- as.Date("02/03/2018", "%m/%d/%Y")     #Feb 3 2018 - ending date for monitoring period
weekNums <- seq(dateStart, dateEnd, by = 7)
weekStartJ <- as.numeric(format(weekNums, "%j"))
#tifInd <- grep("BC.*$", list.files("../data/snowice/processed"))

tifInd <- grep("AB.*$", list.files("../data/snowice/processed"))
tifInd <- list.files("../data/snowice/processed")[tifInd]

idx <- seq(1, length(tifInd)-5, by = 7)
for(i in 1:(length(weekStartJ))) {
  x <- raster(paste("../data/snowice/processed/",  tifInd[idx[i] + 1], sep=""))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 1], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 2], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 3], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 4], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 5], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 6], sep="/"))
  x <- max(x, na.rm = TRUE)
  #snow.df$snow[i] <- length(x[x ==4]) / length(!is.na(x[]))
  writeRaster(x, paste("../data/snowice/current_SM-AB-", i, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
  #writeRaster(srAB, paste("data/ndvi/current_SM-AB-", weekNum, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
}
#************************************************************************************
### Snow Cover 
#************************************************************************************
#************************************************************************************
### SM 
#************************************************************************************
region <- "BC"
for(week in 32:52) {
  f <- paste("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/soilmoisture/current_SM-", region, "-", week, "-.tif", sep="")
  r <- raster(f)
  r <- projectRaster(r, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  writeRaster(r, paste("apps/report-dashboard/data/SM/current_SM-BC-", week, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
}

#************************************************************************************
### NDVI 
#************************************************************************************
region <- "AB"
for(week in 40:44) {
  f <- paste("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/ndvi/current_SM-", region, "-", week, "-.tif", sep="")
  r <- raster(f)
  r <- projectRaster(r, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  writeRaster(r, paste("apps/report-dashboard/data/NDVI/current_SM-AB-", week, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
}


#************************************************************************************
### Temperature 
#************************************************************************************

df <- dbGetQuery(con, "SELECT * from wu_ab")

df$obsdt2 <- as.Date(df$subdate, "%Y-%m-%d")
df2 <- subset(df, obsdt2 >= dateStart & obsdt2 <= dateEnd)
#missingDates <- seq(dateStart, dateEnd, 1)[which(!seq(dateStart, dateEnd, 1) %in% df2$obsdt)]
df2$week <- as.numeric(format(df2$obsdt2, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df2$weekNum <- 1 + as.integer(df2$obsdt2 - o - df2$week) %/% 7

dfSum <- ddply(df2, "weekNum", summarise, highs = median(temperaturehighc, na.rm=TRUE), lows = median(temperaturelowc, na.rm=TRUE), avg = median(temperatureavgc, na.rm=TRUE), dewpoint = median(dewpointavgc), humidity = median(humidityavg), precip = median(precipsumcm, na.rm = TRUE))
dfSum$region <- "AB"

df <- dbGetQuery(con, "SELECT * from wu_bc")

df$obsdt2 <- as.Date(df$subdate, "%Y-%m-%d")
df2 <- subset(df, obsdt2 >= dateStart & obsdt2 <= dateEnd)
#missingDates <- seq(dateStart, dateEnd, 1)[which(!seq(dateStart, dateEnd, 1) %in% df2$obsdt)]
df2$week <- as.numeric(format(df2$obsdt2, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df2$weekNum <- 1 + as.integer(df2$obsdt2 - o - df2$week) %/% 7

dfSum2 <- ddply(df2, "weekNum", summarise, highs = median(temperaturehighc, na.rm=TRUE), lows = median(temperaturelowc, na.rm=TRUE), avg = median(temperatureavgc, na.rm=TRUE), dewpoint = median(dewpointavgc), humidity = median(humidityavg), precip = median(precipsumcm, na.rm = TRUE))
dfSum2$region <- "BC"
df <- rbind(dfSum, dfSum2)
write.csv(df, "data/temperature-shiny.csv")


#WEB SIGNAL SURVEILLANCE
#************************************************************************************
### AI TWEET observations in the reporting period
#************************************************************************************
dateStart <- as.Date("08/06/2017", "%m/%d/%Y")   #Aug 6 2017 - starting date for monitoring period
dateEnd <- as.Date("02/03/2018", "%m/%d/%Y")     #Feb 3 2018 - ending date for monitoring period

## Social Media Summary
### AI-related Tweets During the Reporting Period
# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "whsc",host = "localhost", port = 5432, user = "postgres")
#
query <- "select tweetDate, tweettext, location, url from tweets"
df <- dbGetQuery(con, query)
df <- subset(df, tweetdate >= dateStart & tweetdate <= dateEnd)
df$week <- as.numeric(format(df$tweetdate, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df$weekNum <- 1 + as.integer(df$tweetdate - o - df$week) %/% 7
write.csv(df, "data/tweets-shiny.csv")

## Poultry Site Headlines
### Poultry Site Headlines - current and historical

df1 <- read.csv("data/AI-poultrysite.csv", stringsAsFactors = FALSE)
df2 <- read.csv("data/AI-poultrysite-3.csv", stringsAsFactors = FALSE)
df3 <- read.csv("data/AI-poultrysite-current.csv", stringsAsFactors = FALSE)
dff <- rbind(df1, df2, df3)
dff$Date <- as.Date(dff$newDates, "%A, %B %d, %Y")
dff$snips <- str_replace_all(dff$snips, "—", "-")
dff$snips <- str_replace_all(dff$snips, "\n", "")
dff$Location <- str_sub(dff$snips, 1, str_locate(dff$snips, "-")[,1]-2)
dff$Location[which(str_detect(dff$Location, ","))] <- str_sub(dff$Location[which(str_detect(dff$Location, ","))], 1, str_locate(dff$Location[which(str_detect(dff$Location, ","))], ",")[,1]-1)
dff$wellFormed <- FALSE
dff$wellFormed[which(nchar(dff$Location) < 20)] <- TRUE
dff$wellFormed[str_detect(dff$Location, "&")] <- FALSE
dff$week <- as.numeric(format(dff$Date, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
dff$weekNum <- 1 + as.integer(dff$Date - o - dff$week) %/% 7

write.csv(dff, "data/ps-clean.csv")
dff <- read.csv("data/ps-clean.csv")
library("geonames")
options(geonamesUsername="colinr23")
dfx <- subset(dff, wellFormed == TRUE) #dropping 197 crazy formatted one
GNsearchx <- function(x) {
  res <- GNsearch(name=x)
  #Sys.sleep(2)
  return(res[1, ])
}
#hist(nchar(dfx$Location))
# loop over city names and reformat
uniqueLocales <- unique(dfx$Location)
GNresult <- sapply(uniqueLocales, GNsearchx)
GNfound <- GNresult[which(lengths(GNresult) == 15)]
GNresult1 <- do.call("rbind", GNfound)
options(stringsAsFactors = FALSE)
GNresult2 <- cbind(Location=row.names(GNresult1), subset(GNresult1, select=c("lng", "lat", "adminName1")))
dfG <- merge(dfx, GNresult2, by.x = "Location", by.y = "Location", all.x = TRUE)
write.csv(dfG, "data/ps-g.csv")

#AUTHORITATIVE SURVEILLANCE
#************************************************************************************
### AI TWEET observations in the reporting period
#************************************************************************************
dfa <- read.csv("data/AIV-WHIP.csv")
dfa <- dfa[,c(1:9, 12)]
dfa <- dfa[-which(dfa$Matrix.PCR.Result.Date == ""), ]
dfa$PCRResultDate <- as.Date(dfa$Matrix.PCR.Result.Date, "%Y-%m-%d")
dfa <- dfa[dfa$PCRResultDate >= as.Date("2017-08-06", "%Y-%m-%d"),]
dfa$week <- as.numeric(format(dfa$PCRResultDate, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
dfa$weekNum <- 1 + as.integer(dfa$PCRResultDate - o - dfa$week) %/% 7
write.csv(dfa, "data/aiv.csv")
