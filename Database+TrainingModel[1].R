install.packages("tidyverse")  # For data manipulation and visualization
install.packages("VIM")        # For KNN imputation
install.packages("ggcorrplot") # For the correlation heatmap visualization
install.packages('plumber')
library(tidyverse)
library(VIM)
library(ggcorrplot)
library(plumber)

# Read the data files
data_sample <- read_delim("data_clinical_sample.txt", delim = "\t", skip = 4, show_col_types = FALSE)
data_patient <- read_delim("data_clinical_patient.txt", delim = "\t", skip = 4, show_col_types = FALSE)

colnames(data_sample)
colnames(data_patient)

# Filter relevant columns
data_sample_filtered <- select(data_sample, "PATIENT_ID", "ONCOTREE_CODE")
data_patient_filtered <- select(data_patient, "PATIENT_ID", "AGE_AT_DIAGNOSIS", "INFERRED_MENOPAUSAL_STATE", "HORMONE_THERAPY")

# Merge datasets based on Patient ID
merged_data <- inner_join(data_sample_filtered, data_patient_filtered, by = "PATIENT_ID")
merged_data <- rename(merged_data, BRCA_GENE = ONCOTREE_CODE, ID = PATIENT_ID, AGE = AGE_AT_DIAGNOSIS)
merged_data$CANCER <- 1  # Label as cancer patients
merged_data$ID <- seq(1, nrow(merged_data))

# Handle missing values by imputing the mode for categorical variables and kNN for age
merged_data$INFERRED_MENOPAUSAL_STATE[is.na(merged_data$INFERRED_MENOPAUSAL_STATE)] <- 
  names(sort(table(merged_data$INFERRED_MENOPAUSAL_STATE), decreasing = TRUE))[1]

merged_data$HORMONE_THERAPY[is.na(merged_data$HORMONE_THERAPY)] <- 
  names(sort(table(merged_data$HORMONE_THERAPY), decreasing = TRUE))[1]

merged_data <- kNN(merged_data, variable = "AGE")
merged_data <- merged_data %>% select(-AGE_imp)  # Remove unnecessary KNN column

# Conversion to binary
merged_data$BRCA_GENE <- ifelse(grepl("BRCA", merged_data$BRCA_GENE), 1, 0)
merged_data$INFERRED_MENOPAUSAL_STATE <- ifelse(merged_data$AGE > 50, 1, 0)
merged_data$HORMONE_THERAPY <- ifelse(merged_data$HORMONE_THERAPY == "YES", 1, 0)

min_age <- min(merged_data$AGE, na.rm = TRUE)
max_age <- max(merged_data$AGE, na.rm = TRUE)
min_age
max_age
# Create synthetic healthy data with adjusted BRCA mutation prevalence
set.seed(123)  # Ensure reproducibility
num_healthy <- 2500  # Total number of healthy individuals to generate

age_distribution <- function(n) {
  # Define a hypothetical age distribution resembling the UK population
  age_bins <- c(20, 30, 40, 50, 60, 70, 80, 90, 100)
  probabilities <- c(0.167, 0.159, 0.166, 0.148, 0.138, 0.126, 0.072, 0.023, 0.001) # Adjust as needed
  sample(
    x = seq(20, 100, by = 1),
    size = n,
    prob = approx(x = age_bins, y = probabilities, xout = seq(20, 100))$y,
    replace = TRUE
  )
}

healthy_data <- data.frame(
  ID = seq(1, num_healthy),
  BRCA_GENE = c(rep(1, floor(0.003 * num_healthy)), rep(0, num_healthy - floor(0.003 * num_healthy))), # Simulate 5.2% BRCA prevalence
  AGE = age_distribution(num_healthy),
  HORMONE_THERAPY = sample(c(1, 0), num_healthy, replace = TRUE), # Simulate binary response
  INFERRED_MENOPAUSAL_STATE = ifelse(sample(20:100, num_healthy, replace = TRUE) > 50, 1, 0) # Postmenopausal state
)

# Assign cancer probabilities to BRCA carriers (90% probability if BRCA is present)
healthy_data$CANCER <- rbinom(n = nrow(healthy_data), size = 1, prob = 0.9 * healthy_data$BRCA_GENE)

# Combine the merged data and the healthy data
combined_data <- bind_rows(merged_data, healthy_data)

# Randomly shuffle the combined data to ensure no order bias
set.seed(456)
shuffled_data <- combined_data[sample(nrow(combined_data)), ]

# Save the shuffled dataset to a CSV file
write.csv(shuffled_data, "shuffled_combined_data.csv", row.names = FALSE)

# Visualize age distribution for cancer vs healthy individuals
ggplot(shuffled_data, aes(x = AGE, fill = as.factor(CANCER))) +
  geom_histogram(binwidth = 5, position = "identity", alpha = 0.7) +
  labs(title = "Age Distribution by Cancer Status", x = "Age at Diagnosis", y = "Frequency") +
  scale_fill_manual(values = c("skyblue", "orange"), labels = c("Healthy", "Cancer")) +
  theme_minimal()


# Generate a correlation matrix for all numerical variables
cor_matrix <- cor(shuffled_data %>% select(-ID))  # Exclude ID as it's not relevant for correlation
ggcorrplot(cor_matrix, lab = TRUE, title = "Correlation between Variables (Including CANCER)")

# Display basic statistics
summary(shuffled_data)

# Ensure no missing values exist in the shuffled dataset
colSums(is.na(shuffled_data))

### Train a Logistic Regression Model
# Split the data into training and testing sets
set.seed(789)
train_indices <- sample(nrow(shuffled_data), 0.7 * nrow(shuffled_data))
train_data <- shuffled_data[train_indices, ]
test_data <- shuffled_data[-train_indices, ]

# Fit a logistic regression model
model <- glm(CANCER ~ BRCA_GENE + AGE + INFERRED_MENOPAUSAL_STATE + HORMONE_THERAPY, 
             family = binomial, 
             data = train_data)

# Save the shuffled dataset to a CSV file
write_rds(model, file = file.path('C:/Users/wagne/Documents/UNI/MÀSTER/Q3/IB/PROJECTE',"logistic_model.rds"))

# Predict probabilities on test set
predictions <- predict(model, newdata = test_data, type = "response")

# Convert predicted probabilities into binary outcomes using 0.5 as threshold
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Confusion Matrix
conf_matrix <- table(Predicted = predicted_classes, Actual = test_data$CANCER)

# Display Model Accuracy, Sensitivity, and Specificity
cat("Model Accuracy:", sum(conf_matrix * diag(nrow(conf_matrix))) / sum(conf_matrix), "\n")
cat("Sensitivity:", conf_matrix[2,2] / sum(conf_matrix[2,]), "\n")
cat("Specificity:", conf_matrix[1,1] / sum(conf_matrix[1,]), "\n")


