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

create_subj_key <- function(data){
  # Create a key the user has to complete
  key_unfilled <- tibble::tibble(subj = detect_subjects(data),
                         true_id = NA_character_)
  
  return(key_unfilled)
}



#' Rename subjects according to key
#'
#' @param data 
#' @param key 
#'
#' @return
#' @export
#'
#' @examples
rename_subjects <- function(data, key){
  # Isolate data
  exp_data <- data |> 
    dplyr::select(-c(date:elapsed_time, starts_with("control")))
  
  # Isolate control data
  blanks <- data |> 
    dplyr::select(starts_with("control"))
  
  # Check order from key matches data
  if(all(names(exp_data) == key$subj))
    names(exp_data) <- key$true_id
  
  # Add back in other data
  output <- data |> 
    dplyr::select(date:elapsed_time) |> 
    bind_cols(exp_data) |> 
    bind_cols(blanks)
  
  # Check dimensions
  if(all(dim(data) == dim(output))){
    message("Renaming complete")
    return(output) 
  }
}

