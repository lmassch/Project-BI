#* @apiTitle Breast Cancer Prediction API
#* @apiDescription This API predicts the probability of breast cancer based on BRCA gene status, hormone therapy usage, inferred menopausal state, and age. It also generates a visualization graph showing cancer probability as a function of age.
library(plumber)
library(ggplot2)
library(dplyr)
library(readr)
# Pretrained logistic regression model
model <- read_rds("C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE/logistic_model.rds")

# Prediction endpoint
#* @param BRCA_GENE The state of the BRCA gene (1 for mutated, 0 for not mutated)
#* @param HORMONE_THERAPY Whether the patient receives hormone therapy (1 for yes, 0 for no)
#* @param INFERRED_MENOPAUSAL_STATE Inferred menopausal state (1 for postmenopausal, 0 for premenopausal)
#* @param AGE The age of the patient 
#* @serializer json
#* @get /predict
function(BRCA_GENE, HORMONE_THERAPY, INFERRED_MENOPAUSAL_STATE, AGE, res) {
  # Validate input data
  if (any(is.na(c(BRCA_GENE, HORMONE_THERAPY, INFERRED_MENOPAUSAL_STATE, AGE)))) {
    res$status <- 400
    return(list(error = "All parameters are required and must be numeric."))
  }
  # Ensure binary inputs for BRCA_GENE, HORMONE_THERAPY, and INFERRED_MENOPAUSAL_STATE
  if (!BRCA_GENE %in% c(0, 1)||
      !HORMONE_THERAPY %in% c(0,1)||
      !INFERRED_MENOPAUSAL_STATE %in% c(0,1)){
    res$status <- 400
    return(list(error = 'BRCA_GENE, HORMONE THERAPY or INFERRED_MENOPAUSAL_STATE must be 0 or 1.'))
  }
  input_data <- data.frame(
    BRCA_GENE = as.numeric(BRCA_GENE),
    AGE = as.numeric(AGE),
    INFERRED_MENOPAUSAL_STATE = as.numeric(INFERRED_MENOPAUSAL_STATE),
    HORMONE_THERAPY = as.numeric(HORMONE_THERAPY)
  )
  
  # Make the prediction
  prediction <- predict(model, newdata = input_data, type = "response")
  
  # Return response
  list(
    cancer_probability = round(prediction * 100, 2),
    cancer_status = ifelse(prediction > 0.5, "Cancer", "Healthy")
  )
}

# Cancer probability graph endpoint
#* @param BRCA_GENE The state of the BRCA gene (1 for mutated, 0 for not mutated)
#* @param HORMONE_THERAPY Whether the patient receives hormone therapy (1 for yes, 0 for no)
#* @param INFERRED_MENOPAUSAL_STATE Inferred menopausal state (1 for postmenopausal, 0 for premenopausal)
#* @serializer png
#* @get /cancer-probability-plot
function(BRCA_GENE, INFERRED_MENOPAUSAL_STATE, HORMONE_THERAPY, res) {
  # Ensure binary inputs for BRCA_GENE, HORMONE_THERAPY, and INFERRED_MENOPAUSAL_STATE
  if (!BRCA_GENE %in% c(0, 1)||
      !HORMONE_THERAPY %in% c(0,1)||
      !INFERRED_MENOPAUSAL_STATE %in% c(0,1)){
    res$status <- 400
    stop("Error: BRCA_GENE, HORMONE_THERAPY, and INFERRED_MENOPAUSAL_STATE must be 0 or 1.")
  }
  # Validate input parameters
  if (missing(BRCA_GENE) || missing(INFERRED_MENOPAUSAL_STATE) || missing(HORMONE_THERAPY)) {
    res$status <- 400
    return(list(error = "BRCA_GENE, INFERRED_MENOPAUSAL_STATE, and HORMONE_THERAPY parameters are required."))
  }
  # Generate the plot for the specified range of ages
  ages <- seq(20, 100, by = 5)  # Define the age range (20 to 100 with steps of 5)
  # Create a data frame for predictions
  prediction_data <- data.frame(
    AGE = ages,
    BRCA_GENE = as.numeric(BRCA_GENE),
    INFERRED_MENOPAUSAL_STATE = as.numeric(INFERRED_MENOPAUSAL_STATE),
    HORMONE_THERAPY = as.numeric(HORMONE_THERAPY)
  )
  
  # Predict cancer probabilities for the specified age range
  prediction_data$CANCER_PROBABILITY <- predict(model, newdata = prediction_data, type = "response")
  
  # Generate the plot
  plot <- ggplot(prediction_data, aes(x = AGE, y = CANCER_PROBABILITY)) +
    geom_line(color = "blue", size = 1.2) +  # Smooth line to visualize trends
    geom_point(color = "blue", size = 3) +   # Highlight points for each age step
    labs(
      title = "Probability of Breast Cancer by Age",
      x = "Age",
      y = "Probability of Cancer"
    ) +
    theme_minimal() +
    theme(
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 12)
    ) +
    scale_y_continuous(limits = c(0, 1))  # Limit the Y-axis from 0 to 1
  
  print(plot)

}

