#' Guess blanks based on threshold
#'
#' @param data 
#' @param threshold 
#'
#' @return
#' @export
#'
#' @examples
guess_blanks <-function(data, 
                        threshold = 90){
  # Isolate data
  exp_data <- data |> 
    dplyr::select(-c(date:elapsed_time))
  
  # Isolate Lane IDs that have means greater than threshold
  blank_guess_ids <- which(colMeans(exp_data, na.rm = TRUE) > threshold) |> names()
  
  # Pull out the numbers for sorting
  number_order <- stringr::str_extract(blank_guess_ids, "[:digit:]") |> as.numeric()
  
  ids_ordered <- tibble::tibble(id = blank_guess_ids,
                                 order = number_order) |> 
    dplyr::arrange(order) |> 
    dplyr::pull(id)
  
  ids_ordered
}

rename_subjects <- function(data, key){
  # Isolate data
  exp_data <- data |> 
    dplyr::select(-c(date:elapsed_time, starts_with("control")))
  
  # Check order from key matches data
  if(all(names(exp_data) == key$subj))
    names(exp_data) <- key$true_id
  
}

