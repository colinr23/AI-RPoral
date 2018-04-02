## getWeatherProducts.R
## C. Robertson
## Purpose: Fetch weather data for specified areas, create interpolation, write to file
## 
## 
#################################################
#-- One Time
#library("devtools")
#install_github("Ram-N/weatherData")

#-- Start script
library(weatherData)
library(sp)
library(automap)
library(raster)
library(rgdal)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
getweather <- function(studyArea, d) {
  #get current date
  
  sr <- readOGR('./data/basemap', "study-sites")
  #get weather for location X for current date
  if(studyArea == "AB") {
    stations <- read.csv("data/weather/alberta-weather.csv", stringsAsFactors = FALSE)
    sr <- sr[1,]
  }
  if(studyArea == "BC") {
    stations <- read.csv("data/weather/fraserValley-weather.csv", stringsAsFactors = FALSE)
    sr <- sr[2,]
  }
  x <- 1
  L <- list()
  for(i in 1:nrow(stations)) {
    dat <- getWeatherForDate(stations$Code[i], d, station_type = 'id', opt_all_columns = TRUE)
    if(!is.null(dat)) {
      #add to bag
      dat$station <- stations$Code[i]
      dat$Lat <- stations$Lat[i]
      dat$Long <- stations$Long[i]
      dat$Ele <- stations$Ele[i]
      x <- x + 1
      L[[x]] <- dat
    }
  }
  
  Sys.sleep(15) #take a break
  
  L.df <- do.call("rbind", L)
  coordinates(L.df) <- c("Long", "Lat")
  proj4string(L.df) <- CRS("+proj=longlat +ellps=GRS80 +units=m +datum=NAD83")
  sp.df <- spTransform(L.df,CRS=CRS(("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=63.390675 +lon_0=-91.86666666666666 +x_0=6200000 +y_0=3000000 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")))
  sp.df$x <- coordinates(sp.df)[,1]
  sp.df$y <- coordinates(sp.df)[,2]
  
  #remove and fill outliers
  #average temperature
  sp.df@data$TemperatureAvgC[-which(sp.df@data$TemperatureAvgC >= boxplot.stats(sp.df@data$TemperatureAvgC)$stats[2] & sp.df@data$TemperatureAvgC <= boxplot.stats(sp.df@data$TemperatureAvgC)$stats[4])] <- NA
  #sp.df@data$TemperatureAvgC[is.na(sp.df@data$TemperatureAvgC)] <- mean(sp.df@data$TemperatureAvgC, na.rm = TRUE) #mean substitution
  #sum precipitation
  sp.df@data$PrecipitationSumCM[-which(sp.df@data$PrecipitationSumCM >= boxplot.stats(sp.df@data$PrecipitationSumCM)$stats[2] & sp.df@data$PrecipitationSumCM <= boxplot.stats(sp.df@data$PrecipitationSumCM)$stats[4])] <- NA
  #sp.df@data$PrecipitationSumCM[is.na(sp.df@data$PrecipitationSumCM)] <- mean(sp.df@data$PrecipitationSumCM, na.rm = TRUE)
  
  sr.grid <- spsample(sr, type="regular", cellsize = 5000, offset = c(0.5, 0.5))
  gridded(sr.grid) <- TRUE
  
  if(mean(sp.df$PrecipitationSumCM, na.rm = TRUE) > .05) {  
    sp.df2 <- sp.df[!is.na(sp.df$PrecipitationSumCM),]
    kriging_result_P <- autoKrige(PrecipitationSumCM~1, sp.df2, new_data = sr.grid)
    writeRaster(raster(kriging_result_P$krige_output), paste("data/weather/precip/current_Precip-", studyArea, "-", d, ".tif", sep=""), format="GTiff", overwrite=TRUE)
  }  
  #kriging_result <- autoKrige(TemperatureHighC~Elev, sp.df)
  write.csv(cbind(ID=as.numeric(format(d, "%s"))+1:nrow(sp.df), sp.df@data[,c(1,3:10,17)]),  paste("data/weather/current_wu-", d, "-", studyArea, ".csv", sep=""), row.names=FALSE) #write the csv file
  sp.df2 <- sp.df[!is.na(sp.df$TemperatureAvgC),]
  kriging_result_T <- autoKrige(TemperatureAvgC~1, sp.df2, new_data = sr.grid)
  writeRaster(raster(kriging_result_T$krige_output), paste("data/weather/temp/current_Temperature-", studyArea, "-", d, ".tif", sep=""), format="GTiff", overwrite=TRUE)
  
}

d <- Sys.Date()
getweather("AB", d) #call to create it for Alberta
Sys.sleep(10)
getweather("BC", d) #call to create it for BC

# for bulk loading or infilling **********************************
#dateStart <- as.Date("08/06/2017", "%m/%d/%Y") #Aug 6 2017
#dateEnd <- as.Date("09/13/2017", "%m/%d/%Y") #Feb 3 2018
#dayNums <- seq(dateStart, dateEnd, by = 1)
#dayNums <- missingDates
#for(i in 1:length(dayNums)) {
#  d <- dayNums[i]
#  getweather("AB", d) #call to create it for Alberta
#  Sys.sleep(10)
#  getweather("BC", d) #call to create it for BC
#}
# for bulk loading or infilling **********************************



