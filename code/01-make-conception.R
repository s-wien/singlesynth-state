# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class  

# load data
here::i_am("code/01-make-conception.R")

data <- rio::import(here::here( "data", "data.rds"), trust = TRUE)

data <- data %>%
  select(FETAL,
         BIRTHS,
         OSTATE,
         YEAR_MONTH,
         COMBGEST,
         DPLURAL,
         MM_RUPT,
         MM_ICU,
         MAGER41)

# calculate conception 
data <- data %>%
  mutate(event_date = YEAR_MONTH,
         conception_date = event_date - weeks(COMBGEST),                           # subtract gestational age in weeks for conception
         date_at_6_weeks = conception_date + weeks(6),                             # calculate date when pregnancy was at 6 weeks         date_at_6_weeks_rounded = case_when(                                      # round date back if < 15 or forward if >= 15
           day(date_at_6_weeks) < 15 ~ floor_date(date_at_6_weeks, unit = "month"),
           TRUE ~ ceiling_date(date_at_6_weeks, unit = "month"))

# export data
rio::export(data, here::here("data", "data.rds"))

# print message when complete
cat("conception dates calculated")