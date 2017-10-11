
library(shiny)
library(leaflet)
library(shinydashboard)
library(magrittr)
library(htmltools)
library(dygraphs)
library(xts)
load("msdata.RData")
dashboardPage(
  dashboardHeader(title = "320 US Mass Shootings", titleWidth = 350,
                  tags$li(class="dropdown",
                          tags$a(href="https://www.kaggle.com/zusmani/us-mass-shootings-last-50-years", 
                                 "Data Link", style = "font-size:90%;color:rgb(24,33,48);font-weight:bold;"))),
  dashboardSidebar( width = 10),
  dashboardBody(  #tags$head( 
   # tags$style(HTML(".fa { font-size: 36px; }"))
 # ),
    tags$style(type = "text/css", "#map {height: calc(100vh - 300px) !important;}"),#use 80px for full screen
    fluidRow(tags$style("#death,#total_death {min-width:250px;}"),
              column(3,valueBoxOutput("death"),align="center"),
              column(3,valueBoxOutput("total_death"),align="center")
             ,column(6,sliderInput("num_year", "Date Range (Press Play):",
                min = min(DATA$annual_d$year), max = max(DATA$annual_d$year),
                value =  min(DATA$annual_d$year),# as.Date("01/1/1967", "%m/%d/%Y"), 
                step = 1, sep = "",
                animate = animationOptions(interval=250,loop=FALSE)
    ),align="center")),
    fluidRow(leafletOutput("map")),
   fluidRow(dygraphOutput("dgraph"))
  )
)

