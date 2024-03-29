#' Reformat SDR output 
#'
#' @param file 
#'
#' @return
#' @export
#'
#' @examples
reformat_sdr <- function(file,
                         output = NULL){
  processed <- remove_header(file) |> 
    remove_additional_sensor_columns() |> 
    remove_No_Sensor() |> 
    create_elapsed_time() |> 
    create_date_time_cols() |> 
    change_data_formats()
  
  # Save the output as a .csv
  if(!is.null(output)){
    # Determine file names
    file_nms <- stringr::str_extract(file, stringr::regex(".*(?=.xlsx)")) |> 
      stringr::str_split(pattern = "/") |> purrr::pluck(1)
    
    # Best guess at the original file name
    file_nm <- file_nms[length(file_nms)]
    
    # Check if it ends with /
    if(stringr::str_detect(output, "/$", negate = TRUE)){
      output_path <- paste0(output,"/")
    } else output_path <- output
    
    # Check if output path exists
    if(file.exists(output_path)){
      readr::write_csv(data, paste0(output_path,file_nm,"_reformatted.csv"))
    } else {
      dir.create(output)
      readr::write_csv(data, paste0(output_path,file_nm,"_reformatted.csv"))
    }
  }
  
  return(processed)
}


#' Remove header of SDR output file
#'
#' @param file 
#' @param output path to save output
#' @return
#' @export
#'
#' @examples
remove_header <- function(file = "data/Block1-MR1_20hpf-20C-120523-1015_Oxygen.xlsx"){
  
  # Read in file
  suppressMessages(
  raw <- readxl::read_xlsx(file) |> data.frame()
  )
  
  # Remove the header
  #Identify row that starts with Date/Time in first column
  start <- stringr::str_which(raw[,1], pattern = stringr::regex("^Date/"))

  # Remove header
  no_header <- raw[-c(1:(start - 1)),] 
  
  # Replace column names with values in first row
  names(no_header) <- no_header[1,]
  
  # Delete first row
  data <- no_header[-1,] |> tibble::tibble()
  
  return(data)
}

#' Title
#'
#' @param data 
#' @param output 
#'
#' @return
#' @export
#'
#' @examples
remove_additional_sensor_columns <- function(data){
  # Detect where the NA is, this is where the gap between data and sensor data starts
  start <- stringr::str_which(names(data), "NA")
  bad_cols <- start:length(names(data))
  
  #Remove bad columns
  data_no_scols <- data[,-c(bad_cols)]
  
  return(data_no_scols)
}


#' Remove 'No Sensor' rows
#'
#' @param data 
#' @param output path to save output
#' @return
#' @export
#'
#' @examples
remove_No_Sensor <- function(data,
                             replace = NA_character_){
  # Detect No Sensor row
  detect <- lapply(data, grep, pattern = 'No Sensor') 
  
  # Start of No Sensor
  row_starts <- purrr::map(detect,
             ~dplyr::first(.x)) |> 
    purrr::map(purrr::discard, is.na) |> 
    purrr::compact() |> 
    purrr::list_transpose() |> 
    purrr::pluck(1) |> 
    unname() |> 
    unique()
  
  # End of No Sensor
  row_ends <- purrr::map(detect,
                         ~dplyr::last(.x)) |> 
    purrr::map(purrr::discard, is.na) |> 
    purrr::compact() |> 
    purrr::list_transpose() |> 
    purrr::pluck(1) |> 
    unname() |> 
    unique()
  
  
  # When data contains no No Sensor
  if(is.null(row_starts)){ 
    replaced_data <- data 
    message("There are no `No Sensor` values in this dataset")
    return(replaced_data)
  }
  
  # Partial No Sensor
  if(length(row_starts) > 1){
    warning("`No Sensor` detected for some vials, replacing `No Sensor` with NA")
    partial_no_sensor_row <- data[min(row_starts),] 
    
    # Replace No Sensor with NA
    replaced <- apply(partial_no_sensor_row, c(1,2), function(x) gsub("No Sensor",NA_character_, x)) |> tibble::tibble()
    replaced_row <- replaced$`apply(...)`  |> tibble::as_tibble()
    
    top_part <- data[1:min(row_starts) - 1,]
    
    replaced_data <- bind_rows(top_part, replaced_row) |> 
      dplyr::arrange(`Time/Min.`)
      
    names(replaced_data) <- names(data)
    return(replaced_data)
  } 
  
  # When data starts with No Sensor
  if(length(row_starts) > 0 & row_starts == 1 & row_ends < nrow(data)) {
      replaced_data <- data[-c(row_starts:row_ends),]
      return(replaced_data)
    }
  
  # When No Sensor is in the middle of the sheet
  if(length(row_starts) > 0 & row_ends < nrow(data)){
    replaced_data <- data[-c(row_starts:row_ends),]
    return(replaced_data)
  }
    
  # When No Sensor is in the end of the sheet
  if(length(row_starts) > 0 & row_ends == nrow(data)){
    replaced_data <- data[-c(row_starts:row_ends),]
    return(replaced_data)
  }
  
  
}
  
#' Rename empty vials sequentially
#'
#' @param data 
#'
#' @return
#' @export
#'
#' @examples
rename_blanks <- function(data,
                          blank_cols,
                          replace_name = "control"){
  # Select the blank lanes
  blanks <- data |> 
    dplyr::select({{blank_cols}}) 
  
  # Retain original names 
  original_names <- names(blanks)
  
  # Create new names, holding info about old names 
  new_names <- paste0(replace_name, "_", original_names)
  
  # Rename the blank lanes data
  names(blanks) <- new_names
  
  # Grab all non-blank data
  data |> 
    dplyr::select(-{{blank_cols}}) |> 
    dplyr::bind_cols(blanks)
}

#' Create elapsed time column
#'
#' @param data 
#'
#' @return
#' @export
#'
#' @examples
create_elapsed_time <-function(data){
  data |> 
    dplyr::rename(elapsed_time = `Time/Min.`) |> 
    dplyr::mutate(elapsed_time = round(as.numeric(elapsed_time),2))
}


#' Create seperate columns for date and time
#'
#' @param data 
#'
#' @return
#' @export
#'
#' @examples
create_date_time_cols <- function(data){
  # Split up date string
  list_dt <- stringr::str_split(data$`Date/Time`, " ") 
  
  # Extract dates
  dates <- purrr::map(list_dt,
                      purrr::pluck(1)) |> 
    purrr::list_c()
  
  # Replace seperators . with / 
  date_slash <- stringr::str_replace_all(dates, "\\.", "/")
  
  # Treat dates as dates
  date_correct <- lubridate::dmy(date_slash)
  
  # Extract times
  times <- purrr::map(list_dt,
                      purrr::pluck(2)) |> 
    purrr::list_c()
  
  # Replace old Date/Time with new columns
  data |> 
    dplyr::mutate(date = date_correct,
                  time = times) |> 
    dplyr::select(date, time, dplyr::everything()) |> 
    dplyr::select(-`Date/Time`) 
    
}


#' Change experimental data from character to numeric
#'
#' @param data 
#'
#' @return
#' @export
#'
#' @examples
change_data_formats <- function(data){
  # Isolate data
  exp_data_cols <- data |> 
    dplyr::select(-c(date:elapsed_time)) |> 
    names()
  
  data |> 
    mutate(across(all_of(exp_data_cols), as.numeric))
}

#' Extract file name
#'
#' @param file 
#'
#' @return
#' @export
#'
#' @examples
extract_file_name <- function(file){
  # Determine file names
  file_nms <- stringr::str_extract(file, stringr::regex(".*(?=.xlsx)")) |> 
    stringr::str_split(pattern = "/") |> purrr::pluck(1)
  
  # Best guess at the original file name
  file_nm <- file_nms[length(file_nms)]
  
  return(file_nm)
}

