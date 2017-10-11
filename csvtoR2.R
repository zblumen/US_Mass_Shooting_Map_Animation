rm(list=ls())
#library(data.table)
library(ggmap)
library(xts)
setwd("/home/zach/US_Mass_Shootings")
#read mass shooting data
#d = read.csv("Mass Shootings Dataset.csv",as.is=TRUE)
d = read.csv("Mass Shootings Dataset Ver 2.csv",as.is=TRUE)
#create a properly formatted date variable (could be useful later)
d$rdate = as.Date(d$Date, "%m/%d/%Y")
#sort earliest to latest.  Important for time series functionality later
d=d[order(d$rdate),]
#Searh google maps for missing latitude and longitudes
missing_latlon_ind = (is.na(d$Latitude) | is.na(d$Longitude) )
New_latlon = geocode(d$Location[missing_latlon_ind])
#assign new latitude and longitude
d$Latitude[missing_latlon_ind] = New_latlon$lat
d$Longitude[missing_latlon_ind] = New_latlon$lon
#save to RData file for easy loading in app

#create a normalized weight for sizing points on leaflet map in Rshiny
d$size = log(d$Total.victims)*2.5
#indicator for contental US
d$continental = !grepl("Alaska|Hawaii",d$Location)

############################################################
###create annual data.frame and time_series object.  This will be useful for displaying time series data and for widgets
d$year = as.numeric(format(d$rdate,"%Y"))
#create initial annual level data.frame with fatalities, injured and total victims
annual_staging = aggregate(d[,6:8],list(year=d$year),FUN=sum)
##in some years there were no shootings....we will imput zeros for these
year_vec=min(d$year):max(d$year)
zero_years=year_vec[!(year_vec %in% d$year)]
zero_rows=data.frame(year=zero_years, Fatalities=0L,Injured=0L,Total.victims=0L)
annual_d=rbind(annual_staging,zero_rows)
annual_d =annual_d[order(annual_d$year),]
#create cummulative sum for total fatalities
annual_d$Total_Fatalities =cumsum(annual_d$Fatalities)
#create moving average series for fatalities
ny = nrow(annual_d)
ma = numeric(ny)
ma[1]=mean(annual_d$Fatalities[1:2])
for(i in 2:(ny-1)){
  temp_ind=c(i-1,i,i+1)
  ma[i] = mean(annual_d$Fatalities[temp_ind])
}
ma[ny]=mean(annual_d$Fatalities[c(ny-1,ny)])
annual_d$ma = ma
#create "end of year" series.  This will be useful for the slidebar functionality
annual_d$eoy = as.Date(paste0("12/31/",annual_d$year), "%m/%d/%Y")
#create time series object from annual_d for output to dygraph
annual_victims =xts(annual_d[,2:6],order.by= as.Date(as.character(annual_d$year),"%Y"))
indexFormat(annual_victims ) <- "%Y"

########################################
#save Data in list to be loaded in shiny app
DATA=list(d=d,annual_victims=annual_victims,annual_d=annual_d)
save(DATA,file="msdata.RData")



