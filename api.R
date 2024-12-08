#* @apiTitle Breast Cancer Prediction API
#* @apiDescription This API predicts the probability of breast cancer based on BRCA gene status, hormone therapy usage, inferred menopausal state, and age. It also generates a visualization graph showing cancer probability as a function of age.

library(plumber)
library(ggplot2)
library(dplyr)
library(readr)

# Load the model data
model_data <- read_csv("shuffled_combined_data.csv")

# Pretrained logistic regression model
model <- glm(CANCER ~ BRCA_GENE + INFERRED_MENOPAUSAL_STATE + HORMONE_THERAPY + AGE, 
             family = binomial, 
             data = model_data)

# Prediction endpoint
#* @param BRCA_GENE The state of the BRCA gene (1 for mutated, 0 for not mutated)
#* @param HORMONE_THERAPY Whether the patient receives hormone therapy (1 for yes, 0 for no)
#* @param INFERRED_MENOPAUSAL_STATE Inferred menopausal state (1 for postmenopausal, 0 for premenopausal)
#* @param AGE The age of the patient 
#* @serializer json
#* @get /predict
function(BRCA_GENE, HORMONE_THERAPY, INFERRED_MENOPAUSAL_STATE, AGE) {
  # Validate input data
  if (any(is.na(c(BRCA_GENE, HORMONE_THERAPY, INFERRED_MENOPAUSAL_STATE, AGE)))) {
    res$status <- 400
    return(list(error = "All parameters are required and must be numeric."))
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
function(BRCA_GENE, INFERRED_MENOPAUSAL_STATE, HORMONE_THERAPY) {
  # Validate input parameters
  if (missing(BRCA_GENE) || missing(INFERRED_MENOPAUSAL_STATE) || missing(HORMONE_THERAPY)) {
    res$status <- 400
    return(list(error = "BRCA_GENE, INFERRED_MENOPAUSAL_STATE, and HORMONE_THERAPY parameters are required."))
  }
  
  # Filter the data based on the input parameters
  filtered_data <- model_data %>%
    filter(
      BRCA_GENE == as.numeric(BRCA_GENE),
      INFERRED_MENOPAUSAL_STATE == as.numeric(INFERRED_MENOPAUSAL_STATE),
      HORMONE_THERAPY == as.numeric(HORMONE_THERAPY)
    )
  
  # If no data matches the filter, return an error
  if (nrow(filtered_data) == 0) {
    res$status <- 400
    return(list(error = "No data matches the provided parameters."))
  }
  
  # Predict cancer probabilities for the filtered data
  filtered_data$CANCER_PROBABILITY <- predict(model, newdata = filtered_data, type = "response")
  
  # Generate the plot
  plot <- ggplot(filtered_data, aes(x = AGE, y = CANCER_PROBABILITY)) +
    geom_point(color = "blue", size = 2) +  
    geom_smooth(color = "black", size = 0.8) +  
    labs(
      title = "Probability of Breast Cancer by Age",
      x = "Age",
      y = "Probability of Cancer"
    ) +
    theme_minimal() +
    theme(
      axis.title.x = element_text(face = "bold", size = 12),
      axis.title.y = element_text(size = 12)
    ) +
    scale_y_continuous(limits = c(0, 1))  # Limit the Y-axis from 0 to 1
  
  # Render the graphic directly as a PNG image
  tmp_file <- tempfile(fileext = ".png")
  png(tmp_file, width = 800, height = 600, units = "px", res = 72)
  print(plot)
  dev.off()
  
  # Read the image and send it as a reply
  readBin(tmp_file, "raw", n = file.info(tmp_file)$size)
}

