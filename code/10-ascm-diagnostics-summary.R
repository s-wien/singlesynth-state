# calculates summary statistics for each exposure-outcome combination

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth)   # augmented synthetic controls

# load data
here::i_am("code/10-ascm-diagnostics-summary.R")

# load synthetic datasets
synth_data_treated_6_weeks <- rio::import(here::here("data", "synth_data_treated_6_weeks.rds"), trust = TRUE)
synth_data_treated_any <- rio::import(here::here("data", "synth_data_treated_any.rds"), trust = TRUE)

# load ascm objects
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

# function: ascm diagnostic, calculate observed and synthetic means with confidence intervals
# inputs are augsynth object, corresponding synthetic dataset, treated unit, outcome variables, and policy date
# extracts 1) ascm plot data and 2) observed and synthetic estimates, then calculates CI and formats them in a table
# original code provided by Liz Wagner, modified for this analysis 
calculate_summary_stats <- function(augsynth_obj, synth_data, treated_unit = "TX", outcome_var, policy_date) {
  
  # extract data from object
  plot <- plot(augsynth_obj)
  plot_data <- as.data.frame(plot$data)
  
  # pull out the actual observed outcomes for the treated unit 
  ct_actual <- synth_data %>%
    filter(OSTATE == treated_unit) %>%
    select(Time = event_date_num, actual_outcome = all_of(outcome_var))
  
  # join and compute the synthetic prediction
  predictions <- plot_data %>%
    left_join(ct_actual, by = "Time") %>%
    mutate(synthetic_outcome = actual_outcome - Estimate)
  
  # create summary table with observed and synthetic means plus confidence intervals
  summary_periods_ci <- predictions %>%
    mutate(Period = if_else(Time < policy_date, "Pre-Policy", "Post-Policy")) %>%
    group_by(Period) %>%
    summarise(
      n                = n(),
      Obs_Mean         = mean(actual_outcome, na.rm = TRUE),
      Obs_SE           = sd(actual_outcome, na.rm = TRUE) / sqrt(n),
      Obs_CI_Lower     = Obs_Mean - qt(0.975, df = n-1) * Obs_SE,
      Obs_CI_Upper     = Obs_Mean + qt(0.975, df = n-1) * Obs_SE,
      Synth_Mean       = mean(synthetic_outcome, na.rm = TRUE),
      Synth_SE         = sd(synthetic_outcome, na.rm = TRUE) / sqrt(n),
      Synth_CI_Lower   = Synth_Mean - qt(0.975, df = n-1) * Synth_SE,
      Synth_CI_Upper   = Synth_Mean + qt(0.975, df = n-1) * Synth_SE,
      .groups = "drop"
    )
  
  return(summary_periods_ci)
}

# loop to process each ascm object and export summary statistics
for (filename in ascm_files) {
  
  # get object name (created during import)
  ascm_object_name <- tools::file_path_sans_ext(filename)
  
  # determine outcome variable and corresponding synth data
  if (grepl("6_weeks", ascm_object_name)) {
    current_synth_data <- synth_data_treated_6_weeks
    outcome_var <- gsub("^ascm_6_weeks_", "", ascm_object_name)
  } else {
    current_synth_data <- synth_data_treated_any
    outcome_var <- gsub("^ascm_any_", "", ascm_object_name)
  }
  
  # print which object is being processed
  cat("processing summary stats for:", ascm_object_name, "\n")
  
  # get ascm object and extract summary stats
  current_ascm <- get(ascm_object_name)
  summary_results <- calculate_summary_stats(current_ascm, current_synth_data, "TX", outcome_var, policy_date)
  
  # create filename and export
  summary_filename <- gsub("^ascm", "summary", paste0(ascm_object_name, ".xlsx"))
  rio::export(summary_results, here::here("tables", summary_filename))
  
  # print which summary file is exported
  cat("exported summary results:", summary_filename, "\n\n")
}

# print message when complete
cat("all summary statistics complete")