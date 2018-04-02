#************************************************************************************
#title: "Integrated Factor Surveillance Avian Influenza Intelligence - Matrix Analysis Data"
#author: "WHIP - C. Robertson"
#date: Feb 2018
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

dateStart <- as.Date("08/06/2017", "%m/%d/%Y")   #Aug 6 2017 - starting date for monitoring period
dateEnd <- as.Date("02/03/2018", "%m/%d/%Y")     #Feb 3 2018 - ending date for monitoring period
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/reports")
weekNums <- seq(dateStart, dateEnd, by = 7)
#print("tbd")
region <- "AB" #"AB" #bc

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "whsc",host = "localhost", port = 5432, user = "postgres")

#************************************************************************************
## Environmental Summary to create factors for matrix analysis 
#************************************************************************************


#************************************************************************************
### Ebird observations in the reporting period
#************************************************************************************

# #
# query <- "select locname, howmany, obsdt, sciname, comname, st_x(o.geom) x, st_y(o.geom) y from ebird o"
 df <- dbGetQuery(con, query)
# 
# #figure out the order of each species -- iteratively doing more screwed up entries
# specs <- unique(df$sciname)
# specs$uniqueID <- 1:nrow(specs)
# taxnm <- tax_name(query = specs, get = c("species", "genus", "family", "order"), db = "ncbi")
# taxnm2 <- cbind(specs[-which(is.na(taxnm$order))], taxnm[-which(is.na(taxnm$order)),])
# noMatch <- specs[which(is.na(taxnm$order))]
# noMatch1 <- data.frame(str_split_fixed(noMatch, " ", n=2))
# noMatch1$X1 <- as.character(noMatch1$X1)
# taxnm3 <- tax_name(query = noMatch1$X1, get = c("species", "genus", "family", "order"), db = "ncbi")
# taxnm4 <- cbind(noMatch[-which(is.na(taxnm3$order))], taxnm3[-which(is.na(taxnm3$order)),])
# names(taxnm4)[1] <- "E-Species"
# names(taxnm2)[1] <- "E-Species"
# finalEBS <- rbind(taxnm2, taxnm4)
#  df <- merge(df, finalEBS, by.x = "sciname", by.y = "E-Species", all.x = TRUE)
# # 
# srptsCRS <- proj4string(readOGR('../data/basemap', "study-sites-pts2"))
# sr <- readOGR('../data/basemap', "study-sites")
# sr <- spTransform(sr, srptsCRS)
# coordinates(df) <- ~x + y
# proj4string(df) <- srptsCRS
# 
# srBC <- sr
# inside.poly <- !is.na(over(df, as(srBC, "SpatialPolygons")))
# df <- df[inside.poly, ]
# # 
# 
# df$obsdt2 <- as.Date(str_sub(df$obsdt, 1, 10), "%Y-%m-%d")
# df2 <- subset(df, obsdt2 >= dateStart & obsdt2 <= dateEnd)
# df2 <- subset(df2, order == "Anseriformes" | order == "Charadriiformes")
# df2$region <- ""
# df2$region[!is.na(over(df2, as(sr[2,], "SpatialPolygons")))] <- "BC"
# df2$region[!is.na(over(df2, as(sr[1,], "SpatialPolygons")))] <- "AB"
# df2$X <- coordinates(df2)[,1]
# df2$Y <- coordinates(df2)[,2]
# write.csv(df2@data, "cleaned-ebird.csv")
df2 <- read.csv("cleaned-ebird.csv", stringsAsFactors = FALSE)



df2$obsdt2 <- as.Date(str_sub(df2$obsdt, 1, 10), "%Y-%m-%d")
df2$week <- as.numeric(format(df2$obsdt2, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df2$weekNum <- 1 + as.integer(df2$obsdt2 - o - df2$week) %/% 7

dfSum <- ddply(df2, c("weekNum", "region"), summarise, Number = sum(howmany, na.rm=TRUE), Sightings = length(howmany), .drop = FALSE)

#ggplot(subset(dfSum, region == "AB"), aes(x = weekNum, y = Sightings)) + geom_point() + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth()
#ggplot(subset(dfSum, region == "BC"), aes(x = weekNum, y = Sightings)) + geom_point() + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth()
write.csv(subset(dfSum, region == "AB"), "cleaned-ebird-weekly-AB.csv")
write.csv(subset(dfSum, region == "BC"), "cleaned-ebird-weekly-BC.csv")


#************************************************************************************
### Soil Moisture Anomaly 
#************************************************************************************
tifIndBC <- grep("BC-[0-9][0-9]-.tif$", list.files("../data/soilmoisture"))
tifIndAB <- grep("AB-[0-9][0-9]-.tif$", list.files("../data/soilmoisture"))

SM.df <- data.frame(weekNum = 1:26, SMFlag = 0, SMRating = 0, Low = 0, Med = 0, High = 0, Region = "BC")
for(xi in 1:length(tifIndAB)) {
  fname <- list.files("../data/soilmoisture")[tifIndBC[xi]]
  weekNum <- str_sub(fname, 15, 16)
  weekNum <- as.numeric(weekNum)
  if(weekNum < 10) { weekNum <- weekNum + 52}
  weekNum <- weekNum - 31
  rp <- paste("../data/soilmoisture", fname, sep="/")
  x <- raster(rp)
  if(length(which(!is.na(x[]))) / ncell(x) > 0.10) { SM.df$SMFlag[weekNum] = 1}
  if(SM.df$SMFlag[weekNum] == 1) {
    SM.df$Low[weekNum] <- length(which(x[] < -5)) / length(which(!is.na(x[])))
    SM.df$Med[weekNum] <- length(which(x[] >= -5 & x[] <= 5)) / length(which(!is.na(x[])))
    SM.df$High[weekNum] <- length(which(x[] > 5)) / length(which(!is.na(x[])))
  }
  
}
write.csv(SM.df, "SM-data-AB.csv")

#************************************************************************************
### NDVI Map
#These are NDVI anomalies for this week. The AAFC NDVI Anomaly Maps comparee a given week’s NDVI value to a baseline value, which allows any outlier values to be visually compared to average values. High positive indicates greener than average vegetation conditions. 
#************************************************************************************ 
tifIndBC <- grep("BC-[0-9][0-9]-.tif$", list.files("../data/ndvi"))
tifIndAB <- grep("AB-[0-9][0-9]-.tif$", list.files("../data/ndvi"))

SM.df <- data.frame(weekNum = 1:26, NDVIFlag = 0, NDVIRating = 0, Low = 0, Med = 0, High = 0, Region = "BC")
for(xi in 1:length(tifIndBC)) {
  fname <- list.files("../data/ndvi")[tifIndBC[xi]]
  weekNum <- str_sub(fname, 15, 16)
  weekNum <- as.numeric(weekNum)
  #if(weekNum < 32) { weekNum <- weekNum + 52}
  weekNum <- weekNum - 31
  rp <- paste("../data/ndvi", fname, sep="/")
  x <- raster(rp)
  if(length(which(!is.na(x[]))) / ncell(x) > 0.05) { SM.df$NDVIFlag[weekNum] = 1} #.10 for AB
  if(SM.df$NDVIFlag[weekNum] == 1) {
    SM.df$Low[weekNum] <- length(which(x[] < -0.10)) / length(which(!is.na(x[])))
    SM.df$Med[weekNum] <- length(which(x[] >= -.10 & x[] <= .10)) / length(which(!is.na(x[])))
    SM.df$High[weekNum] <- length(which(x[] > .10)) / length(which(!is.na(x[])))
  }
  
}
write.csv(SM.df, "NDVI-data-BC.csv") # AB

#************************************************************************************
### Weather Time Series
#************************************************************************************
#Observed weather data over the reporting period from a sample of weather stations in the region.

df <- dbGetQuery(con, "SELECT * from wu_bc")
#df <- dbGetQuery(con, "SELECT * from wu_ab")

df$obsdt2 <- as.Date(df$subdate, "%Y-%m-%d")
df2 <- subset(df, obsdt2 >= dateStart & obsdt2 <= dateEnd)
#missingDates <- seq(dateStart, dateEnd, 1)[which(!seq(dateStart, dateEnd, 1) %in% df2$obsdt)]
df2$week <- as.numeric(format(df2$obsdt2, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df2$weekNum <- 1 + as.integer(df2$obsdt2 - o - df2$week) %/% 7

dfSum <- ddply(df2, "weekNum", summarise, highs = median(temperaturehighc, na.rm=TRUE), lows = median(temperaturelowc, na.rm=TRUE), avg = median(temperatureavgc, na.rm=TRUE), dewpoint = median(dewpointavgc), humidity = median(humidityavg), precip = median(precipsumcm, na.rm = TRUE))
  
TEMP.df <- data.frame(weekNum = 1:26, Rating = 0, Region = "BC")
# dfSum$Rating <- 0
# dfSum$Rating[dfSum$avg >= 20 | dfSum$avg < -10] <- 1 #condition 1
# dfSum$Rating[dfSum$avg >= 15 & dfSum$avg < 20 | dfSum$avg <= -10] <- 2 #condition 2
# dfSum$Rating[dfSum$avg >= 10 & dfSum$avg < 15 | dfSum$avg <= -5 & dfSum$avg >= -10] <- 3 #condition 3
# dfSum$Rating[dfSum$avg >= -5 & dfSum$avg < 10] <- 4 #condition 4 

dfSum$Rating <- 0
dfSum$Rating[dfSum$avg > 15 | dfSum$avg < -10] <- 1 #condition 1
dfSum$Rating[dfSum$avg >= 10 & dfSum$avg <= 15 | dfSum$avg <= -5 & dfSum$avg >= -10] <- 2 #condition 2
dfSum$Rating[dfSum$avg > -5 & dfSum$avg < 10] <- 3 #condition 3 

# above 15 or below -10 LOW
# between 10 and 15 OR -5 and -10 MOD
# -5 to 10 HIGH

TEMP.df$Rating <- dfSum$Rating 
write.csv(TEMP.df, "Temp-data-BC.csv") # AB  
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

weekStartJ <- as.numeric(format(weekNums, "%j"))
tifInd <- grep("BC.*$", list.files("../data/snowice/processed"))
tifInd <- list.files("../data/snowice/processed")[tifInd]
#tifIndAB <- grep("AB.*$", list.files("../data/snowice/processed"))
snow.df <- data.frame(weekNum = 1:26, snow = 0, Low = 0, Med = 0, High = 0, Region = "BC")
idx <- seq(1, length(tifInd)-5, by = 7)
for(i in 1:(length(weekStartJ))) {
  x <- raster(paste("../data/snowice/processed/",  tifInd[idx[i] + 1], sep=""))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 1], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 2], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 3], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 4], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 5], sep="/"))
  x <- addLayer(x, paste("../data/snowice/processed", tifInd[idx[i] + 6], sep="/"))
  x <- max(x)
  snow.df$snow[i] <- length(x[x ==4]) / length(!is.na(x[]))
}

plot(snow.df$weekNum, snow.df$snow)
snow.df$High[which(snow.df$snow <= 0.25)] <- 1
snow.df$Med[which(snow.df$snow > 0.25 & snow.df$snow <= 0.5)] <- 1
snow.df$Low[which(snow.df$snow > 0.5)] <- 1
write.csv(snow.df, "Snow-data-BC.csv")


