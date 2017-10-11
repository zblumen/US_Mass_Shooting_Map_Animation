#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
#library(shinydashboard)
library(leaflet)
library(magrittr)
library(htmltools)
library(dygraphs)
library(xts)
load("msdata.RData")

shinyServer(function(input, output) {
   
        output$map <- leaflet::renderLeaflet({
        leaflet::leaflet(DATA$d
                        #, options = leafletOptions(minZoom=4)
                        ) %>%
          leaflet::addTiles() %>% 
          #setView(lng = -98.5, lat = 39.5, zoom = 5)
            setView(lng = -96.5, lat = 38.0, zoom = 4)
      })
        output$dgraph = renderDygraph({dygraph(DATA$annual_victims[,c(1,5)], 
                    main="Annual Fatalities", ylab="Death Toll", xlab="Year") %>%
            dySeries("Fatalities", label = "Fatalities") %>%
            dySeries("ma", label = "Moving Average") %>%
            dyRangeSelector(height = 20)
          })
        
        observeEvent(input$num_year, {
          ## plot the subsetted data
          eoy_date = DATA$annual_d$eoy[DATA$annual_d$year==input$num_year]
          dmap = DATA$d[DATA$d$rdate<=eoy_date,];
          leafletProxy("map") %>%
            clearMarkers() %>%
            leaflet::addCircleMarkers(lat = dmap$Latitude, lng = dmap$Longitude,
              radius = dmap$size,
              color = 'red',
              stroke = FALSE, fillOpacity = .5,
              label = paste0(dmap$Title," (",dmap$Date,"), ", dmap$Total.victims," TV")
            )
          ######################################################
        })
        output$death =  renderValueBox({
          temp_death = DATA$annual_d$Fatalities[ DATA$annual_d$year==input$num_year]
          if(length(temp_death)<1){temp_death=0}
          valueBox(tags$p(paste0(input$num_year," Fatalities: ",temp_death), style = "font-size: 45%;"),
            subtitle='', #icon = icon("times-circle"),
            color = "yellow")
        })
        output$total_death =  renderValueBox({
          temp_death = DATA$annual_d$Total_Fatalities[ DATA$annual_d$year==input$num_year]
          if(length(temp_death)<1){temp_death=0}
          valueBox(tags$p(paste0(input$num_year," Total Fatalities: ",temp_death), style = "font-size: 45%;"),
                   subtitle='', #icon = icon("times-circle"),
                   color = "red")
        })
        
})  

