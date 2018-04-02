#************************************************************************************
#title: "Integrated Factor Surveillance Avian Influenza Intelligence - Tweet Processing"
#author: "WHIP - C. Robertson"
#date: Feb 2018
#This script takes unprocessed tweets from the database and attempts to scrape the text linked to in each 
#************************************************************************************
library("RPostgreSQL")
library("stringr")
library("rvest")
library("plyr")
dateStart1 <- as.Date("09/01/2015", "%m/%d/%Y")   #June 1 2016 - starting date for monitoring period
dateEnd1 <- as.Date("03/01/2016", "%m/%d/%Y")     #March 4 2018 - ending date for monitoring period

dateStart2 <- as.Date("09/01/2016", "%m/%d/%Y")   #June 1 2016 - starting date for monitoring period
dateEnd2 <- as.Date("03/01/2017", "%m/%d/%Y")     #March 4 2018 - ending date for monitoring period

dateStart3 <- as.Date("09/01/2017", "%m/%d/%Y")   #June 1 2016 - starting date for monitoring period
dateEnd3 <- as.Date("03/01/2018", "%m/%d/%Y")     #March 4 2018 - ending date for monitoring period

## Social Media Summary
### AI-related Tweets During the Reporting Period
# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "whsc",host = "localhost", port = 5432, user = "postgres")
#
query <- "select tweetDate, tweettext, location, url from tweets"
df <- dbGetQuery(con, query)
df1 <- subset(df, tweetdate >= dateStart1 & tweetdate <= dateEnd1)
df2 <- subset(df, tweetdate >= dateStart2 & tweetdate <= dateEnd2)
df3 <- subset(df, tweetdate >= dateStart3 & tweetdate <= dateEnd3)
df1$Year <- 2015
df2$Year <- 2016
df3$Year <- 2017
df <- rbind(df1, df2, df3)
daily <- ddply(df, .(tweetdate), summarise, numTweets = length(tweetdate), Year = min(Year)) #summarize by mean
daily$numTweetsNorm <- 
daily$Julia <- as.numeric(format(daily$tweetdate, "%j"))
daily$Julia[which(daily$Julia < 200)] <- daily$Julia[which(daily$Julia < 200)] + 365
ggplot(daily, aes(Julia)) + geom_line(aes(y=numTweets, colour=factor(Year)), size=1) + stat_smooth(aes(y=numTweets, colour=factor(Year))) #+ geom_line(aes(y=numTweets3, colour="3 Day Moving \nAverage"), size=1) + geom_line(aes(y=numTweets7, color="7 Day Moving \nAverage"), size=1) + xlab("Day") + ylab("Daily AI-related Tweets") + scale_colour_manual("Lines", values=c("Daily"="black", "3 Day Moving \nAverage"="red", "7 Day Moving \nAverage"="grey")) + theme_bw() + theme(legend.title = element_blank(), legend.key.size = unit(1.5, "cm")) 



df1 <- df[sample(1:nrow(df), size = 10),]
df1$textContent <- ""

for(i in 1:nrow(df1)) {
  df1$textContent[i] <- printArticleText(df1$url[i])
  closeAllConnections()
  } 

printArticleText <- function(url) {
  texts <- "None"
  out <- tryCatch( 
    {

    if(is.na(str_match(url, ".com"))) {
      url <- decode_short_url(url)
    }
    webpage <- read_html(as.character(url))
    url <- html_text(html_node(webpage, 'a.twitter-timeline-link'))
    if(!is.na(url)) {
      url <- decode_short_url(url)
      url <- str_replace(as.character(url), "\\s+.*", "")
      webpage <- read_html(url)
      texts <- html_text(html_node(webpage, 'article'))
    } 
  },
  error=function(cond) {
    message(paste("URL does not seem to exist:", url))
    message("Here's the original error message:")
    message(cond)
    texts <- "Error"
    # Choose a return value in case of error
    return(NA)
  },  
  warning=function(cond) {
    message(paste("URL caused a warning:", url))
    # Choose a return value in case of warning
    return(NULL)
  },
  finally = {
    message(paste("Processed URL:", url))
    #print(url)
    #print(texts)
    Sys.sleep(5)
  }
  ) 
  return(texts)
}
decode_short_url <- function(url, ...) {
  # PACKAGES #
  require(RCurl)
  
  # LOCAL FUNCTIONS #
  decode <- function(u) {
    Sys.sleep(0.5)
    x <- try( getURL(u, header = TRUE, nobody = TRUE, followlocation = FALSE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")) )
    if(inherits(x, 'try-error') | length(grep(".*Location: (\\S+).*", x))<1) {
      return(u)
    } else {
      return(gsub('.*Location: (\\S+).*', '\\1', x))
    }
  }
  
  # MAIN #
  gc()
  # return decoded URLs
  urls <- c(url, ...)
  l <- vector(mode = "list", length = length(urls))
  l <- lapply(urls, decode)
  names(l) <- urls
  return(l)
}