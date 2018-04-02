#!/bin/bash

#update e-bird data****************
    #insert records NOTE::: AS OF 2019-01-11 THIS FAILS BECAUSE THERE IS ARE TWO LOCID FIELDS BEING ADDED.. API CHANGE?
for fe in /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/e-bird/*.shp 
do 
  /usr/local/bin/shp2pgsql -a -I -S -s 3347 $fe ebird | /usr/local/bin/psql -U postgres -d whsc
done
    
#move shps to processed
for fe in /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/e-bird/*.*
do
  mv $fe /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/e-bird/processed
done


#update soil moisture data
#for fe in /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/soilmoisture/*M5.tif
#do
#  mv $fe /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/soilmoisture/processed
#done

#update poultry data
#delete all records from poultry table
#/usr/local/bin/psql -U postgres -d whsc -c "DELETE FROM poultry;"

#copy current csv to table
#/usr/local/bin/psql -U postgres -d whsc -c "COPY poultry FROM '/Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/data/poultry/poultry.csv' DELIMITER ',' CSV HEADER;"