# Load required library (no installation required)
library(MASS)
library(ggplot2)
library(dplyr)

# Suppress automatic plot device
options(device = "null")


# ---- Dataset ----
pima_all <- rbind(Pima.tr, Pima.te)
# write.csv(pima_all, "pima_all.csv", row.names = FALSE) 
# this is the data we are using (from MASS); (tr=training; te=test; but we are using the whole dataset)
# It contains health measurements from adult women of Pima Indian heritage 
# and the goal is to predict whether a patient has diabetes.
# this datset is not used in the below script but it is assumed that a colleague receiving the docker image
# has the input data for this script


# ---- Get CSV filename from environment variable ----
csv_filename <- Sys.getenv("CSV_FILE")

# Check if environment variable is set; with cat() you can print text to the command line for Docker users to read
if (csv_filename == "") {
  cat("\n✗ Error: CSV_FILE environment variable not set\n\n")
  cat("To use this container, set the CSV_FILE environment variable:\n\n")
  cat("Docker command on CLI:\n")
  cat("docker run -e CSV_FILE=pima_raw_data.csv -v .\Input:/input -v .\Output:/output imagename:1.0\n")
  cat("Or use DockerDesktop and set the environment variable under optional settings.")
  stop("CSV_FILE environment variable must be set")
}

# Build full path
# Within the running container, the script expects the file to be in a folder called "input"
# When using docker run, specify which of your local folder is mounted to "input" so the container can get your csv file
input_file <- file.path("/input", csv_filename)

# Check if file exists
if (!file.exists(input_file)) {
  cat("\n✗ Error: File not found at /input/", csv_filename, "\n\n", sep = "")
  cat("Make sure:\n")
  cat("1. The filename is correct: ", csv_filename, "\n", sep = "")
  cat("2. The file is in your mounted input folder\n")
  cat("3. The folder is mounted to /input\n\n")
  stop("CSV file not found: ", input_file)
}

cat("✓ Found data file:", csv_filename, "\n\n")

# ---- Read dataset ----
pima_imported <- read.csv(input_file)

# Inspect structure
cat("Your imported dataset has the following structure:\n")
str(pima_imported)

# ---- Basic metrics ----
summary_stats <- pima_imported %>%
  summarise(
    n_patients = n(),
    mean_age = mean(age, na.rm = TRUE),
    mean_bmi = mean(bmi, na.rm = TRUE),
    mean_glucose = mean(glu, na.rm = TRUE),
    diabetes_prevalence = mean(type == "Yes"),
    mean_glucose_diabetes = mean(glu[type == "Yes"], na.rm = TRUE),
    mean_glucose_no_diabetes = mean(glu[type == "No"], na.rm = TRUE)
  )

# ---- Save metrics ----
# file is saved within the container in the folder called "output"
# when running the container, you must mount a local folder onto "output", so those files get also saved locally
# and not just within the container that you cannot access after the script is done running
write.csv(summary_stats, "/output/pima_summary_metrics.csv", row.names = FALSE)

# ---- Plot ----
plot <- ggplot(pima_imported, aes(x = bmi, y = glu, color = type)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Relationship between BMI and Glucose by Diabetes Status",
    x = "BMI",
    y = "Glucose",
    color = "Diabetes"
  ) +
  theme_minimal()

# Save plot as PNG; file is saved in the "output" folder in the container
ggsave("/output/pima_bmi_glucose_plot.png", plot, width = 7, height = 5, device = "png")

# Close all graphics devices 
graphics.off()

cat("\n✓ Analysis complete!\n")
cat("Output files saved:\n")
cat("  - pima_summary_metrics.csv\n")
cat("  - pima_bmi_glucose_plot.png\n")
