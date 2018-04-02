#************************************************************************************
#title: "Integrated Factor Surveillance Avian Influenza Intelligence - Web Application - Reporting App / Dashboard"
#author: "WHIP - C. Robertson"
#date: Mar 2018
#This script takes unprocessed tweets from the database and attempts to scrape the text linked to in each 
#************************************************************************************

library("shiny")
library("shinythemes")
library("shinycssloaders")
library("shinyjs")
#library("RPostgreSQL")
library("raster")
library("ggplot2")
#library("ggmap")
library("plyr")
library("leaflet")
library("stringr")
library("rgdal")
library("htmltools")
library("NLP")
library("tm")
library("RColorBrewer")
library("wordcloud")
library("topicmodels")
library("SnowballC")
library("Rmpfr")
library("tidyverse")
library("reshape2")
# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("darkly"),
  useShinyjs(),
   # Application title
  titlePanel("WHIP - Integrated Reporting"), 
  #dateStart <- as.Date("08/06/2017", "%m/%d/%Y")   #Aug 6 2017 - starting date for monitoring period
  #dateEnd <- as.Date("02/03/2018", "%m/%d/%Y")     #Feb 3 2018 - ending date for monitoring period
  #weekNums <- seq(dateStart, dateEnd, by = 7)
  #choices <- setNames(as.character(1:length(weekNums)), as.character(weekNums)) #maybe switch back to date
  sidebarLayout(
    sidebarPanel(
  selectInput("week", "Week Number:", setNames(as.character(1:length(seq(as.Date("08/06/2017", "%m/%d/%Y"), as.Date("02/03/2018", "%m/%d/%Y") , by = 7))), as.character(seq(as.Date("08/06/2017", "%m/%d/%Y"), as.Date("02/03/2018", "%m/%d/%Y") , by = 7))), selected = 14),
  selectInput("region", "Study Region:", setNames(c("BC", "AB"), c("BC", "AB"))),
  selectInput("image", "Image:", setNames(c("sm", "veg", "ice"), c("Soil Moisture", "NDVI", "Snow/Ice"))),
  selectInput("graph", "Graph:", setNames(c("ebird", "temp"), c("E-Bird", "Temperature"))),
  hidden(sliderInput("sgd", "NAIV",
              min = 0, max = 1, value = 0.4083
  )),
  hidden(sliderInput("s_birds", "Waterfowl Presence",
              min = 0, max = 1, value = 0.2417
  )),
  hidden(sliderInput("s_temp", "Temperature",
              min = 0, max = 1, value = 0.1028
  )),
  hidden(sliderInput("s_snow", "Snow/Ice",
              min = 0, max = 1, value = 0.0611
  )),
  hidden(sliderInput("s_sm", "Soil Moisture",
              min = 0, max = 1, value = 0.1583
  )),
  hidden(sliderInput("s_vege", "Vegetation",
              min = 0, max = 1, value = 0.0278
  ))
  
  #htmlOutput("selectUIRegion"),
  ),
   # Sidebar with a slider input for number of bins 
  mainPanel(
    tabsetPanel(
      tabPanel("Environmental", 
               #h4("Waterfowl Presence"),
               withSpinner(leafletOutput("EB_map")),
               withSpinner(plotOutput("EnviroGraph")),
               value = "env"
              ),
      tabPanel("Social", 
               h3("Social Media Signals"),
               h5("Social Media - Theme"),
               withSpinner(plotOutput("tweetCloud")),
               h5("Social Media - Locations"),
               withSpinner(plotOutput("tweetCloud2")),
               h5("Global Headlines"),
               tableOutput("poultrySite"),
               value = "soc"
               ),
      tabPanel("Authoritative", 
               #h3("OIE Reporting"),
               h3("CWHC Surveillance"),
               plotOutput("cwhcaiv"),
               value = "aut"
              ), 
      tabPanel("Risk Matrix", 
               withSpinner(plotOutput("matrixPlot")),
               value = "risk"
              ),
      tabPanel("About", 
               h3("WHIP Integrated Reporting"),
               div("This application is a proof of concept tool for integrating risk factor data collected as part of the project 'Wildlife Health Intelligence to Improve Agriculture Threat Detection' which aimed to develop and evaluate indicators for AI risk from environmental and online information sources."),
               tags$br(),
               div("Datasets in this project were categorized as web/social, environmental, and authoritative. Different tools and technologies were created to extract and process each variable and generate weekly reports."),
               h4("Environmental Sources"),
               tags$table(class = "table",
                          tags$thead(tags$tr(
                            tags$th("Factor"),
                            tags$th("Source"),
                            tags$th("Description")
                          )),
                          tags$tbody(
                            tags$tr(
                              tags$td("Soil Moisture"),
                              tags$td("AAFC - Soil Moisture Weekly Anomalies"),
                              tags$td("Weekly product showing soil moisture during the growing season relative to a baseline. Each week is the percentage above or below the baseline range.")
                            ),
                            tags$tr(
                              tags$td("NDVI"),
                              tags$td("AAFC - NDVI Weekly Anomalies"),
                              tags$td("Weekly vegetation index during the growing season relative to a baseline. Each week is the NDVI above or below the baseline range.")
                            ),
                            tags$tr(
                              tags$td("Snow/Ice"),
                              tags$td("National Snow and Ice Data Center"),
                              tags$td("Daily Northern Hemisphere Snow and Ice Analysis at 1 km, summarized by week. Values here indicate 2 for dry land and 4 for snow covered land.")
                            )
                          )
               ),
               h4("Social/Web Sources"),
               tags$table(class = "table",
                          tags$thead(tags$tr(
                            tags$th("Factor"),
                            tags$th("Source"),
                            tags$th("Description")
                          )),
                          tags$tbody(
                            tags$tr(
                              tags$td("Social Media Activity"),
                              tags$td("Twitter Streaming API"),
                              tags$td("Weekly wordclouds generated from Tweets matching a set of pre-defined AI keywords. Weekly wordclouds generated from location of accounts Tweeting content matching a set of pre-defined AI keywords.")
                            ),
                            tags$tr(
                              tags$td("Global AI Headlines"),
                              tags$td("The Poultry Site"),
                              tags$td("Global AI headlines of outbreaks and stories are tracked by The Poultry Site. These are indexed here by week.")
                            ))),
                      h4("Authoritative Sources"),
                            tags$table(class = "table",
                                       tags$thead(tags$tr(
                                         tags$th("Factor"),
                                         tags$th("Source"),
                                         tags$th("Description")
                                       )),
                                       tags$tbody(
                                         tags$tr(
                                           tags$td("CWHC AI Tests"),
                                           tags$td("CWHC API"),
                                           tags$td("Weekly counts of AI tests submitted to CWHC network labs based on most recently available data (currently excluding BC).")
                                         ),
                                         tags$tr(
                                           tags$td("Global AI Outbreaks"),
                                           tags$td("OIE"),
                                           tags$td("To be added: weekly location and duration of known global outbreaks of AI as monitored by OIE.")
                                         )
                          )
               ),
               value = "about"
      ),id = 'main')

)))

getChart <- function(tweets) {
  #tweets <- df$tweettext #xA1$text
  
  # Here we pre-process the data in some standard ways. I'll post-define each step
  tweets <- iconv(tweets, to = "ASCII", sub = " ")  # Convert to basic ASCII text to avoid silly characters
  tweets <- tolower(tweets)  # Make everything consistently lower case
  tweets <- gsub("rt", " ", tweets)  # Remove the "RT" (retweet) so duplicates are duplicates
  tweets <- gsub("@\\w+", " ", tweets)  # Remove user names (all proper names if you're wise!)
  tweets <- gsub("http.+ |http.+$", " ", tweets)  # Remove links
  tweets <- gsub("[[:punct:]]", " ", tweets)  # Remove punctuation
  tweets <- gsub("[ |\t]{2,}", " ", tweets)  # Remove tabs
  tweets <- gsub("amp", " ", tweets)  # "&" is "&amp" in HTML, so after punctuation removed ...
  tweets <- gsub("^ ", "", tweets)  # Leading blanks
  tweets <- gsub(" $", "", tweets)  # Lagging blanks
  tweets <- gsub(" +", " ", tweets) # General spaces (should just do all whitespaces no?)
  tweets <- unique(tweets)  # Now get rid of duplicates!
  
  
  # Convert to tm corpus and use its API for some additional fun
  corpus <- Corpus(VectorSource(tweets))  # Create corpus object
  # Remove English stop words. This could be greatly expanded! # Don't forget the mc.cores thing
  corpus <- tm_map(corpus, removeWords, stopwords("en"))  
  # Remove numbers. This could have been done earlier, of course.
  corpus <- tm_map(corpus, removeNumbers)
  # Stem the words. Google if you don't understand
  corpus <- tm_map(corpus, stemDocument)
  # Remove the stems associated with our search terms!
  corpus <- tm_map(corpus, removeWords, c("bird", "flu", "avian", "influenza", "poultry"))
  #corpus <- tm_map(corpus, removeSparseTerms ,0.90)
  pal <- brewer.pal(8, "Dark2")
  w <- wordcloud(corpus, min.freq=2, max.words = 150, random.order = TRUE, col = pal) 
  return(w)
  
}
getImageData <- function(region, week, imgType, panelType) { #get soil moisture as a raster
  proxy <- leafletProxy("EB_map")
  
  if(imgType == 'sm' & as.numeric(week) <= 45) {
      f <- paste("data/SM/current_SM-", region, "-", week, "-.tif", sep="")
      r <- raster(f) 
      pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(r), na.color = "transparent")
      proxy %>% clearImages() %>% clearControls() %>% 
        addRasterImage(r, colors = pal, opacity = 0.8) %>%
        addLegend(pal = pal, values = values(r),
                title = "Soil Moisure", labFormat = function(type = "numeric", cuts){ cuts <- sort(cuts, decreasing = T)})
    }
  else if(imgType == 'veg' & as.numeric(week) <= 44) {
      f <- paste("data/NDVI/current_SM-", region, "-", week, "-.tif", sep="")
      r <- raster(f)
      pal <- colorNumeric(c("#2ECC71", "#41B6C4", "#E67E22"), values(r), na.color = "transparent") #blue, yellow, blue-grey, white-grey
      r[r < .05] <- NA
      proxy %>% clearImages() %>% clearControls() %>% 
        addRasterImage(r, colors = pal, opacity = 0.8) %>%
        addLegend(pal = pal, values = values(r),
                  title = "NDVI", labFormat = function(type = "numeric", cuts){ cuts <- sort(cuts, decreasing = T)}) 
  }
  else if(imgType == 'ice') {
    week <- as.numeric(week) - 31
    f <- paste("data/snowice/current_SM-", region, "-", week, "-.tif", sep="")
    r <- raster(f)
    r <- projectRaster(r, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
    r <- reclassify(r, c(-Inf,1.5,1, 1.5,2.5,2, 2.5,3.5,3, 3.5,4,4))
    pal <- c("#3385ff", "#cccc00","#f2f2f2", "#f2f2f2")
    vals <- c(1, 2, 3, 4)
    pa <- colorFactor(pal, vals)
    proxy %>% clearImages() %>% clearControls() %>% 
      addRasterImage(r, colors = pa, opacity = 0.8)  %>%
      addLegend(pal = pa, values = vals, labels = c("Water", "Land", "Snow/Ice", "Snow/Ice"), title = "Ice/Snow") 
  }
  else {
    proxy %>% clearImages() %>% clearControls()
    if(panelType == "env") {
      showNotification("No image data for that week in this region")
    }
  }
} 

# Define server logic required to draw a histogram
server <- function(input, output, session) {
      df <- read.csv("data/cleaned-ebird-app.csv")
      df$obsdt <- as.Date(str_sub(df$obsdt, 1, 10), "%Y-%m-%d")
      dfTweets <- read.csv("data/tweets-shiny.csv")
      dfPS <- read.csv("data/ps-g.csv")
      dfPS$Link <- paste("<a href='", dfPS$URL, "'>", dfPS$sources, "</a>", sep="")
      dfM <- read.csv("data/whip-Matrix-FINAL.csv")
      dfM <- dfM[,1:8]
      dfA <- read.csv("data/aiv.csv")
      coordinates(df) <- ~X + Y
      proj4string(df) <- "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=63.390675 +lon_0=-91.86666666666666 +x_0=6200000 +y_0=3000000 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"
      df <- spTransform(df, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
      df$Xt <- coordinates(df)[,1]
      df$Yt <- coordinates(df)[,2]
      df$weekNum <- as.character(df$weekNum)
      dfo <- df
      df <- subset(df, region == "BC")
    
    output$EB_map <- renderLeaflet({
      leaflet(df) %>% addTiles() #%>% setView(mean(df$Xt), mean(df$Yt), 10) #addCircleMarkers(~Xt, ~Yt, label = ~htmlEscape(obsdt)) 
    })
    
    output$tweetCloud <- renderPlot({
      dfTweetsW <- subset(dfTweets, weekNum == as.numeric(input$week))
      g <- getChart(dfTweetsW$tweettext)
      g
    })
    output$tweetCloud2 <- renderPlot({
      dfTweetsW <- subset(dfTweets, weekNum == as.numeric(input$week))
      g <- getChart(dfTweetsW$location)
      g
    })
    output$matrixPlot <- renderPlot({
      dfMValues <- dfM #dfM[dfM$Region == input$Region,]
      w_naid <- as.numeric(input$sgd)
      w_birds <- as.numeric(input$s_birds)
      w_temp <- as.numeric(input$s_temp)
      w_snow <- as.numeric(input$s_snow)
      w_sm <- as.numeric(input$s_sm)
      w_vege <- as.numeric(input$s_vege)
      dfMValues$SoilMoisture[is.na(dfMValues$SoilMoisture[which(dfMValues$Region=="AB")])] <- mean(dfMValues$SoilMoisture[which(dfMValues$Region=="AB")], na.rm=TRUE)
      dfMValues$NDVI[is.na(dfMValues$NDVI[which(dfMValues$Region=="AB")])] <- mean(dfMValues$NDVI[which(dfMValues$Region=="AB")], na.rm=TRUE)
      dfMValues$SoilMoisture[is.na(dfMValues$SoilMoisture[which(dfMValues$Region=="BC")])] <- mean(dfMValues$SoilMoisture[which(dfMValues$Region=="BC")], na.rm=TRUE)
      dfMValues$NDVI[is.na(dfMValues$NDVI[which(dfMValues$Region=="AB")])] <- mean(dfMValues$NDVI[which(dfMValues$Region=="AB")], na.rm=TRUE)
      dfMValues$Risk <- (w_naid * dfMValues$NAIV) + (w_birds * dfMValues$Waterfowl) + (w_temp * dfMValues$Temperature)+ (w_sm * dfMValues$SoilMoisture) + (w_vege * dfMValues$NDVI)
      dfMValues$week <- 0
      dfMValues$week[dfMValues$WeekNum >= as.numeric(input$week)] <- 1
      ggplot(dfMValues, aes(x = WeekNum, y = Risk)) + geom_point(aes(colour = factor(Region), shape = factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth(aes(colour = factor(Region)))  + theme_bw() + scale_colour_manual(values = c("Green", "Blue"), labels = c("AB", "BC"), name = "Region") + scale_shape_manual(values = c(1, 4), labels = c("Before", "After"), name = "Time") 
    })
    output$cwhcaiv <- renderPlot({
      dfAI <- ddply(dfA, "weekNum", summarise,  tests=length(week))
      dfAIProv <- ddply(dfA, c("weekNum", "Province"), summarise,  tests=length(week))
      dfAIBC <- subset(dfAIProv, Province == "British Columbia")
      dfAIAB <- subset(dfAIProv, Province == "Alberta")
      missing <- which(!1:26 %in% dfAIBC$weekNum)
      if(length(missing) > 0) {
        missing <- data.frame(weekNum = missing, Province = "BC", tests = 0)
        dfAIBC <- rbind(missing, dfAIBC)
      }
      missing <- which(!1:26 %in% dfAIAB$weekNum)
      if(length(missing) > 0) {
        missing <- data.frame(weekNum = missing, Province = "AB",  tests = 0)
        dfAIAB <- rbind(missing, dfAIAB)
      }
      dfAIAB$Province <- "AB"
      dfAIBC$Province <- "BC"
      dfProv <- rbind(dfAIAB, dfAIBC)
      #ggplot(dfProv, aes(x = weekNum, y = tests)) + geom_point(aes(colour=Province)) + stat_smooth(aes(colour=Province)) + labs(x = "Week Number (Aug 6 2017 = Week 1)", y = "Number AIV PCR Tests")
      ggplot(dfAI, aes(x = weekNum, y = tests)) + geom_point() + stat_smooth() + labs(x = "Week Number (Aug 6 2017 = Week 1)", y = "Number AIV PCR Tests - Canada (excluding BC)")
    })
    output$poultrySite <- renderTable({
      PS <- subset(dfPS, weekNum == as.numeric(input$week))
      PS <- PS[,c("newDates", "items", "snips", "Link")]
      names(PS) <- c("Date", "Headline", "Details", "Source")
      PS
    }, sanitize.text.function = function(x) x)
  #}
   #observer event on region ***********************************
   observeEvent(input$region, {
     #g <- getGraphData(input$region, input$week, input$graph, dfo) #region, week, graphType, dfo
      df2 <- dfo[dfo$region == input$region & dfo$weekNum == input$week, ]
      rweek <- as.numeric(input$week) + 31 
      getImageData(input$region, rweek, input$image, input$main)
      proxy <- leafletProxy("EB_map") 
      if(nrow(df2)==0){
        proxy %>% clearShapes()
        showNotification("No records for that week in this region") 
      #update graph with current weeks data
      }
      else {
        proxy %>% clearShapes() %>% addCircles(lng=df2$Xt, lat=df2$Yt) %>% fitBounds(min(df2$Xt), min(df2$Yt), max(df2$Xt), max(df2$Yt))
      }
      output$EnviroGraph <- renderPlot({
          if(input$graph == "ebird") {
            df2 <- dfo[dfo$region == input$region, ]
            df2$weekNum <- as.numeric(df2$weekNum)
            
            dfSum <- ddply(df2@data, .(weekNum), summarise, Number = sum(howmany, na.rm=TRUE), Sightings = length(howmany), .drop = FALSE)
            missing <- which(!1:26 %in% dfSum$weekNum)
            if(length(missing) > 0) {
              missing <- data.frame(weekNum = missing, Number = 0, Sightings = 0)
              dfSum <- rbind(missing, dfSum)
            }
            dfSum$week <- 0
            dfSum$week[dfSum$weekNum <= as.numeric(input$week)] <- 1
            ggplot(dfSum, aes(x = weekNum, y = Sightings)) + geom_point(aes(colour = factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth()  + theme_bw() + theme(legend.position="none")
          }
          else {
            dfSum <- read.csv("data/temperature-shiny.csv")
            dfSum <- subset(dfSum, region == input$region)
            dfSum$week <- 0
            dfSum$week[dfSum$weekNum <= as.numeric(input$week)] <- 1
            
            ggplot(dfSum) + geom_line(aes(x = weekNum, y = highs, colour=factor(week))) +  geom_line(aes(x = weekNum, y = lows, colour=factor(week))) + geom_line(aes(x = weekNum, y = avg, colour=factor(week))) + geom_point(aes(x = weekNum, y = avg, colour=factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)", y = "Temperature (C) - lows, avg, highs") + theme_bw() + theme(legend.position="none")
          }
      })
       
    })
  
   #observer event on week ***********************************
   observeEvent(input$week, {
     #x <- input$refresh_helper
     #getGraphData(input$region, input$week, input$graph, dfo)
     df2 <- dfo[dfo$region == input$region & dfo$weekNum == input$week, ]
     rweek <- as.numeric(input$week) + 31 
     getImageData(input$region, rweek, input$image, input$main)
     proxy <- leafletProxy("EB_map") 
     if(nrow(df2)==0){
       proxy %>% clearShapes()
       if(input$main == "env") {
         showNotification("No records for that week in this region") 
       }
       #update graph with current weeks data
     }
     else {
       proxy %>% clearShapes() %>% addCircles(lng=df2$Xt, lat=df2$Yt) %>% fitBounds(min(df2$Xt), min(df2$Yt), max(df2$Xt), max(df2$Yt))
     }
     rweek <- as.numeric(input$week) + 31 
     getImageData(input$region, rweek, input$image, input$main)
     if(input$main == "soc") {
       output$tweetCloud <- renderPlot({
         dfTweetsW <- subset(dfTweets, weekNum == as.numeric(input$week))
         g <- getChart(dfTweetsW$tweettext)
         g
       })
       output$tweetCloud2 <- renderPlot({
         dfTweetsW <- subset(dfTweets, weekNum == as.numeric(input$week))
         g <- getChart(dfTweetsW$location)
         g
       })
       output$poultrySite <- renderTable({
         PS <- subset(dfPS, weekNum == as.numeric(input$week))
         PS <- PS[,c("newDates", "items", "snips", "Link")]
         names(PS) <- c("Date", "Headline", "Details", "Source")
         PS
       }, sanitize.text.function = function(x) x)
     }
     if(input$main == "env") {
       output$EnviroGraph <- renderPlot({
         if(input$graph == "ebird") {
           df2 <- dfo[dfo$region == input$region, ]
           df2$weekNum <- as.numeric(df2$weekNum)
           
           dfSum <- ddply(df2@data, .(weekNum), summarise, Number = sum(howmany, na.rm=TRUE), Sightings = length(howmany), .drop = FALSE)
           missing <- which(!1:26 %in% dfSum$weekNum)
           if(length(missing) > 0) {
             missing <- data.frame(weekNum = missing, Number = 0, Sightings = 0)
             dfSum <- rbind(missing, dfSum)
           }
           dfSum$week <- 0
           dfSum$week[dfSum$weekNum <= as.numeric(input$week)] <- 1
           ggplot(dfSum, aes(x = weekNum, y = Sightings)) + geom_point(aes(colour = factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth()  + theme_bw() + theme(legend.position="none")
         }
         else {
           dfSum <- read.csv("data/temperature-shiny.csv")
           dfSum <- subset(dfSum, region == input$region)
           dfSum$week <- 0
           dfSum$week[dfSum$weekNum <= as.numeric(input$week)] <- 1
           #ggplot(dfSum, aes(x = weekNum, y = avg)) + geom_point(aes(colour = factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)") + stat_smooth()  + theme_bw() + theme(legend.position="none")
           ggplot(dfSum) + geom_line(aes(x = weekNum, y = highs, colour=factor(week))) +  geom_line(aes(x = weekNum, y = lows, colour=factor(week))) + geom_line(aes(x = weekNum, y = avg, colour=factor(week))) + geom_point(aes(x = weekNum, y = avg, colour=factor(week))) + labs(x = "Week Number (Aug 6 2017 = Week 1)", y = "Temperature (C) - lows, avg, highs") + theme_bw() + theme(legend.position="none")
         }
       })
     }
   })
   #observer event on image ***********************************
   observeEvent(input$image, {
     #getGraphData(input$region, input$week, input$graph, dfo)
     rweek <- as.numeric(input$week) + 31 
     getImageData(input$region, rweek, input$image, input$main)
   })
   #observer event on graph ***********************************
   # observeEvent(input$graph, {
   #   rweek <- as.numeric(input$week) + 31 
   #   #getGraphData(input$week, input$region, input$graph, dfo)
   # })
   #observer event on tabset ***********************************
   
   observeEvent(input$main, {
     if(input$main == "soc") { 
        enable("week")
        disable("region")
        disable("image")
        disable("graph")
        hide("sgd")
        hide("s_birds")
        hide("s_temp")
        hide("s_snow")
        hide("s_sm")
        hide("s_vege")
     }
     if(input$main == "aut") { 
       disable("week")
       disable("region")
       disable("image")
       disable("graph")
       hide("sgd")
       hide("s_birds")
       hide("s_temp")
       hide("s_snow")
       hide("s_sm")
       hide("s_vege")
     }
     if(input$main == "about") {
       disable("week")
       disable("region")
       disable("image")
       disable("graph")
       hide("sgd")
       hide("s_birds")
       hide("s_temp")
       hide("s_snow")
       hide("s_sm")
       hide("s_vege")

     }
     if(input$main == "risk") { 
       showElement("sgd")
       showElement("s_birds")
       showElement("s_temp")
       showElement("s_snow")
       showElement("s_sm")
       showElement("s_vege")
       showElement("updateMatrix")
       enable("week")
       disable("region")
       disable("image")
       disable("graph")
     }
     if(input$main == "env") { 
       enable("week")
       enable("region")
       enable("image")
       enable("graph")
       hide("sgd")
       hide("s_td")
       hide("s_trans")
       hide("s_birds")
       hide("s_temp")
       hide("s_snow")
       hide("s_sm")
       hide("s_vege")
     }
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

