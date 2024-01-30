source(here("R/clean_data.R"))

# file <- file.choose()
remove_header("data/Block1-MR1_20hpf-20C-120523-1022_Oxygen_Start.xlsx") |>
  remove_additional_sensor_columns() |>
  remove_No_Sensor() # fixed

remove_header("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen_Middle.xlsx") |>
  remove_additional_sensor_columns() |>
  remove_No_Sensor() # fixed

remove_header("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen_End.xlsx") |>
  remove_additional_sensor_columns() |>
  remove_No_Sensor() # fixed

remove_header("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen_Partial.xlsx") |>
  remove_additional_sensor_columns() |>
  remove_No_Sensor() |> View()

remove_header("data/Block1-MR1_41hpf-12C-130523-1015_Oxygen_None.xlsx") |>
  remove_additional_sensor_columns() |>
  remove_No_Sensor() |>     
  create_elapsed_time() |> 
  create_date_time_cols() |> 
  change_data_formats()
  


reformat_sdr("data/Block1-MR1_41hpf-12C-130523-1015_Oxygen_None.xlsx")
