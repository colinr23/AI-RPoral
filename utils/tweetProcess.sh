#!/bin/bash

#call processToCSV
/usr/bin/python /Users/colinr23/Dropbox/nserccreate/scraping/tweets/process.py

#call cleanCSV
/usr/bin/python /Users/colinr23/Dropbox/nserccreate/scraping/tweets/clean-csv.py

#copy current csv to table
/usr/local/bin/psql -U postgres -d whsc -c "COPY tweets (tweetDate,tweetText,tweetUser, location, url)  FROM '/Users/colinr23/Dropbox/nsercCREATE/Scraping/tweets/repaired.csv' WITH (FORMAT CSV, DELIMITER ',', NULL 'NA', HEADER);"

/usr/local/bin/psql -U postgres -d whsc -c "DELETE FROM tweets WHERE tweetID IN (SELECT tweetID FROM (SELECT tweetID, ROW_NUMBER() OVER (partition BY tweetText, tweetDate ORDER BY tweetID) AS rnum FROM tweets) t WHERE t.rnum > 1);"