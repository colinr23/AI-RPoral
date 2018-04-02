## getSnowIce.R
## C. Robertson
## Purpose: Fetch soil moisture data for specified areas, write to file
## 
## 
#################################################

#run on Sunday - check to see when the API updates the file
library(raster)
library(MODISSnow)
library(rgdal)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
dt2 <- as.POSIXlt(Sys.Date())
z <- ""
z <- download_data(dt2, h = 10, v = 3)
if (length(z) > 1) {
  print("Success!")
} else {print(paste("error - "))}

Sys.sleep(15) #take a rest

if (length(z) > 1) {
  #call function or script to process file
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

