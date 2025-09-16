# filters each exposure dataset based on features of the exposure definition

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth)   # augmented synthetic controls

# load data
here::i_am("code/07-prepare-singlesynth.R")

synth_data_treated_6_weeks <- rio::import(here::here("data", "synth_data_treated_6_weeks.rds"), trust = TRUE)
synth_data_treated_any <- rio::import(here::here("data", "synth_data_treated_any.rds"), trust = TRUE)

# filter dates for exposure 1, filtering due to exposure definition 
synth_data_treated_6_weeks <- synth_data_treated_6_weeks %>%
  filter(!is.na(treated),
         event_date < "2022-04-01")

# filter states for exposure 2, filtering due to control states receiving the treatment after this date
synth_data_treated_any <- synth_data_treated_any %>%
  filter(!is.na(treated),
         event_date < "2022-05-01")

# export exposure data 
synth_data_treated_6_weeks <- rio::export(synth_data_treated_6_weeks, here::here("data", "synth_data_treated_6_weeks.rds"))
synth_data_treated_any <- rio::export(synth_data_treated_any, here::here("data", "synth_data_treated_any.rds"))

# print message when complete
cat("synth data prepared")