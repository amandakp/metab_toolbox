# Install/Load packages
# install.packages("pacman")
pacman::p_load(readxl, dplyr, purrr, lubridate, stringr, readr)

# Load functions 
source("R/clean_data.R")
source("R/guess.R")
source("R/menu.R")

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
blank_ids <- guess_blanks(data, threshold = 90)

# Bulk processing
blank_ids_ls <- map(processed,
                 ~guess_blanks(.x, threshold = 90))


# 3. Rename blanks
# Single file
# If you didn't guess blanks, you can manually type out the ID for the blanks *no quotes!
blank_single <- data |> 
  rename_blanks(c(D1, D2, A3, B3, C3, D3, D4, D5, A6, B6, C6, D6))

# Bulk processing
blanks_renamed <- map2(.x = processed, 
                            .y =blank_ids_ls,
                         ~rename_blanks(.x, tidyselect::all_of(.y))
)


# 4. Enter ids for lane placeholders 
# Remember to assign to object otherwise progress or renamed output will not be saved
# If you choose Quit it returns key and you can resume later
# Single file
in_progress <- assign_subj_ids(blank_single)

# If you break the cycle during renaming and want to resume
resumed <- assign_subj_ids(blank_single, key = in_progress)

# Create some fake ids for testing
key_filled <- tibble::tibble(subj = detect_subjects(blank_single),
                             true_id = paste(sample(LETTERS, size = length(detect_subjects(blank_single))),
                                             sample(1:1000, size = length(detect_subjects(blank_single))), sep="_")
)

# Giving function a prefilled key, Choose "Update column names"
renamed <- assign_subj_ids(blank_single, key = key_filled)

# Bulk processing is possible but can get other of hand if you decide to terminate early
test_bulk_rename <- map(blanks_renamed,
    ~assign_subj_ids(.x))

# 5. Save the output in whatever method you like
# Single file
write_csv(renamed, "output/processed/file_name_renamed.csv")

# Bulk saving
original_file_names <- map(list.files("data/"),
    ~extract_file_name(.x)) |> 
  list_c()

walk2(.x = test_bulk_rename,
      .y = original_file_names,
      ~write_csv(.x, paste0("output/processed/", Sys.Date(), "_", .y, "cleaned_",".csv"))
)
               










