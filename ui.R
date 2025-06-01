library(shiny)
library(shinyjs)
library(shinyBS)
library(leaflet)

shinyUI(navbarPage(
  title = "Granite Rent Guide",
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
        width: 100%; /* Use full width */
        display: flex;
        justify-content: center;
        align-items: center;
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

  useShinyjs(),
  
  tabPanel(
    title = tagList(icon("chart-line"), "Predict Your Rent"),
    sidebarLayout(
      sidebarPanel(
        h3("Enter Property Details"),
        h5(tagList(icon("map-marker-alt"), "Select Property Location")),
        
        leafletOutput("map", height = "600px"),
        br(),
        
        actionButton("open_modal", label = tagList(icon("edit"), "Enter Property Details"), class = "btn"),
        actionButton("predict",    label = tagList(icon("chart-line"), "Predict Rent"), class = "btn", disabled = TRUE)
      ),
      mainPanel(
        h4("Prediction Results"),
        
        p("We run two models to predict rent: a simple linear model and a more flexible model (GAM). ",
          "The predicted price is shown in teal."),
        
        htmlOutput("lmPrediction"),
        br(),
        htmlOutput("fancyPrediction"),
        br(),
        uiOutput("prediction_details")
      )
    )
  ),

  navbarMenu(
    title = tagList(icon("chart-bar"), "Relationships"),
    tabPanel("Linear Model", div(class="image-container", img(src="lm_plots.png", style = "width: 100%; height: auto;"))),
    tabPanel("GAM (Heatmap)", div(class="image-container", img(src="rent_maps.png", style = "width: 100%; height: auto;"))),
    tabPanel("GAM (Figures)", div(class="image-container", img(src="rent_figs.png", style = "width: 100%; height: auto;")))
  ),
  
  tabPanel(
    title = tagList(icon("database"), "Rental Map"),
    uiOutput("leaflet_map_price")
  )
))
