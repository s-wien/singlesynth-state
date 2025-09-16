# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class

# load data
here::i_am("code/06-make-synth-data.R")

data <- rio::import(here::here("data", "data.rds"), trust = TRUE)

# function 1: create synthetic dataset
# inputs are the dataframe and column name with exposure information 
# aggregates data by treatment, time, state, and time impacted by state Medicaid expansion
# calculates monthly rate of all outcomes, confounders (state Medicaid expansion, proportion pregnancies > 35)
create_synth_data <- function(data, exposure_col, save_file = TRUE) {
  
  # stores variable name as string 
  exposure_var <- rlang::sym(exposure_col)
  
  synth_data <- data %>%
    #"!!" unquotes the symbol
    group_by(!!exposure_var, event_date, OSTATE, aca_expansion) %>%
    # count events of interest
    summarise(total = n(),
              eq_over_35 = sum(maternal_age_over_35 == 1, na.rm = TRUE),
              births = sum(BIRTHS == 1, na.rm = TRUE),
              fetal = sum(FETAL == 1, na.rm = TRUE),
              ptb = sum(ptb == 1, na.rm = TRUE),
              ptb_ex = sum(ptb_ex == 1, na.rm = TRUE),
              .groups = 'drop') %>%
    # create rates
    mutate(prop_eq_over_35 = (eq_over_35 / total),
           fetal_rate = (fetal / total) * 100,
           ptb_rate = (ptb / births) * 100,
           ptb_far_rate = (ptb / total) * 100,
           ptb_ex_rate = (ptb_ex / births) * 100,
           ptb_ex_far_rate = (ptb_ex / total) * 100) %>%
    
    mutate(exposure_type = exposure_col) %>%
    #"!!" unquotes the symbol
    rename(treated = !!exposure_var)
  
  return(synth_data)}

# function 2: create numeric dates
# create numeric dates for synthetic data, with start of treatment = 0 (in months)
# input is the dataframe
add_numeric_date <- function(data) {
  first_treatment_date <- data %>%
    
    # find first treatment period (earliest treated == 1)
    filter(treated == 1) %>%                                                           
    summarise(first_treatment = min(event_date, na.rm = TRUE)) %>%
    pull(first_treatment)
  
  data <- data %>%
    # add numeric date: first treatment period is time 0, counting months after
    mutate(event_date_num = interval(first_treatment_date, event_date) %/% months(1))
  
  return(data)}

# create synthetic dataset
synth_data_treated_6_weeks <- create_synth_data(data, "treated_6_weeks")
synth_data_treated_any <- create_synth_data(data, "treated_any")

# add numeric time for both exposure definitions 
synth_data_treated_6_weeks <- add_numeric_date(synth_data_treated_6_weeks)
synth_data_treated_any <- add_numeric_date(synth_data_treated_any)

# export data
rio::export(data, here::here("data", "synth_data_treated_6_weeks.rds"))
rio::export(data, here::here("data", "synth_data_treated_any.rds"))

# print message when complete
cat("synth data created")