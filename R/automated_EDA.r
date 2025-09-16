# ==============================
# Automated EDA Pipeline (R)
# ==============================

# This script performs automated exploratory data analysis (EDA) on a given dataset
# and generates a comprehensive HTML report using the DataExplorer and skimr packages.

library(DataExplorer)
library(skimr)

# ========= Adapt script =========

# Change these variables as needed
data_file_path <- "personal-projects/data/health_data_activitysummary.csv"
output_file_name <- "activitySummary_EDA_report.html"  # change as needed
report_title_name <- "Automated Activity Summary Health Data EDA Report" # change as needed

# ========= Load Data =========

df <- readr::read_csv(data_file_path)   # tibble
#df <- read.csv(data_file_path)   # data.frame (works the same)

# ========= DataExplorer Quick Report =========

# output directory
path_out <- "personal-projects/EDA Results"
create_report(
  df,
  output_file = output_file_name,
  output_dir = path_out,
  report_title = report_title_name 
)

# ========= Skimr summary (optional) =========
skim(df)  # text-based summary in console
