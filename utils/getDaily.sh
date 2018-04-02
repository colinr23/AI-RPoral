#!/bin/bash
#get wunderground data every night at 11 pm
cd /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal

echo "starting script ..."
/usr/local/bin/Rscript /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/scripts/getWeatherProducts.R

/usr/local/bin/psql -U postgres -d whsc -c "COPY wu_ab FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/current_wu-AB.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"
/usr/local/bin/psql -U postgres -d whsc -c "COPY wu_bc FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/current_wu-BC.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"

#process wunderground data every night at 11 pm
d="$(date +'%Y%m%d')"
a="current_wu-AB.csv"
b="current_wu-BC.csv"

mv /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/$a /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/processed/$d$a
mv /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/$b /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/weather/processed/$d$b

#process json into CSV file (get json files for previous day)
#run at 12:01 am
#move all from yesterday to current
#process, then move to processed
#update Twitter database table with new Tweets

#run scraper algorithm to update the mongo db and django web application

#move processed Tweets into processed directory


