# Function to update a data frame interactively
assign_subj_ids <- function(data, key = NULL) {
  # Get key
  if(is.null(key))
  key <- create_subj_key(data)
  
  print(key)
  
  repeat {
    choice <- menu(title = "Choose an option:", c("Assign ID to lane", "Quit", "Update column names"))
    
    if (choice == 1) {
      selected <- menu(key$subj, title = "Select ID to update:")
      
      cat("Enter new value:\n")
      value <- readline(prompt = "")
      
      key$true_id[[selected]] <- value
      cat("Key updated:\n")
      print(key)
      
    } else if (choice == 2) {
      return(key)
      break
    }
    else if (choice == 3) {
      out <- rename_subjects(data, key)
      return(out)
      break
    }
  }
}

