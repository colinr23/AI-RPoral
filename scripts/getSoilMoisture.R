## getSoilMoisture.R
## C. Robertson
## Purpose: Fetch soil moisture data for specified areas, write to file
## 
## 
#################################################

#run on Sunday - check to see when the API updates the file
library(raster)
library(RCurl)
library(rgdal)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
# base fetch URL 
baseURL <- "http://www.agr.gc.ca/atlas/data_donnees/geo/aafcPsssm/tif/anomaly/2017/weekly/"
baseName <- "SMDiffAvg_SMUDP2_2017_Week_"
# increment weekNum
dt2 <- as.POSIXlt(Sys.Date())
weekNum <- (dt2$yday %/%  7) 
fetchURL <- paste(baseURL, baseName, weekNum, "_M5.tif", sep="")

#check its there
#Go get it
z <- ""
try(z <- getBinaryURL(fetchURL, failonerror = TRUE), silent=TRUE)   
if (length(z) > 1) {download.file(fetchURL, destfile = paste("data/soilmoisture/", baseName, weekNum, "_M5.tif", sep=""))
} else {print(paste(fetchURL, " doesn't exist", sep =  ""))}

Sys.sleep(15) #take a rest

if (length(z) > 1) {
  #call function or script to process file
  weekNum <- "43"
  x <- raster(paste("data/soilmoisture/", baseName, weekNum, "_M5.tif", sep=""))
  sr <- readOGR('./data/basemap', "study-sites")
  srCRS <- proj4string(sr)
  sr <- spTransform(sr, proj4string(x))
  x1 <- crop(x, extent(sr)) #crop to extent of study sites
  srAB <- crop(x1, extent(sr[1,]))
  srBC <- crop(x1, extent(sr[2,]))
  srAB <- projectRaster(srAB, crs=srCRS)
  srBC <- projectRaster(srBC, crs=srCRS)
  writeRaster(srAB, paste("data/soilmoisture/current_SM-AB-", weekNum, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
  writeRaster(srBC, paste("data/soilmoisture/current_SM-BC-", weekNum, "-.tif", sep=""), format="GTiff", overwrite=TRUE)
}
rm(z)
#NDVI - #http://www.agr.gc.ca/atlas/data_donnees/geo/aafcModisNdvi/tif/anomaly/2017/  
#weekly poultry slaughter - #http://open.canada.ca/data/en/dataset/abf0347f-637b-4542-8d0b-d6f3496094f1

