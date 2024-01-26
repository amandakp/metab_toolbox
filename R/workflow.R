# Install/Load packages
# install.packages("pacman")
pacman::p_load(readxl, dplyr, purrr, lubridate, stringr, readr)

# Load functions 
source("R/clean_data.R")
source("R/guess.R")

# Locate files
raw_files_paths <- file.path("data/", list.files("data/"))


# 1. Reformat your files 
# Single file
data <- reformat_sdr("data/Block1-MR1_20hpf-20C-120523-1015_Oxygen.xlsx") 

# Bulk processing
processed <- map(raw_files_paths,
     ~reformat_sdr(.x)
)


# 2. Guess blanks (Optional)
# Single file
blank_ids <- guess_blanks(data)

# Bulk processing
blank_ids_ls <- map(processed,
                 ~guess_blanks(.x))


# 3. Rename blanks
# Single file
# If you didn't guess blanks, you can manually type out the ID for the blanks *no quotes!
data |> 
  rename_blanks(c(D1, D2, A3, B3, C3, D3, D4, D5, A6, B6, C6, D6))

# Bulk processing
blanks_renamed <- map2(.x = processed, 
                            .y =blank_ids_ls,
                         ~rename_blanks(.x, tidyselect::all_of(.y))
)











