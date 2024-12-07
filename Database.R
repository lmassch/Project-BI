install.packages("tidyverse") # Install if not already installed
library(tidyverse)

# Read data files
data_sample <- read_delim("data_clinical_sample.txt", delim = "\t", skip = 4, show_col_types = FALSE)
data_patient <- read_delim("data_clinical_patient.txt", delim = "\t", skip = 4, show_col_types = FALSE)

colnames(data_sample)
colnames(data_patient)

str(data_sample)
str(data_patient)

# Select relevant columns from data_sample
data_sample_filtered <- select(data_sample, "PATIENT_ID", "ONCOTREE_CODE")

# Select relevant columns from data_patient
data_patient_filtered <- select(data_patient, "PATIENT_ID", "AGE_AT_DIAGNOSIS", "INFERRED_MENOPAUSAL_STATE", "HORMONE_THERAPY")

# Merge datasets based on #Patient Identifier
merged_data <- inner_join(data_sample_filtered, data_patient_filtered, by = "PATIENT_ID")
merged_data <- rename(merged_data, BRCA_GENE = ONCOTREE_CODE, ID = PATIENT_ID, AGE = AGE_AT_DIAGNOSIS)
merged_data$CANCER <- 1
merged_data$ID <- seq(1, 2509)

colSums(is.na(merged_data))
filas_con_na <- merged_data[apply(is.na(merged_data), 1, any), ]
print(filas_con_na)
merged_data <- na.omit(merged_data)

merged_data

# Replace Oncotree Code values with 1, 0, or NaN
merged_data$BRCA_GENE <- ifelse(
  grepl("BRCA", merged_data$BRCA_GENE), 
  1, 
  ifelse(merged_data$BRCA_GENE == "", NaN, 0)
)

# Count occurrences of each Oncotree Code category
category_counts <- table(merged_data$BRCA_GENE)
print(category_counts)

# Histogram for Age
ggplot(merged_data, aes(x = AGE)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Age Distribution", x = "Age at Diagnosis", y = "Frequency")

# Calculate the minimum and maximum age
min_age <- min(merged_data$AGE, na.rm = TRUE)
max_age <- max(merged_data$AGE, na.rm = TRUE)

# Print the results
cat("Minimum Age:", min_age, "\n")
cat("Maximum Age:", max_age, "\n")

# Load necessary libraries
library(dplyr)

# Set the number of healthy individuals
num_healthy <- 2500


# Generate synthetic healthy data
set.seed(123) # for reproducibility
healthy_data <- data.frame(
  ID = seq(1, num_healthy),
  BRCA_GENE = c(rep(1, 45), rep(0, num_healthy - 45)), # 45/(45+133)=25%
  AGE = sample(20:100, num_healthy, replace = TRUE),
  HORMONE_THERAPY = sample(c("YES", "NO"), num_healthy, replace = TRUE),
  CANCER = 0 # Healthy individuals
)

healthy_data$INFERRED_MENOPAUSAL_STATE <- ifelse(healthy_data$AGE > 50, "Post", "Pre")

ggplot(healthy_data, aes(x = AGE)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Age Distribution", x = "Age at Diagnosis", y = "Frequency")

# View the first few rows of the synthetic healthy dataset
head(healthy_data)

combined_data <- bind_rows(merged_data, healthy_data)
combined_data
# Randomly shuffle the combined dataset
set.seed(456) # for reproducibility
shuffled_data <- combined_data[sample(nrow(combined_data)), ]

# View the first few rows of the shuffled combined data
head(shuffled_data)

# Save to CSV if needed
write.csv(shuffled_data, "shuffled_combined_data.csv", row.names = FALSE)

ls(
)

