# Cargar librerías necesarias

rm(list = ls())  # Limpia todas las variables de tu entorno actual
gc()  # Limpia la memoria

if ("plumber" %in% loadedNamespaces()) {
  detach("package:plumber", unload = TRUE)
}

if ("plumber" %in% rownames(installed.packages())) {
  remove.packages("plumber")
}

install.packages("plumber", dependencies = TRUE, show_col_types = FALSE)
library(plumber)
library(tidyverse)

# Cargar el modelo previamente entrenado
model <- readRDS("C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE/logistic_model.rds")
model_data <- read_csv("C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE/shuffled_combined_data.csv")  

# Create a new plumber router
pr <- plumber::plumber$new()


pr$handle("POST", "/predict", function(req, BRCA_GENE, AGE, INFERRED_MENOPAUSAL_STATE, HORMONE_THERAPY) {

  if (any(is.na(c(BRCA_GENE, AGE, INFERRED_MENOPAUSAL_STATE, HORMONE_THERAPY)))) {
    res$status <- 400
    return(list(error = "Todos los parámetros son obligatorios."))
  }
  
  # Dataframe con los parámetros del usuario
  input_data <- data.frame(
    BRCA_GENE = as.numeric(BRCA_GENE),
    AGE = as.numeric(AGE),
    INFERRED_MENOPAUSAL_STATE = as.numeric(INFERRED_MENOPAUSAL_STATE),
    HORMONE_THERAPY = as.numeric(HORMONE_THERAPY)
  )
  
  # Predecir probabilidades
  prediction <- predict(model, newdata = input_data, type = "response")
  
  # Devolver la probabilidad y clase predicha
  res <- list(
    cancer_probability = prediction,
    cancer_status = ifelse(prediction > 0.5, "Cancer", "Healthy")
  )
  
  return(res)
}

# Inicia el servidor

pr$run(port = 8000)


