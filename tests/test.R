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
