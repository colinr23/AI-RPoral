setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/snowice")
library(RCurl)
url <- "ftp://sidads.colorado.edu/pub/DATASETS/NOAA/G02156/GIS/1km/2018/"
#userpwd <- "yourUser:yourPass"
filenames <- getURL(url, ftp.use.epsv = FALSE,dirlistonly = TRUE) 
files <- unlist(strsplit(filenames, split = "\r\n"))
baseName <- "GIS_snowice_1km"
for(i in 21:42) {
  file <- files[i]
  fetchURL <- paste(url, file,sep="")
  z <- ""
  try(z <- getBinaryURL(fetchURL, failonerror = TRUE), silent=TRUE)
  if (length(z) > 1) {download.file(fetchURL, destfile = paste("raw/", file, sep=""))
  } else {print(paste(fetchURL, " doesn't exist", sep =  ""))}
  Sys.sleep(10)
}