#' Remove header of SDR output file
#'
#' @param file 
#' @param output path to save output
#' @return
#' @export
#'
#' @examples
remove_header <- function(file = "data/Block1-MR1_20hpf-20C-120523-1015_Oxygen.xlsx",
                          output = NULL){
  
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
    }
      
    # Check if output path exists
    if(file.exists(output_path)){
      readr::write_csv(data, paste0(output_path,file_nm,"_noheader.csv"))
    } else {
      dir.create(output_path)
      readr::write_csv(data, paste0(output_path,file_nm,"_noheader.csv"))
    }
  }
  
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
  
  row_starts <- purrr::map(detect,
             ~.x[1]) |> 
    purrr::map(purrr::discard, is.na) |> 
    purrr::compact() |> 
    purrr::list_transpose() |> 
    purrr::pluck(1) |> 
    unname() |> 
    unique()
  
  if(length(row_starts) > 1) warning("`No Sensor` detected on some vials, replacing `No Sensor` with NA")
    
  no_sensor <- data[1:min(row_starts),] 

  # Replace No Sensor with NA
  replaced <- apply(no_sensor, c(1,2), function(x) gsub("No Sensor",NA_character_, x)) |> tibble::tibble()
  replaced_data <- replaced$`apply(...)`  |> tibble::as_tibble()
  
  return(replaced_data)
}
  



