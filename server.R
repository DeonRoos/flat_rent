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
  
  # Define the earliest date in your data
  earliest_date <- as.Date("2024-10-04")
  current_date <- Sys.Date()
  
  # Reactive values for storing coordinates and user inputs
  coords <- reactiveValues(lon = -2.105621720258337, lat = 57.16686874046701)
  user_inputs <- reactiveValues(
    Rooms = NULL,
    FloorArea = NULL,
    EPC = NULL,
    Tax = NULL,
    HouseType = NULL,
    Furnished = NULL,
    DayAdded = NULL
  )
  
  # Show modal dialog when the "Enter Property Details" button is clicked
  observeEvent(input$open_modal, {
    showModal(
      modalDialog(
        title = "Enter Property Details",
        numericInput("Rooms", "Number of Rooms:", value = 3),
        numericInput("FloorArea", "Square Meters:", value = 65),
        selectInput("EPC", "EPC Rating:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "C"),
        selectInput("Tax", "Tax Band:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "D"),
        selectInput("HouseType", "House Type:", choices = c("Flat", "Detached", "Semi-Detached", "Terraced"), selected = "Flat"),
        selectInput("Furnished", "Furnished:", choices = c("Unfurnished", "Fully furnished", "Part furnished"), selected = "Unfurnished"),
        dateInput("DayAdded", "Date Added:", value = current_date, min = earliest_date, max = current_date),
        footer = tagList(
          actionButton("submit", "Submit", class = "btn-primary"),
          modalButton("Cancel")
        )
      )
    )
  })
  
  # Store user inputs when the modal is submitted
  observeEvent(input$submit, {
    user_inputs$Rooms <- input$Rooms
    user_inputs$FloorArea <- input$FloorArea
    user_inputs$EPC <- input$EPC
    user_inputs$Tax <- input$Tax
    user_inputs$HouseType <- input$HouseType
    user_inputs$Furnished <- input$Furnished
    user_inputs$DayAdded <- input$DayAdded
    removeModal()
  })
  
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
    req(user_inputs$Rooms, user_inputs$FloorArea, user_inputs$EPC, user_inputs$Tax, user_inputs$HouseType, user_inputs$Furnished, user_inputs$DayAdded)
    
    new_data <- data.frame(
      Longitude = coords$lon,
      Latitude = coords$lat,
      FloorArea = user_inputs$FloorArea,
      Rooms = user_inputs$Rooms,
      EPC = user_inputs$EPC,
      Tax = user_inputs$Tax,
      HouseType = user_inputs$HouseType,
      Furnished = user_inputs$Furnished,
      DayAdded = as.numeric(difftime(user_inputs$DayAdded, Sys.Date(), units = "days"))
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
  })
  
  # Linear Model Prediction
  observeEvent(input$predict, {
    req(user_inputs$Rooms, user_inputs$FloorArea, user_inputs$EPC, user_inputs$Tax, user_inputs$HouseType, user_inputs$Furnished, user_inputs$DayAdded)
    
    new_data <- data.frame(
      FloorArea = user_inputs$FloorArea,
      Rooms = user_inputs$Rooms,
      EPC = user_inputs$EPC,
      Tax = user_inputs$Tax,
      HouseType = user_inputs$HouseType,
      Furnished = user_inputs$Furnished,
      DayAdded = as.numeric(difftime(user_inputs$DayAdded, Sys.Date(), units = "days"))
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
