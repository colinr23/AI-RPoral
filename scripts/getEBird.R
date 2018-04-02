## getEBird.R
## C. Robertson
## Purpose: Fetch e-bird data for specified areas in last week, write to database
## 
## 
#################################################


#install.packages("rebird")
library(rebird)
library(rgdal)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
srpts <- readOGR('./data/basemap', "study-sites-pts2")
srptsCRS <- proj4string(srpts)
srpts <-spTransform(srpts, CRS("+proj=longlat +ellps=GRS80 +units=m +datum=NAD83"))
L <- list()
for(i in 1:nrow(srpts)) {
  ebird <- ebirdgeo(species = NULL, lat = coordinates(srpts)[i,2], lng = coordinates(srpts)[i,1], dist = 50, back = 7, sleep = 10)
  ebird <- data.frame(ebird)
  L[[i]] <- ebird
}

ebirdDF <- do.call("rbind", L)
ebirdDF.cln <- ebirdDF[!duplicated(ebirdDF),] #remove duplicates due to grid search overlap
coordinates(ebirdDF.cln) <- c("lng", "lat")
proj4string(ebirdDF.cln) <- CRS("+proj=longlat +ellps=GRS80 +units=m +datum=NAD83")
srpts <-spTransform(ebirdDF.cln, srptsCRS)
srpts <- srpts[,-10] #remove duplicate locid -- issue as of January 11 2018 - API change
writeOGR(srpts, "./data/e-bird/", paste("e-bird-", Sys.Date(), sep=""), driver="ESRI Shapefile", overwrite_layer=TRUE)
