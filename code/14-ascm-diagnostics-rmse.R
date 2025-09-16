# calculates pretreatment RMSE for each exposure-outcome combination

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth,   # augmented synthetic controls
               Metrics)    # calculate rmse

# load data
here::i_am("code/14-ascm-diagnostics-rmse.R")

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

# specify policy date
policy_date <- 0

# function: ascm diagnostic, calculate mean ATT and pre-treatment rmse
# inputs are augsynth object and policy date
# calculates overall ATT (i.e., across all time periods) and pre-treatment rmse
# original code provided by Liz Wagner, modified for this analysis 
calculate_rmse <- function(augsynth_obj, policy_date) {
  
  # generate summary and plot data
  augsynth_summary <- summary(augsynth_obj)
  plot <- plot(augsynth_summary)
  plot_data <- as.data.frame(plot$data)
  
  # calculate average ATT for entire treatment time period
  Avg_ATT <- mean(plot_data$Estimate[plot_data$Time >= policy_date])
  
  # pre-treatment RMSE calculation
  pre_observed <- as.vector(augsynth_obj[["data"]][["synth_data"]][["Z1"]])
  pre_predicted <- as.vector(predict(augsynth_obj)[plot_data$Time < policy_date])
  pre_rmse <- rmse(pre_predicted, pre_observed)
  
  # create results dataframe
  results <- data.frame(Avg_ATT = Avg_ATT,
                        Pre_RMSE = pre_rmse)
  
  return(results)
}

# loop to process each ascm object and export rmse results
for (filename in ascm_files) {
  
  # get object name (created during import)
  ascm_object_name <- tools::file_path_sans_ext(filename)
  
  # print which object is being processed
  cat("calculating rmse for:", ascm_object_name, "\n")
  
  # get ascm object and calculate rmse
  current_ascm <- get(ascm_object_name)
  rmse_results <- calculate_rmse(current_ascm, policy_date)
  
  # create filename for rmse results (replaces "ascm" with "rmse")
  rmse_filename <- gsub("^ascm", "rmse", paste0(ascm_object_name, ".xlsx"))
  
  # export rmse results
  rio::export(rmse_results, here::here("tables", rmse_filename))
  
  # print which rmse file was exported
  cat("exported rmse results:", rmse_filename, "\n\n")
}

# print message when complete
cat("all rmse calculations complete")