library(shiny)
library(mgcv)
library(dplyr)
library(leaflet)

shinyServer(function(input, output, session) {
  
  # Load the pre-trained models
  model_path <- file.path("data", "model_m1.rds")
  model_m1 <- readRDS(model_path)
  lm_path <- file.path("data", "lm_m1.rds")
  lm_m1 <- readRDS(lm_path)
  
  # Reactive values for storing coordinates
  coords <- reactiveValues(lon = -2.105621720258337, lat = 57.16686874046701)
  
  # Initial leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = coords$lon, lat = coords$lat, zoom = 12)
  })
  
  # Update coordinates and add marker on map click
  observeEvent(input$map_click, {
    click <- input$map_click
    coords$lon <- click$lng
    coords$lat <- click$lat
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(lng = click$lng, lat = click$lat)
  })
  
  # Fancy Model Prediction
  observeEvent(input$predict, {
    new_data <- data.frame(
      lon = coords$lon,
      lat = coords$lat,
      sqmt = input$sqmt,
      rooms = input$rooms,
      epc = input$epc,
      tax = input$tax,
      days_since = 0
    )
    
    prediction <- predict(model_m1, new_data, se.fit = TRUE)
    expect_price <- round(prediction$fit)
    low_price <- round(prediction$fit - 1.96 * prediction$se.fit)
    upp_price <- round(prediction$fit + 1.96 * prediction$se.fit)
    
    output$prediction <- renderText({
      paste0(
        "<div style='text-align: center;'>",
        "<p style='font-size: 24px;'>The 'fancy' linear model predicts your property would be rented for:</p>",
        "<p style='font-size: 36px; font-weight: bold; color: #00A68A;'>£", format(expect_price, big.mark = ","), "</p>",
        "<p style='font-size: 18px;'>Price Range: £", format(low_price, big.mark = ","), " - £", format(upp_price, big.mark = ","), "</p>",
        "</div>"
      )
    })
    
    output$prediction_details <- renderUI({
      HTML(paste0(
        "<h4>Details Used for Prediction</h4>",
        "<ul>",
        "<li>Number of Rooms: ", input$rooms, "</li>",
        "<li>Square Meters: ", input$sqmt, "</li>",
        "<li>EPC Rating: ", input$epc, "</li>",
        "<li>Tax Band: ", input$tax, "</li>",
        "<li>Longitude: ", coords$lon, "</li>",
        "<li>Latitude: ", coords$lat, "</li>",
        "</ul>"
      ))
    })
  })
  
  # Linear Model Prediction
  observeEvent(input$predict, {
    new_data <- data.frame(
      sqmt = input$sqmt,
      rooms = input$rooms,
      epc = input$epc,
      tax = input$tax
    )
    
    lm_prediction <- predict(lm_m1, new_data, se.fit = TRUE)
    lm_expect_price <- round(lm_prediction$fit)
    lm_low_price <- round(lm_prediction$fit - 1.96 * lm_prediction$se.fit)
    lm_upp_price <- round(lm_prediction$fit + 1.96 * lm_prediction$se.fit)
    
    output$lmprediction <- renderText({
      paste0(
        "<div style='text-align: center;'>",
        "<p style='font-size: 24px;'>The linear model predicts your property would be rented for:</p>",
        "<p style='font-size: 36px; font-weight: bold; color: #00A68A;'>£", format(lm_expect_price, big.mark = ","), "</p>",
        "<p style='font-size: 18px;'>Price Range: £", format(lm_low_price, big.mark = ","), " - £", format(lm_upp_price, big.mark = ","), "</p>",
        "</div>"
      )
    })
    
    output$lmprediction_details <- renderUI({
      HTML(paste0(
        "<h4>Details Used for Prediction</h4>",
        "<ul>",
        "<li>Number of Rooms: ", input$rooms, "</li>",
        "<li>Number of Bathrooms: ", input$baths, "</li>",
        "<li>Square Meters: ", input$sqmt, "</li>",
        "<li>EPC Rating: ", input$epc, "</li>",
        "<li>Tax Band: ", input$tax, "</li>",
        "</ul>"
      ))
    })
  })
  
  # Render the saved Leaflet maps
  output$leaflet_map_price <- renderUI({
    tags$iframe(
      src = "abdn_map.html",
      width = "100%",
      height = "850px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
})
