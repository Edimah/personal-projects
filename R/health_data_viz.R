library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(viridis)

# Load the CSV files created in health_data_import.R
records <- read_csv("personal-projects/data/health_data_record.csv")
workouts <- read_csv("personal-projects/data/health_data_workout.csv")
activity <- read_csv("personal-projects/data/health_data_activitysummary.csv")

# Quick overview of the data
print(paste("Total records:", nrow(records)))
print(paste("Total workouts:", nrow(workouts)))
print(paste("Total activity summaries:", nrow(activity)))

# Example 1: Plotting step count over time from ActivitySummary
steps_data <- activity %>%
  filter(!is.na(appleExerciseTime) & !is.na(appleStandHours))
steps_data$date <- as.Date(steps_data$date)
ggplot(steps_data, aes(x = date)) +
  geom_line(aes(y = activeEnergy, color = "Active Energy Burned")) +
  geom_line(aes(y = exerciseTimeMin * 10, color = "Exercise Time (scaled)")) +
  geom_line(aes(y = standHours * 50, color = "Stand Hours (scaled)")) +
  scale_color_viridis(discrete = TRUE) +
  labs(title = "Activity Summary Over Time",
       x = "Date",
       y = "Values",
       color = "Metrics") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")