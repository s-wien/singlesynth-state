# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class 

# load data
here::i_am("code/03-make-exposure.R")

data <- rio::import(here::here("data", "data.rds"), trust = TRUE)

policy_date <- "2021-09-01"

# exposure 1
# pregnancies are exposed if, by the date the policy went into effect, the pregnancy was at least 6 weeks gestational age
# pregnancies where the event occurred before the policy went into effect ~ unexposed
# pregnancies <  6 weeks gestational age by the time the policy went into effect ~ removed

data <- data %>%
  mutate(treated_6_weeks = case_when(
    # if gestational age at 6 weeks is after policy ~ exclude (set to NA)
    date_at_6_weeks > policy_date ~ NA_integer_,
    # if in treated state AND event at/after policy AND 6-weeks gestation date before/at policy ~ treated
    OSTATE == "TX" & event_date >= policy_date & date_at_6_weeks <= policy_date ~ 1,
    # if in treated state AND event before policy ~ control
    OSTATE == "TX" & event_date < policy_date ~ 0,
    # if not in treated state: control
    OSTATE != "TX" ~ 0,
    TRUE ~ NA_integer_
  ))

# exposure 2: any exposure definition
# pregnancies exposed if any part of pregnancy occurred after policy in effect
# pregnancies where the event occurred before the policy went into effect
# no pregnancies are removed

data <- data %>%
  mutate(treated_any = case_when(
    # if in treated state AND event after policy ~ treated
    OSTATE == "TX" & event_date >= policy_date ~ 1,
    # if in treated state AND event before/at policy ~ control
    OSTATE == "TX" & event_date < policy_date ~ 0,
    # if not in treated state ~ control 
    OSTATE != "TX" ~ 0,
    TRUE ~ NA_integer_
  )) 

rio::export(data, here::here("data", "data.rds"))

# print message when complete
cat("exposures created")