#************************************************************************************
#title: "Integrated Factor Surveillance Avian Influenza Intelligence - Scraper"
#author: "WHIP - C. Robertson"
#date: Feb 2018
#Test scraper
#************************************************************************************
#library("RPostgreSQL")
library("stringr")
library("rvest")
library("plyr")


getPoultrySite <- function(offset) {
    
    
    
    get_bf <- function(webpage){
      snips <- html_text(html_nodes(webpage, '.birdfluSnip'))
      items <- html_text(html_nodes(webpage, '.birdfluItem'))
      sources <- html_text(html_nodes(webpage, '.birdfluSource'))
      dates <- html_text(html_nodes(webpage, '.newsIndexDate'))
      rawText <- html_text(html_nodes(webpage, xpath = '//*[@id="sectiontwocolumn"]'))
      newDates <- vector(length=length(snips))
      curJ <- 1
      newDates[1] <- dates[1]
      for(j in 1:(length(dates)-1)) {
        bit1 <- str_sub(rawText, str_locate(rawText, dates[j])[2]+1, str_locate(rawText, dates[j+1])[1]-1)
        #val <- length(which(!is.na(as.vector(unlist(str_match_all(bit1, snips))))))
        val <- length(which(str_detect(str_replace_all(bit1, "[^[:alnum:]]", " "), str_replace_all(items, "[^[:alnum:]]", " "))))
        #print(val)
        newDates[curJ] <- dates[j]
        if(j == (length(dates)-1)) {
          for(k in 1:val) {
            newDates[curJ+k-1] <- dates[j]
          }
        } else { 
          if(j > 1) {
            for(k in 1:val) {
              newDates[curJ+k] <- dates[j]
            }
          }
          if(j == 1) {
            for(k in 1:(val-1)) {
              newDates[curJ+k] <- dates[j]
            }
          }  
        }
        curJ <- curJ + val
      }
      bit1 <- str_sub(rawText, str_locate(rawText, dates[j+1])[2]+1, str_locate(rawText, "Previous 20Next 20")[1]-1)
      val <- length(which(str_detect(str_replace_all(bit1, "[^[:alnum:]]", " "), str_replace_all(items, "[^[:alnum:]]", " "))))
      #newDates[curJ] <- dates[j+1]
      for(k in 1:val) {
        newDates[curJ+k-1] <- dates[j+1]
      }
      if(length(items) < 20) { 
        il <- length(items)
        items <- c(items, rep(NA, 20-il))}
      if(length(newDates) < 20) { 
        il <- length(newDates)
        newDates <- c(newDates, rep(NA, 20-il))}
      if(length(snips) < 20) { 
        il <- length(snips)
        snips <- c(snips, rep(NA, 20-il))}
      if(length(sources) < 20) { 
        il <- length(sources)
        sources <- c(sources, rep(NA, 20-il))}
      if(length(items) > 20) { 
        #il <- length(items)
        items <- items[1:20]} #c(items, rep(NA, 20-il))}
      if(length(newDates) > 20) { 
        #il <- length(newDates)
        newDates <- newDates[1:20]} #c(newDates, rep(NA, 20-il))}
      if(length(snips) > 20) { 
        #il <- length(snips)
        snips <- snips[1:20]} #c(snips, rep(NA, 20-il))}
      if(length(sources) > 20) { 
        #il <- length(sources)
        sources <- sources[1:20]} #c(sources, rep(NA, 20-il))}
      return(data.frame(newDates, snips, items, sources))
    }
    
    offsets <- seq(5000, 20, -20)
    baseurl <- "http://www.thepoultrysite.com/bird-flu/bird-flu-news.php"
    L <- list()
    for(i in 154:length(offsets)) {
      offset <- offsets[i]
      url <- paste(baseurl, "?offset=", offset, sep="")
      webpage <- read_html(as.character(url))
      d <- get_bf(webpage)
      d$URL <- url
      L[[i]] <- d
      Sys.sleep(10) #take a rest
    }
    DF <- do.call("rbind", L)
    write.csv(DF, "AI-poultrysite-3.csv")
    
}