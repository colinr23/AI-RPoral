---
title: "Avian Influenza Intelligence - Overview"
author: "Colin Robertson"
date: "April 1, 2018"
output: 
  html_document: 
    keep_md: yes
---

## Wildlife Health Intelligence Platform - Avian Influenza

This site includes scripts, markdown reports, and a shiny web app for acquiring, structuring, analyzing and reporting on environmental and social media data obtained in support of the WHIP project undertaken by Canadian Wildlife Health Cooperative. The actual datasets (residing either in the data folder or in an PostgreSQL database) were excluded from the repository for space constraints.

### Directory Structure
The WHIP portal here is implemented as an [R-project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects) in R-Studio. There are four directories in the base directory, as follows:

* apps - includes R file and data directory for report-dashboard - the Shiny web app developed to visualize and explore the extracted datasets
     +  report-dashboard
* data (excluded from repo version) - all data files in sub directories:
     +  basemap
     +  e-bird
     +  ndvi
     +  poultry
     +  snowice 
     +  soil moisture
     +  weather
          + temp
          + precip
* reports - weekly and periodic reports for analysis of environmental and social media data using r markdown
* scripts - R scripts for extracting and processing data
* utils - shell scripts for administration of data processing and database processes. These were actually run from one directly up, above the base of the AI-RPortal directory

### Operation
Each of the get* scripts in the scripts directory were designed to extract data on a regular schedule from each source. For most sources this was a weekly schedule (e.g., soil moisture, ndvi) while for weather data this was daily, and datasets were post-processed into weekly summarized for reporting. Tabular data were backed up as CSV files and were inserted into an operational postgreSQL database (database creation scripts are available outside of the R repo in the utils directory). Image data were stored on disk as geoTIF files, with file names indicating the date of extraction. Data processing included clipping to study areas, reprojecting, interpolating to continuous rasters (precip and temp), and aggregating to weekly data. These operations made the data useful for weekly analysis in the integrated risk matrix analysis. 

Social media data were extracted from Twitter from a python script using the Tweepy library while individual web scraping tools were developed using a combination of a python/scrapy framework and R. An operational example is provided in the R-scraper.R file which was used to extract over 10 years of AI reports (globally) from [the Poultry Site](http://www.thepoultrysite.com/bird-flu/bird-flu-news.php).
