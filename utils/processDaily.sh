#!/bin/bash

#process Twitter data in steps

for fe in /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/*BC.csv 
do 
  /usr/local/bin/psql -U postgres -d whsc -c "COPY wu_bc FROM '$fe' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"
done


for fe in /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/*BC.csv 
do
  mv $fe /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/processed
done
#process json into CSV file (get json files for previous day)
#run at 12:01 am
#move all from yesterday to current
#process, then move to processed
#update Twitter database table with new Tweets

#run scraper algorithm to update the mongo db and django web application

#move processed Tweets into processed directory


