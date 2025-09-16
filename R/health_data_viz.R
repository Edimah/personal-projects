library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(viridis)

# Load & preview CSV files created in health_data_import.R

print("Records Data")
records <- read_csv("personal-projects/data/health_data_record.csv")
glimpse(records)        # Structure & column types
head(records, 3)        # First 3 rows
colnames(records)       # Just the column names

print("Workouts Data")
workouts <- read_csv("personal-projects/data/health_data_workout.csv")
glimpse(workouts)
head(workouts, 3)
colnames(workouts)

print("Activity Summary Data")
activity <- read_csv("personal-projects/data/health_data_activitysummary.csv")
glimpse(activity)
head(activity, 3)
colnames(activity)

##################################################
# Basic visualizations using ggplot2 and viridis #
##################################################

# Example 1: Plotting step count over time from ActivitySummary
steps_data <- activity %>%
  filter(!is.na(exerciseTimeMin) & !is.na(standHours))
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