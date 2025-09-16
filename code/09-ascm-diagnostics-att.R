# calculates ATT for each exposure-outcome combination

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth)   # augmented synthetic controls

# load data
here::i_am("code/09-ascm-diagnostics-att.R")

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

# specify policy date at time = 0 
policy_date <- 0

# function: ascm diagnostic, extract post-treatment ATT's with p-values and CI's 
# input is augsynth object and policy date
# runs the augsynth summary function, extracts ATT data by filtering by treatment date
# original code from Liz Wagner, modified for this analysis
extract_att_data <- function(augsynth_obj, policy_date) {
  
  augsynth_summary <- summary(augsynth_obj)              
  plot <- plot(augsynth_summary)                         
  plot_data <- as.data.frame(plot$data)                  
  
  att_data <- plot_data %>%
    filter(Time >= policy_date)                          
  
  return(att_data)
}

# loop to process each ascm object and export ATT results
for (filename in ascm_files) {
  
  # get object name (created during import)
  ascm_object_name <- tools::file_path_sans_ext(filename)
  
  # print which object is being processed, add one line
  cat("processing ATT for:", ascm_object_name, "\n")
  
  # get ascm object
  current_ascm <- get(ascm_object_name)
  
  # extract ATT data using function created above
  att_results <- extract_att_data(current_ascm, policy_date)
  
  # create filename for ATT results (replaces "ascm" with "att")
  att_filename <- gsub("^ascm", "att", paste0(ascm_object_name, ".xlsx"))
  
  # export ATT results
  rio::export(att_results, here::here("tables", att_filename))
  
  # print which ATT file is exported, add two lines
  cat("exported ATT results:", att_filename, "\n\n")
}

# print message when complete
cat("all ATT extractions complete")