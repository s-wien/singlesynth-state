# passes data through the augsynth package for each combination of exposure-outcomes

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth)   # augmented synthetic controls

# load data
here::i_am("code/08-run-singlesynth.R")

synth_data_treated_6_weeks <- rio::import(here::here("data", "synth_data_treated_6_weeks.rds"), trust = TRUE)
synth_data_treated_any <- rio::import(here::here("data", "synth_data_treated_any.rds"), trust = TRUE)

# define list of datasets and outcomes
datasets <- list("6_weeks" = synth_data_treated_6_weeks,
                 "any" = synth_data_treated_any)

outcomes <- c("fetal_rate", 
              "ptb_rate", 
              "ptb_far_rate", 
              "ptb_ex_rate", 
              "ptb_ex_far_rate")

# run ascm 
# loop to run through each combination of exposure dataset and outcome column
# exports ascm object to data folder
for (exposure_type in names(datasets)) {
  for (outcome in outcomes) {
    
    # report which combination of ascm exposure and outcome are running 
    cat("processing:", exposure_type, "exposure with", outcome, "outcome\n")
    
    # get exposure dataset
    current_data <- datasets[[exposure_type]]
    
    # create flexible formula
    formula_str <- paste(outcome, "~ treated | aca_expansion + prop_eq_over_35")
    current_formula <- as.formula(formula_str)
    
    # run augsynth
    asyn <- augsynth(current_formula,         # uses flexible formula that includes each exposure and outcome, some confounders
                     unit = OSTATE,           # state
                     time = event_date_num,   # numerical date, policy at time = 0
                     data = current_data,     # exposure dataset
                     progfunc = "Ridge",      # augmented synthetic control
                     scm = TRUE,
                     fixedeff = TRUE)         # fixed effects for state
    
    # create filename and export ascm object
    asyn_filename <- paste0("ascm_", exposure_type, "_", outcome, ".rds")
    rio::export(asyn, here::here("data", asyn_filename))
    
    # state which object is exported
    cat("exported:", asyn_filename, "\n\n")
  }
}

# print message
cat("augsynth functions for all outcomes complete")