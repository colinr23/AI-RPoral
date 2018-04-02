## getNDVI.R
## C. Robertson
## Purpose: Fetch NDVI data for specified areas, write to file
## 
## 
#################################################

#run on Sunday - check to see when the API updates the file
library(RCurl)
library(RJSONIO)
library("leaflet")


setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
#static URL, gets appended to weekly
fetchURL <- "https://test.whipdb.org/api/v1/get-aiv-test-results?apikey=FB3581E2CD2967B42401B2D518E2E44A&language=en"
from_date <- "&from_date=2009-01-01"
to_date <- "&to_date=2018-01-01"
province <- "&province=BC"
fetchURL <- paste(fetchURL, from_date, province, sep="")

#check its there
#Go get it

raw_data <- getURL(fetchURL, failonerror = TRUE)  
data <- fromJSON(raw_data)
nr <- length(data$data)
res <- data.frame(code = vector(length=nr), diagn = vector(length=nr), when = rep(0, nr), lat = vector(length=nr), lon = vector(length=nr))
res$when <- as.Date(res$when, origin = "1970-01-01")
for(i in 1:nrow(res)) {
  res$code[i] <-data$data[[i]]$specimen_code
  res$diagn[i] <- data$data[[i]]$diagnosis[[1]]$pathogenicity
  res$when[i] <- as.Date(data$data[[i]]$diagnosis[[1]]$diagnosis_date, "%Y-%m-%d")
  res$lat[i] <- as.numeric(data$data[[i]]$latitude)
  res$lon[i] <- as.numeric(data$data[[i]]$longitude)
}
coordinates(res) <- ~lon + lat
leaflet(res@data) %>% addTiles() %>% addMarkers(coordinates(res)[,1], coordinates(res)[,2], popup = paste(diagn,when))
