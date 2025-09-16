# renames fake synthetic data so it can be imported

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # tidy package
               lubridate)  # handling date class

# load data
here::i_am("code/00-name-fake-synth-data.R")

# import data
fake_synth_data_exposure_treated_6_weeks <- rio::import(here::here("data", "fake_synth_data_exposure_treated_6_weeks.rds"), trust = TRUE)
fake_synth_data_exposure_treated_any <- rio::import(here::here("data", "fake_synth_data_exposure_treated_any.rds"), trust = TRUE)

# export data with new name to run script
rio::export(fake_synth_data_exposure_treated_6_weeks, here::here( "data", "synth_data_treated_6_weeks.rds"))
rio::export(fake_synth_data_exposure_treated_any, here::here( "data", "synth_data_treated_any.rds"))

# print message when complete
cat("fake data has been renamed")