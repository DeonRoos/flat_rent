library(shiny)
library(leaflet)

shinyUI(navbarPage(
  title = "Flat Rent",
  tags$head(
    tags$style(
      HTML("
      /* Global styles */
      body {
        background-color: #202123 !important;
        color: white;
      }

      /* Main panel styles */
      .mainPanel {
        background-color: #202123 !important;
      }

      /* Sidebar panel styles */
      .well {
        background-color: #202123 !important;
        border: 1px solid #00A68A !important;
      }

      /* Text color styles */
      h4, h6, p, .form-control-static, .text-output {
        color: white;
      }
      
      /* Custom CSS styles */
      .navbar .navbar-brand {
          font-size: 24px;
          color: #FFFFFF !important;
      }
      
      /* Navigation bar styles */
      .navbar {
        background-color: #444654;
        color: #00A68A; 
        font-weight: bold;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
        font-size: 20px;
      }

      /* Navigation bar styles */
      .navbar .nav > li > a:hover,
      .navbar .nav > li > a:focus {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
      }

      /* Navigation bar styles */
      .navbar .nav .active > a,
      .navbar .nav .active > a:hover,
      .navbar .nav .active > a:focus {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
      }

      /* Input styles */
      .form-control, .selectize-input, .shiny-input-container {
        background-color: #444654 !important;
        color: white !important;
        border: 1px solid #00A68A;
      }

      /* Action button styles */
      .btn {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 1px solid #00A68A;
      }

      /* Image container styles */
      .image-container {
        display: flex;
        justify-content: center;
      }

      /* Image styles */
      .image-container img {
        max-width: 100%;
        max-height: 800px;
        height: auto;
        width: auto;
      }

      /* Modal styles */
      .modal-content {
        background-color: #202123 !important;
        color: white !important;
        border: 1px solid #00A68A !important;
      }

      .modal-header {
        border-bottom: 1px solid #00A68A !important;
      }

      .modal-footer {
        border-top: 1px solid #00A68A !important;
      }

      /* Date picker styles */
      .datepicker {
        background-color: #444654 !important;
        color: white !important;
        border: 1px solid #00A68A !important;
      }

      .datepicker table {
        background-color: #444654 !important;
      }

      .datepicker table tr td.day:hover,
      .datepicker table tr td.day.focused {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker table tr td.active,
      .datepicker table tr td.active:hover,
      .datepicker table tr td.active.disabled,
      .datepicker table tr td.active.disabled:hover {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker table tr td.today {
        background-color: #444654 !important;
        color: #00A68A !important;
      }

      .datepicker table tr td.today:hover {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker table tr td span:hover {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker table tr td span.active {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker table tr td span.active:hover {
        background-color: #00A68A !important;
        color: white !important;
      }

      .datepicker .datepicker-switch {
        color: white !important;
      }

      .datepicker .next,
      .datepicker .prev {
        color: white !important;
      }

      .datepicker .next:hover,
      .datepicker .prev:hover {
        color: #00A68A !important;
      }
      ")
    )
  ),
  
  # Combined Prediction Tab
  tabPanel("Predict Rent",
           sidebarLayout(
             sidebarPanel(
               h3("Enter Property Details"),
               h5("Select Property Location"),
               leafletOutput("map", height = "600px"),
               br(),
               actionButton("open_modal", "Enter Property Details"),
               br(), br(),
               actionButton("predict", "Predict Price")
             ),
             mainPanel(
               h4("Prediction Results"),
               h5("Two models are used for predicting rent price. The first is a linear model (as you have learnt how to fit). The second is also a linear model which includes a 'non-linear interaction' to describe the spatial pattern (you will learn how to fit 'linear interactions' next week)."),
               htmlOutput("lmprediction"),
               br(),
               htmlOutput("prediction"),
               br()
             )
           )
  ),
  
  # Leaflet Map Tab
  tabPanel("Data",
           h3("Map of Aberdeen House Prices"),
           uiOutput("leaflet_map_price")
  ),
  
  # Image Tab for lm_plots
  tabPanel("Linear Model",
           h3("Variable Associations"),
           div(class = "image-container",
               img(src = "lm_plots.png")
           )
  ),
  
  # Image Tab for plot_maps and plot_figs
  tabPanel("Fancy model",
           h3("Spatial Association"),
           div(class = "image-container",
               img(src = "rent_maps.png")
           ),
           br(),
           div(class = "image-container",
               img(src = "rent_figs.png")
           )
  )
))
