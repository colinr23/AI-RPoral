#!/bin/bash
#get ebird data
cd /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal
/usr/local/bin/Rscript /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/scripts/getEBird.R
#get soil moisture
echo "getting soil moisture data"
/usr/local/bin/Rscript /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/scripts/getSoilMoisture.R
#get poultry slaughter
echo "getting poultry slaughter data"
/usr/local/bin/Rscript /Users/colinr23/Dropbox/citsci/wht/AI-Portal/AI-RPortal/scripts/getPoultrySlaughter.R


