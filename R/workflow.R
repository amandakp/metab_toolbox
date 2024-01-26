# Install/Load packages
# install.packages("pacman")
pacman::p_load(readxl, dplyr, purrr, lubridate, stringr, readr)

# Load functions 
source("R/clean_data.R")
source("R/guess.R")

# Locate files
raw_files_paths <- file.path("data/", list.files("data/"))


# 1. Reformat your files in bulk
walk(raw_files_paths,
     ~reformat_sdr(.x, output = "output/processed/")
)

processed <- map(raw_files_paths,
     ~reformat_sdr(.x)
)


# 2. Guess and rename blanks







data <- reformat_sdr("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen.xlsx") 


  rename_blanks(c(A3, B3, C3, D3, A6, B6, D6, C6, D1, D4, C2, C5)) 

detect_subjects(data)

data_no_sensor <- 
  remove_header("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen.xlsx") |> 
  remove_additional_sensor_columns() |> 
  remove_No_Sensor() 

data_no_sensor |> filter(if_any(everything(), ~is.na(.)))


  create_elapsed_time() |> 
  create_date_time_cols() 

data |> 
  rename_blanks(c(A3, B3, C3, D3, A6, B6, D6, C6, D1, D4, C2, C5)) 

  







