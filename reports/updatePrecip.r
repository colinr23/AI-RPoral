## updaatePrecip.R
## C. Robertson
## Purpose: Get precip records for BC to fill in 
## 
## 
#################################################


library(rclimateca)
ec_climate_geosearch_locations(
  "Abbotsford BC",
  year = 2007:2017,
  timeframe = "daily"
)

df <- ec_climate_data(
  "MISSION WEST ABBEY BC 810", timeframe = "daily", 
  start = "2017-08-06", end = "2018-02-03"
)
df <- data.frame(df)
df <- df[,c("location", "year", "month", "day", "date", "total_rain_mm")]


df$week <- as.numeric(format(df$date, "%w")) 
o <- as.Date("2017-08-06", "%Y-%m-%d")
df$weekNum <- 1 + as.integer(df$date - o - df$week) %/% 7
dfSum <- ddply(df, "weekNum", summarise, total = sum(total_rain_mm, na.rm=TRUE))

#*******************************************************************************
#*******************************************************************************
#*******************************************************************************
#*******************************************************************************
#*******************************************************************************
dfb <- ec_climate_data(
  "MISSION WEST ABBEY BC 810", timeframe = "daily", 
  start = "2009-08-02", end = "2017-02-03"
)
dfb <- data.frame(dfb)
dfb <- dfb[,c("location", "year", "month", "day", "date", "total_rain_mm")]

dfb <- subset(dfb, month >= 8 & day >= 1 | month >= 9 | month <= 1 | month == 2 & day <= 3)

dfb$week <- as.numeric(format(dfb$date, "%W")) 
o <- as.Date("2009-08-03", "%Y-%m-%d")
dfb$weekNum <- dfb$week + 1
dfb$weekNum[which(dfb$month >= 8)] <- dfb$weekNum[which(dfb$month >= 8)] - 31
dfb$weekNum[which(dfb$month <= 2)] <- dfb$weekNum[which(dfb$month <= 2)] + 20


dfbSum <- ddply(dfb, c("weekNum","year"), summarise, total = sum(total_rain_mm, na.rm=TRUE))
dfbSum <- ddply(dfbSum, c("weekNum"), summarise, total = mean(total))

dfbSum <- subset(dfbSum, weekNum >= 1 & weekNum <= 26)
dfM <- merge(dfSum, dfbSum, by = "weekNum")
names(dfM) <- c("WeekNum", "Y2017", "Baseline")
dfM$cumBase <- cumsum(dfM$Baseline)
dfM$cumY2017 <- cumsum(dfM$Y2017)
dfM$pctChg <- round((dfM$cumY2017 - dfM$cumBase) / (dfM$cumBase + .001), 4)
dfM$Low <- 0
dfM$Med <- 0
dfM$High <- 0
dfM$Low[which(dfM$pctChg <= -0.05)] <- 1
dfM$Med[which(dfM$pctChg > -0.05 & dfM$pctChg < 0.05)] <- 1
dfM$High[which(dfM$pctChg >= 0.05)] <- 1
write.csv(dfM, "SPrecip-data-BC.csv")


