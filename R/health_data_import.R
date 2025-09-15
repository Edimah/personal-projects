
library(xml2)
library(dplyr)
library(lubridate)

#######################
# Extracting xml file #
#######################

health_data <- read_xml("personal-projects/data/health_data_export.xml")

# Extract all node types
all_nodes <- xml_find_all(health_data, "//*")
n_nodes <- length(all_nodes)
print(paste("Number of different node types:", n_nodes))
node_types <- unique(xml_name(all_nodes))
print(paste("Total unique node types:", length(node_types)))
print("All unique node types:")
print(node_types, 20)


# Extract all <Record> nodes
records <- xml_find_all(health_data, "//Record")
number_records <- length(records)
print(paste("Number of records:", number_records))

# Explore various record types
record_types <- unique(xml_attr(records, "type"))
print("First 20 unique record types:")
print(head(record_types, 20))
print(paste("Total unique record types:", length(record_types)))

######################################
# Building CSV files out of xml data #
######################################


path_out <- "personal-projects/data"

# ------ XML to tibble for records -------

records_df <- tibble(
  record_id     = seq_along(records),
  type          = xml_attr(records, "type"),
  unit          = xml_attr(records, "unit"),
  value         = as.numeric(xml_attr(records, "value")),
  sourceName    = xml_attr(records, "sourceName"),
  sourceVersion = xml_attr(records, "sourceVersion"),
  device        = xml_attr(records, "device"),
  creationDate  = ymd_hms(xml_attr(records, "creationDate")),
  startDate     = ymd_hms(xml_attr(records, "startDate")),
  endDate       = ymd_hms(xml_attr(records, "endDate"))
)

full_path_records_csv <- file.path(path_out, "health_data_records.csv")
write.csv(records_df, full_path_records_csv, row.names = FALSE)


# ------ XML to tibble for workouts -------

workout_nodes <- xml_find_all(health_data, "//Workout")
workouts_df <- tibble::tibble(
      workout_id      = seq_along(workout_nodes),
      activity_type   = xml_attr(workout_nodes, "workoutActivityType"),
      sourceName      = xml_attr(workout_nodes, "sourceName"),
      sourceVersion   = xml_attr(workout_nodes, "sourceVersion"),
      device          = xml_attr(workout_nodes, "device"),
      creationDate_raw= xml_attr(workout_nodes, "creationDate"),
      startDate_raw   = xml_attr(workout_nodes, "startDate"),
      endDate_raw     = xml_attr(workout_nodes, "endDate"),
      duration_s      = as.numeric(xml_attr(workout_nodes, "duration")),
      totalDistance   = as.numeric(xml_attr(workout_nodes, "totalDistance"))
    )