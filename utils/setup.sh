#instal home brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install postgis
brew install postgis

#start postgres
brew services start postgresql

# create database for context data
createdb whsc
psql -d whsc -c "CREATE EXTENSION postgis;"
createuser -s postgres

# do initial inserts of static spatial data
#study sites (maybe dont use hyphens in table name - use underscores instead)
shp2pgsql -I -S -s 3347 /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/basemap/study-sites.shp study_sites | psql -U postgres -d whsc

#
# do initial inserts of dynamic spatial data (will depend on date of first dataset)
shp2pgsql -I -S -s 3347 /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/e-bird/e-bird-2017-06-18.shp ebird | psql -U postgres -d whsc


#these are one time table creation and initial inserts commands
#poulry
psql -U postgres -d whsc -c "CREATE TABLE poultry (EndDt_DtFin Date, MjrCmdtyEn_PrdtPrncplAn varchar, MjCmdtyFr_PrdtPrncplFr varchar, CtgryEn_CtgrieAn varchar, CtgryFr_CtgrieFr varchar, NumHd_NmbTetes integer, LvWt_PdsVif integer);"
psql -U postgres -d whsc -c "COPY poultry FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/poultry/poultry.csv' DELIMITER ',' CSV HEADER;"

#wu - ab
psql -U postgres -d whsc -c "CREATE TABLE wu_ab (ID bigint,SubDate Date,TemperatureHighC double precision,TemperatureAvgC double precision,TemperatureLowC double precision,DewpointHighC double precision,DewpointAvgC double precision,DewpointLowC double precision,HumidityHigh double precision,HumidityAvg double precision);"
psql -U postgres -d whsc -c "COPY wu_ab FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/current_wu-AB-2017-09-16.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"
#wu - bc
psql -U postgres -d whsc -c "CREATE TABLE wu_bc (ID bigint,SubDate Date,TemperatureHighC double precision,TemperatureAvgC double precision,TemperatureLowC double precision,DewpointHighC double precision,DewpointAvgC double precision,DewpointLowC double precision,HumidityHigh double precision,HumidityAvg double precision);"
psql -U postgres -d whsc -c "COPY wu_bc FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/current_wu-BC-2017-09-16.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"

psql -U postgres -d whsc -c "ALTER TABLE ADD COLUMN precipsumcm double precision;" 

#tweets
#wu - bc
psql -U postgres -d whsc -c "CREATE TABLE tweets (tweetID serial primary key, tweetDate Date,tweetText varchar(255),tweetUser varchar(255), location varchar(255), url varchar(255));"
#psql -U postgres -d whsc -c "COPY tweets FROM '/Users/colinr23/Dropbox/nsercCREATE/Scraping/tweets/test_current-test.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"
psql -U postgres -d whsc -c "COPY tweets (tweetDate,tweetText,tweetUser, location, url)  FROM '/Users/colinr23/Dropbox/nsercCREATE/Scraping/tweets/repaired.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"
psql -U postgres -d whsc -c "DELETE * FROM tweets;"

#check if its running
launchctl list | grep com.whtDaily.getWeatherUW
#load and unload 
launchctl unload getWeather.plist
#launchctl load getWeather.plist
#launchctl unload processTweets.plist
#launchctl unload getWeeks.plist
#launchctl unload getWeather.plist
