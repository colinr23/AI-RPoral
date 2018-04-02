
library(raster)
library(rgdal)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
tifInd <- list.files("/Users/colinr23/Desktop/raw") #doing this outside of the portal directory due to file sizes
#first go through and clip everything down
for(i in 1:(length(tifInd)-2)) {
  x <- raster(paste("/Users/colinr23/Desktop/raw/", tifInd[i], sep=""))
  sr <- readOGR('./data/basemap', "study-sites")
  srCRS <- proj4string(sr) #get CRS of basemap
  sr <- spTransform(sr, proj4string(x)) #reproject basemaps to that of raster
  x1 <- crop(x, extent(sr)) #crop to extent of study sites
  srAB <- crop(x1, extent(sr[1,])) #crop it down
  srBC <- crop(x1, extent(sr[2,])) #crop it down
  srAB <- projectRaster(srAB, crs=srCRS, method = 'ngb') #reproject
  srBC <- projectRaster(srBC, crs=srCRS, method = 'ngb') #reproject
  writeRaster(srAB, paste("/Users/colinr23/Desktop/raw/processed/AB-", tifInd[i], sep=""), format="GTiff", overwrite=TRUE)
  writeRaster(srBC, paste("/Users/colinr23/Desktop/raw/processed/BC-", tifInd[i], sep=""), format="GTiff", overwrite=TRUE)
}


