library(shiny)
library(mgcv)
library(dplyr)
library(leaflet)
library(shinyjs)
library(shinyBS)

shinyServer(function(input, output, session) {
  
  useShinyjs()
  
  lm_m1    <- readRDS(file.path("data", "lm_m1.rds"))
  model_m1 <- readRDS(file.path("data", "model_m1.rds"))
  
  earliest_date <- as.Date("2024-10-04")
  current_date  <- Sys.Date()
  
  coords <- reactiveValues(lon=-2.1056217, lat=57.1668687)
  form_data <- reactiveValues(
    Rooms=3, FloorArea=65,
    EPC="C", Tax="D",
    HouseType="Flat",
    Furnished="Unfurnished",
    DayAdded=current_date
  )
  
  createDetailsModal <- function() {
    modalDialog(
      title = "Enter Property Details",
      
      numericInput("Rooms", "Number of Rooms:", value=form_data$Rooms, min=1),
      bsTooltip("Rooms", "Number of total rooms (bedrooms + public rooms).",
                placement="right", trigger="hover"),
      
      numericInput("FloorArea", "Square Meters:", value=form_data$FloorArea, min=10),
      bsTooltip("FloorArea", "The floor area of the property (not the land).",
                placement="right", trigger="hover"),
      
      selectInput("EPC", "EPC Rating:", choices=c("A","B","C","D","E","F","G"),
                  selected=form_data$EPC),
      bsTooltip("EPC","Energy Performance Certificate rating: A (best) - G (worst).",
                placement="right",trigger="hover"),
      
      selectInput("Tax", "Tax Band:", choices=c("A","B","C","D","E","F","G"),
                  selected=form_data$Tax),
      bsTooltip("Tax","Council tax band: A (lowest) - G (highest).",
                placement="right", trigger="hover"),
      
      selectInput("HouseType","House Type:",
                  choices=c("Flat","Detached","Semi-Detached","Terraced"),
                  selected=form_data$HouseType),
      bsTooltip("HouseType","Type of property (e.g. flat, terraced).",
                placement="right",trigger="hover"),
      
      selectInput("Furnished","Furnished:",
                  choices=c("Unfurnished","Fully furnished","Part furnished"),
                  selected=form_data$Furnished),
      bsTooltip("Furnished","Furnishing status of the property.",
                placement="right", trigger="hover"),
      
      dateInput("DayAdded","Date Added:",value=form_data$DayAdded,
                min=earliest_date, max=current_date),
      bsTooltip("DayAdded","The date the property was (or will be) listed.",
                placement="right", trigger="hover"),
      
      footer=tagList(
        modalButton("Cancel"),
        actionButton("submit_details","Submit",class="btn btn-primary")
      )
    )
  }
  
  observeEvent(input$open_modal, {
    showModal(createDetailsModal())
  })
  
  observeEvent(input$submit_details, {
    if(is.null(input$Rooms) || input$Rooms<=0 ||
       is.null(input$FloorArea) || input$FloorArea<10) {
      showNotification("Please enter valid values (>=1 room, >=10 sqm).", type="error")
      shinyjs::disable("predict")
    } else {
      form_data$Rooms     <- input$Rooms
      form_data$FloorArea <- input$FloorArea
      form_data$EPC       <- input$EPC
      form_data$Tax       <- input$Tax
      form_data$HouseType <- input$HouseType
      form_data$Furnished <- input$Furnished
      form_data$DayAdded  <- input$DayAdded
      
      removeModal()
      showNotification("Property details submitted!", type="message")
      shinyjs::enable("predict")
    }
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% addTiles() %>% setView(lng=coords$lon, lat=coords$lat, zoom=12)
  })
  observeEvent(input$map_click, {
    coords$lon <- input$map_click$lng
    coords$lat <- input$map_click$lat
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(lng=coords$lon, lat=coords$lat)
  })
  
  output$leaflet_map_price <- renderUI({
    tags$iframe(src="abdn_map.html", width="100%", height="850px", frameborder="0", scrolling="yes")
  })
  observeEvent(input$predict, {
    
    new_data_lm <- data.frame(
      FloorArea = form_data$FloorArea,
      Rooms     = form_data$Rooms,
      EPC       = form_data$EPC,
      Tax       = form_data$Tax,
      HouseType = form_data$HouseType,
      Furnished = form_data$Furnished,
      DayAdded  = as.numeric(difftime(form_data$DayAdded, Sys.Date(), units="days"))
    )
    lm_pred    <- predict(lm_m1, new_data_lm, se.fit=TRUE)
    lm_exp     <- round(lm_pred$fit)
    lm_low     <- round(lm_pred$fit - 1.96*lm_pred$se.fit)
    lm_up      <- round(lm_pred$fit + 1.96*lm_pred$se.fit)
    
    output$lmPrediction <- renderText({
      paste0(
        "<div style='text-align:center;'>",
        "<p style='font-size:24px;'>The linear model predicts rent:</p>",
        "<p style='font-size:36px; color:#00A68A;'>£", format(lm_exp,big.mark=","), "</p>",
        "<p style='font-size:18px;'>Price Range: £",
        format(lm_low,big.mark=",")," - £", format(lm_up,big.mark=","), "</p>",
        "</div>"
      )
    })
    
    new_data_gam <- data.frame(
      Longitude=coords$lon, Latitude=coords$lat,
      FloorArea=form_data$FloorArea, Rooms=form_data$Rooms,
      EPC=form_data$EPC, Tax=form_data$Tax,
      HouseType=form_data$HouseType,
      Furnished=form_data$Furnished,
      DayAdded=as.numeric(difftime(form_data$DayAdded, Sys.Date(),units="days"))
    )
    fancy_pred <- predict(model_m1, new_data_gam, se.fit=TRUE)
    fancy_exp  <- round(fancy_pred$fit)
    fancy_low  <- round(fancy_pred$fit -1.96*fancy_pred$se.fit)
    fancy_up   <- round(fancy_pred$fit +1.96*fancy_pred$se.fit)
    
    output$fancyPrediction <- renderText({
      paste0(
        "<div style='text-align:center;'>",
        "<p style='font-size:24px;'>The fancy model (GAM) predicts rent:</p>",
        "<p style='font-size:36px; color:#00A68A;'>£", format(fancy_exp,big.mark=","), "</p>",
        "<p style='font-size:18px;'>Price Range: £",
        format(fancy_low,big.mark=",")," - £", format(fancy_up,big.mark=","),"</p>",
        "</div>"
      )
    })
    
    output$prediction_details <- renderUI({
      HTML(paste0(
        "<h4>Details Used for Prediction</h4><ul>",
        "<li>Location: (", round(coords$lat,3),", ", round(coords$lon,3),")</li>",
        "<li>Rooms: ", form_data$Rooms,"</li>",
        "<li>FloorArea: ", form_data$FloorArea," m^2</li>",
        "<li>EPC: ", form_data$EPC,"</li>",
        "<li>Tax: ", form_data$Tax,"</li>",
        "<li>HouseType: ", form_data$HouseType,"</li>",
        "<li>Furnished: ", form_data$Furnished,"</li>",
        "<li>Date Added: ", as.character(form_data$DayAdded),"</li>",
        "</ul>"
      ))
    })
  })
})
