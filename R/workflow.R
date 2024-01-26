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

# 4. Detect subjects (lanes that contain live organisms)
# Single file
subjects <- detect_subjects(blank_single)

# Bulk processing
map(blanks_renamed,
    ~detect_subjects(.x))

# 5. Create 'key' and assign true subject ids to placeholders
# Single file
create_subj_key(blank_single)

# Bulk processing
map(blanks_renamed,
    ~create_subj_key(.x))


# ---------
# Create some fake ids
ids <- paste(sample(LETTERS, size = nrow(key_unfilled)),
             sample(1:1000, size = nrow(key_unfilled)), sep="_")

# We've filled in the key now
key_filled <- mutate(key_unfilled,
                     true_id = ids)









