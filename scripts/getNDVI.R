## getNDVI.R
## C. Robertson
## Purpose: Fetch NDVI data for specified areas, write to file
## 
## 
#################################################

#run on Sunday - check to see when the API updates the file
library(raster)
library(RCurl)
library(rgdal)
library(stringr)
# base fetch URL 
baseURL <- "http://www.agr.gc.ca/atlas/data_donnees/geo/aafcModisNdvi/tif/anomaly/2017/"
baseName <- "AgExtent.MOD.Anomaly.BestQuality.MaxNDVI."
# increment weekNum
dt2 <- as.POSIXlt(Sys.Date())
weekNum <- (dt2$yday %/%  7)
startJDs <- seq(79, 365, 7)
idx <- which.min(abs(startJDs-dt2$yday))
if(startJDs[idx] > dt2$yday) {
  idx <- idx - 1
}
startD <- startJDs[idx]
endD <- startD + 6
fetchURL <- paste(baseURL, baseName, "2017", startD, ".2017", endD, ".Week.", weekNum, ".zip", sep="")

#check its there
#Go get it
z <- ""
try(z <- getBinaryURL(fetchURL, failonerror = TRUE), silent=TRUE)
if (length(z) > 1) {download.file(fetchURL, destfile = paste("data/ndvi/", baseName, weekNum, ".zip", sep=""))
} else {print(paste(fetchURL, " doesn't exist", sep =  ""))}

#Sys.sleep(15) #take a rest

#if (length(z) > 1) {
  #call function or script to process file
##########################*************************
##########################*************************
##########################*************************
# MANUAL ONLY -- NEED TO ADJUST FOLDER/FILE NAME, AND WEEK NUM VARIABLE.. DO WEEKLY
#########################################################
dirs <- list.dirs("./data/ndvi/processed")
for(xi in 14:15) {
  rpath <- grep(".tif$", list.files(list.dirs("./data/ndvi/processed")[xi]))
  fname <- list.files(list.dirs("./data/ndvi/processed")[xi])[rpath]
  rp <- paste(list.dirs("./data/ndvi/processed")[xi], fname, sep="/")
  x <- raster(rp)
  weekNum <- as.numeric(str_sub(rp, -6, -5))
  sr <- readOGR('./data/basemap', "study-sites")
  srCRS <- proj4string(sr)
  sr <- spTransform(sr, proj4string(x))
  x1 <- crop(x, extent(sr)) #crop to extent of study sites
  srAB <- crop(x1, extent(sr[1,]))
  srBC <- crop(x1, extent(sr[2,]))
  srAB <- projectRaster(srAB, crs=srCRS)
  srBC <- projectRaster(srBC, crs=srCRS)
  writeRaster(srAB, paste("data/ndvi/current_SM-AB-", weekNum, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
  writeRaster(srBC, paste("data/ndvi/current_SM-BC-", weekNum, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
  
}
rm(z)
