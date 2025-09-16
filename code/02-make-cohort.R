# applies inclusion, exlusion criteria for analysis

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class

# load data
here::i_am("code/02-make-cohort.R")

data <- rio::import(here::here("data", "data.rds"), trust = TRUE)

# create cohort 
data <- data %>%
  filter(event_date >= "2014-01-01",    # study start period (study ends varies by exposure definition)
         DPLURAL == 1,                  # restrict to singleton events
         COMBGEST >= 20,                # restrict to stillbirths >= 20 weeks gestation
         OSTATE != "CT")                # remove CT due to under reporting of stillbirths                             

rio::export(data, here::here("data", "data.rds"))

# print message when complete
cat("cohort created")