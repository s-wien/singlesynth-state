# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth,   # augmented synthetic controls
               ggplot2)    # plotting

# create list of file names
ascm_files <- list.files(here::here("data"),          # data folder
                         pattern = "^ascm.*\\.rds$",  # starts with "ascm", is an .rds file
                         full.names = FALSE)

# loop to import all augsynth results that start with "ascm"
for (filename in ascm_files) {
  
  # create object name (remove .rds extension)
  object_name <- tools::file_path_sans_ext(filename)
  
  # import and assign to global environment
  assign(object_name, rio::import(here::here("data", filename), trust = TRUE))
  
  # state which object imported
  cat("imported:", object_name, "\n")
}

# function: ascm diagnostic, extract, calculate weights used to construct the synthetic control
# input is the augsynth object
# extracts weight, calculates absolute/relative weight for each state
# imports FIPS codebook to match state FIPS code with state name
# original code provided by Liz Wagner, modified for this analysis 
analyze_weights <- function(augsynth_obj) {
  
  # import file with FIPS codes
  fips <- rio::import(here::here("data", "state-fips-codebook.xlsx"), trust = TRUE)
  
  # extract weights from ascm object
  weights_df <- as.data.frame(augsynth_obj[["weights"]])
  
  # calculate absolute value of weights
  weights_df$abs_V1 <- abs(weights_df$V1)
  
  # calculate weights denominator
  total_abs_V1 <- sum(weights_df$abs_V1)
  
  # calculate total proportion each weight represents
  weights_df$proportion <- (weights_df$abs_V1 / total_abs_V1)
  
  # add state information
  weights_df <- tibble::rownames_to_column(weights_df, var = "POSTAL")
  weights_df <- weights_df %>%
    left_join(fips %>% select(NAME, POSTAL), by = "POSTAL") %>%
    arrange(desc(V1))
  
  return(weights_df)
}

# loop to process each ascm object and export weights analysis
for (filename in ascm_files) {
  
  # get object name (created during import)
  ascm_object_name <- tools::file_path_sans_ext(filename)
  
  # print which object is being processed
  cat("processing weights for:", ascm_object_name, "\n")
  
  # get ascm object and analyze weights
  current_ascm <- get(ascm_object_name)
  weights_results <- analyze_weights(current_ascm)
  
  # create filename for weights results (replaces "ascm" with "weights")
  weights_filename <- gsub("^ascm", "weights", paste0(ascm_object_name, ".xlsx"))
  
  # export weights results
  rio::export(weights_results, here::here("tables", weights_filename))
  
  # print which weights file is exported
  cat("exported weights results:", weights_filename, "\n\n")
}

# print message when complete
cat("all weight tables complete")