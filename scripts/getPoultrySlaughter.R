## getNDVI.R
## C. Robertson
## Purpose: Fetch NDVI data for specified areas, write to file
## 
## 
#################################################

#run on Sunday - check to see when the API updates the file
library(RCurl)
setwd("/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal")
#static URL, gets appended to weekly
fetchURL <- "http://od-do.agr.gc.ca/WeeklyPoultrySlaughter_AbattageVolailleHebdomadaire.csv"
#check its there
#Go get it
z <- ""
try(z <- getBinaryURL(fetchURL, failonerror = TRUE), silent=TRUE)   
if (length(z) > 1) {download.file(fetchURL, destfile = paste("data/poultry/", "poultry.csv", sep=""))
} else {print(paste(fetchURL, " doesn't exist", sep =  ""))}

Sys.sleep(15) #take a rest

rm(z)
