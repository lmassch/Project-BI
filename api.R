#* @apiTitle Breast Cancer Prediction
#* @apiDescription Hackaton IB 
library(plumber)
library(ggplot2)
library(dplyr)
library(readr)
#model <- readRDS("C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE/logistic_model.rds")
model_data <- read_csv("C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE/shuffled_combined_data.csv") 
#* @param BRCA_GENE The state of the BRCA gene (1 for mutated, 0 for not mutated)
#* @param HORMONE_THERAPY Whether the patient receives hormone therapy (1 for yes, 0 for no)
#* @param INFERRED_MENOPAUSAL_STATE Inferred menopausal state (1 for postmenopausal, 0 for premenopausal)
#* @param AGE The age of the patient 
#* @serializer json
#* @get /predict
function(BRCA_GENE, HORMONE_THERAPY, INFERRED_MENOPAUSAL_STATE, AGE) {
  model <- glm(CANCER ~ BRCA_GENE + INFERRED_MENOPAUSAL_STATE + HORMONE_THERAPY + AGE, 
               family = binomial, 
               data = model_data)
  input_data <- data.frame(
    BRCA_GENE = as.numeric(model_data$BRCA_GENE),
    AGE = as.numeric(model_data$AGE),
    INFERRED_MENOPAUSAL_STATE = as.numeric(model_data$INFERRED_MENOPAUSAL_STATE),
    HORMONE_THERAPY = as.numeric(model_data$HORMONE_THERAPY)
  )
  prediction <- predict(model, newdata = input_data, type = "response")
  list(
    cancer_probability = round(prediction*100,2),
    cancer_status = ifelse(prediction > 0.5, "Cancer", "Healthy")
  )
} 
#* @param BRCA_GENE The state of the BRCA gene (1 for mutated, 0 for not mutated)
#* @param HORMONE_THERAPY Whether the patient receives hormone therapy (1 for yes, 0 for no)
#* @param INFERRED_MENOPAUSAL_STATE Inferred menopausal state (1 for postmenopausal, 0 for premenopausal)
#* @param AGE The age of the patient 
#* @serializer png
#* @get /cancer-probability-plot
function(BRCA_GENE, INFERRED_MENOPAUSAL_STATE, HORMONE_THERAPY) {
  # Filtrar los datos existentes
  filtered_data <- model_data %>%
    filter(
      BRCA_GENE == model_data$BRCA_GENE,
      INFERRED_MENOPAUSAL_STATE == model_data$INFERRED_MENOPAUSAL_STATE,
      HORMONE_THERAPY == model_data$HORMONE_THERAPY
    )
  }
  filtered_data$CANCER_PROBABILITY <- predict(model, newdata = filtered_data, type = "response")
  plot <- ggplot(filtered_data, aes(x = AGE, y = CANCER_PROBABILITY)) +
    geom_point(color = "blue", size = 2) +
    geom_smooth(method = "loess", color = "red") +
    labs(
      title = "Probabilidad de Cáncer según la Edad",
      x = "Age",
      y = "Probability of cancer"
    ) +
    theme_minimal()
  # Guardar la gráfica como imagen temporal
  tmp <- tempfile(fileext = ".png")
  ggsave(tmp, plot = plot, device = "png", width = 8, height = 6)
  readBin(tmp, "raw", n = file.info(tmp)$size)

