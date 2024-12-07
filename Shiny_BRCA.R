library(shiny)
library(tidyverse)

# Define UI
ui <- fluidPage(
  titlePanel("Breast Cancer Prediction with BRCA Model"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("age", "Age:", value = 50, min = 20, max = 100),
      selectInput("menopause", "Menopause:", choices = list("Premenopausia" = 0, "Postmenopausia" = 1)),
      selectInput("hormone", "Hormone Therapy:", choices = list("No" = 0, "Sí" = 1)),
      selectInput("brca", "BRCA mutated:", choices = list("No" = 0, "Sí" = 1)),
      actionButton("predict", "Predict")
    ),
    
    mainPanel(
      h3("Probability of Breast Cancer:"),
      verbatimTextOutput("result")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Model trained earlier
  model <- glm(CANCER ~ BRCA_GENE + INFERRED_MENOPAUSAL_STATE + HORMONE_THERAPY + AGE, 
               family = binomial, 
               data = shuffled_data)
  
  # Prediction on user input
  observeEvent(input$predict, {
    user_data <- data.frame(
      BRCA_GENE = as.numeric(input$brca),
      INFERRED_MENOPAUSAL_STATE = as.numeric(input$menopause),
      HORMONE_THERAPY = as.numeric(input$hormone),
      AGE = as.numeric(input$age)
    )
    
    # Make prediction
    prediction <- predict(model, newdata = user_data, type = "response")
    
    # Output prediction
    output$result <- renderText({
      paste0("The probability of getting breast cancer is: ", round(prediction * 100, 2), "%")
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
