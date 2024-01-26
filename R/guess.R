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

