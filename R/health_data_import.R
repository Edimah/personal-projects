library(xml2)
library(dplyr)
library(purrr)
library(lubridate)

#######################
# Extracting XML file #
#######################

health_data <- read_xml("personal-projects/data/health_data_export.xml")

# Extract all node types
all_nodes <- xml_find_all(health_data, "//*")
n_nodes <- length(all_nodes)
print(paste("Number of different node types:", n_nodes))
node_types <- unique(xml_name(all_nodes))
print(paste("Total unique node types:", length(node_types)))
print("All unique node types:")
print(node_types)


# Extract all <Record> nodes
records <- xml_find_all(health_data, "//Record")
number_records <- length(records)
print(paste("Number of records:", number_records))

# Explore various record types
record_types <- unique(xml_attr(records, "type"))
print("First 20 unique record types:")
print(head(record_types, 20))
print(paste("Total unique record types:", length(record_types)))


########################
# Helper preview func  #
########################
preview_nodes <- function(xml, node_name, n = 5) {
  nodes <- xml_find_all(xml, paste0("//", node_name))
  if (length(nodes) == 0) {
    cat("\nNo <", node_name, "> nodes found\n")
    return(NULL)
  }
  # Extract first n nodes into a tibble of attributes
  preview <- map_dfr(head(nodes, n), ~ as.list(xml_attrs(.x))) %>% as_tibble()
  cat("\n--- Preview of <", node_name, "> (", length(nodes), " total) ---\n")
  print(preview)
  invisible(preview)
}

########################
# Run previews         #
########################

# Preview 5 examples from the main node types you found
node_types <- c("Record", "Workout", "WorkoutEvent", "WorkoutStatistics",
                "ActivitySummary", "InstantaneousBeatsPerMinute")

walk(node_types, ~ preview_nodes(health_data, .x, n = 5))

#################################################################
# Building CSV files out of xml data for node types of interest #
#################################################################

# Path for saving CSVs
path_out <- "personal-projects/data"

# List of node types you want to extract
node_types_of_interest <- c("Record", "Workout", "ActivitySummary")

# Function to convert nodes from XML to tibble (dataframe)
extract_nodes_to_tibble <- function(node_name, health_data) {
  nodes <- xml_find_all(health_data, paste0("//", node_name))
  if (length(nodes) == 0) return(NULL)

  # Different schemas per node type
  if (node_name == "Record") {
    return(tibble(
      record_id     = seq_along(nodes),
      type          = xml_attr(nodes, "type"),
      unit          = xml_attr(nodes, "unit"),
      value         = as.numeric(xml_attr(nodes, "value")),
      sourceName    = xml_attr(nodes, "sourceName"),
      sourceVersion = xml_attr(nodes, "sourceVersion"),
      device        = xml_attr(nodes, "device"),
      creationDate  = ymd_hms(xml_attr(nodes, "creationDate")),
      startDate     = ymd_hms(xml_attr(nodes, "startDate")),
      endDate       = ymd_hms(xml_attr(nodes, "endDate"))
    ))
  }

  if (node_name == "Workout") {
    return(tibble(
      workout_id     = seq_along(nodes),
      activity_type  = xml_attr(nodes, "workoutActivityType"),
      sourceName     = xml_attr(nodes, "sourceName"),
      sourceVersion  = xml_attr(nodes, "sourceVersion"),
      device         = xml_attr(nodes, "device"),
      creationDate   = ymd_hms(xml_attr(nodes, "creationDate")),
      startDate      = ymd_hms(xml_attr(nodes, "startDate")),
      endDate        = ymd_hms(xml_attr(nodes, "endDate")),
      duration_s     = as.numeric(xml_attr(nodes, "duration")),
      totalDistance  = as.numeric(xml_attr(nodes, "totalDistance")),
      totalEnergy    = as.numeric(xml_attr(nodes, "totalEnergyBurned"))
    ))
  }

  if (node_name == "ActivitySummary") {
    return(tibble(
      summary_id      = seq_along(nodes),
      date            = xml_attr(nodes, "dateComponents"),
      activeEnergy    = as.numeric(xml_attr(nodes, "activeEnergyBurned")),
      exerciseTimeMin = as.numeric(xml_attr(nodes, "appleExerciseTime")),
      standHours      = as.numeric(xml_attr(nodes, "appleStandHours"))
    ))
  }
}

# Loop through node types of interest
for (node_type in node_types_of_interest) {
  message("Processing node type: ", node_type)
  df <- extract_nodes_to_tibble(node_type, health_data)

  if (!is.null(df)) {
    filename <- paste0("health_data_", tolower(node_type), ".csv")
    out_path <- file.path(path_out, filename)
    write.csv(df, out_path, row.names = FALSE)
    message(" → Saved ", nrow(df), " rows to ", out_path)
  } else {
    message(" → Skipped (no schema defined)")
  }
}