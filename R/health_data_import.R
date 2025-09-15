
rm(list = ls())

library(xml2)
library(dplyr)
library(lubridate)

#######################
# Extracting xml file #
#######################

health_data <- read_xml("personal-projects/data/health_data_export.xml")

# Extract all <Record> nodes
records <- xml_find_all(health_data, "//Record")
number_records <- length(records)
print(paste("Number of records:", number_records))

# Explore various record types
record_types <- unique(xml_attr(records, "type"))
print("First 20 unique record types:")
print(head(record_types, 20))
print(paste("Total unique record types:", length(record_types)))

##############################################################
# Building CSV file out of xml data for heatmap visuaisation #
##############################################################


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

# ---- XML to tibble for metadata ----
metadata <- xml_find_all(records, ".//MetadataEntry")

metadata_df <- purrr::map_dfr(metadata, function(m) {
  tibble(
    record_id   = as.integer(xml_attr(xml_parent(m), "record_id")),
    parent_type = xml_attr(xml_parent(m), "type"),
    key         = xml_attr(m, "key"),
    value       = xml_attr(m, "value")
  )
})

full_path_metadata_csv <- file.path(path_out, "health_data_metadata.csv")
write.csv(records_df, full_path_metadata_csv, row.names = FALSE)