###############################################################################
# Animated Maps in R
#
# Author: Vivek Katial
# Created 2019-03-01 22:03:45
###############################################################################


# Setup and Libraries -----------------------------------------------------

library(shiny)
library(leaflet)
library(sp)
library(tidyverse)
library(xts)

# Import RDS file containing route information
d_routes <- read_csv("greenet_shiny/data/enriched_data.csv")

d_test <- d_routes %>%
    slice(1:1000)

gcIntermediate(
    p1 = d_test %>% select(start_lng, start_lat) %>% as.matrix(),
    p2 = d_test %>% select(dest_lng, dest_lat) %>% as.matrix(),
    n = 100,
    addStartEnd=TRUE,
    sp=TRUE
) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.DarkMatterNoLabels) %>%
    addPolylines(weight = 1)

# Shiny App ---------------------------------------------------------------

ui <- fluidPage(

  sliderInput(
    "time",
    "date",
    min(d_routes$request_time) %>% as.Date(),
    max(d_routes$request_time) %>% as.Date(),
    value = max(d_routes$request_time) %>% as.Date(),
    step=14,
    animate=T
  ),

  leafletOutput("map")
)

server <- function(input, output, session) {

  points_full <- reactive({
    #browser()
    # Clean trip data
    d_show <- d_routes %>%
      filter(city == input$city)

    # Check if any trips present otherwise return NULL
    if (nrow(d_show) > 0) {

      # store in DF
      d_show <- d_show %>% unnest(route)

      # Convert to SP obj
      split_data = lapply(
        unique(d_show$trip),
        function(x) {
          df = as.matrix(d_show[d_show$trip == x, c("lon", "lat")])
          lns = Lines(Line(df), ID = x)
          return(lns)
        }
      )

      # Convert to SP lines so it can be plotted
      data_lines = SpatialLines(split_data)

    } else {
      NULL
    }

  })

  points <- reactive({

    # Clean trip data
    d_show <- d_routes %>%
      filter(city == "Auckland") %>%
      filter(request_time <= (input$time))

    # Check if any trips present otherwise return NULL
    if (nrow(d_show) > 0) {

      # store in DF
      d_show <- d_show %>% unnest(route)

      # Convert to SP obj
      split_data = lapply(
        unique(d_show$trip),
        function(x) {
          df = as.matrix(d_show[d_show$trip == x, c("lon", "lat")])
          lns = Lines(Line(df), ID = x)
          return(lns)
        }
      )

      # Convert to SP lines so it can be plotted
      data_lines = SpatialLines(split_data)

    } else {
      NULL
    }

  })

  output$map <- renderLeaflet({
    # Base map
    leaflet(points_full()) %>%
      addProviderTiles(providers$CartoDB.DarkMatterNoLabels)

  })

  observe({
    req(!is.null(points()))
    # create the map
    leafletProxy("map", data = points()) %>%
      clearShapes() %>%
      addPolylines(weight = 1, color = "orange") %>%
      fitBounds(
        points_full()@bbox[1],
        points_full()@bbox[2],
        points_full()@bbox[3],
        points_full()@bbox[4]
      )
  })


}

shinyApp(ui, server)
