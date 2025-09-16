# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class  

# load data
here::i_am("code/05-make-covariates.R")

data <- rio::import(here::here("data", "data.rds"), trust = TRUE)

aca <- rio::import(here::here("data", "state-medicaid-data.xlsx"), trust = TRUE)

# state Medicaid expansion 
# assumption that for Medicaid expansion to impact outcomes, it needs to be in effect at conception (e.g., prenatal care)
# assuming earliest pregnancies in dataset impacted by expansion are stillbirths that occur 20 weeks after implementation date
aca <- aca %>%
  mutate(`Date Implemented` = na_if(`Date Implemented`, "NA"),
         date_implemented = ymd(`Date Implemented`),
         date_event_impacted = date_implemented + weeks(20)) %>% # adding 20 weeks onto every implementation date
  rename(OSTATE = `State Abbreviation`) %>%
  select(OSTATE, `Adoption State`, date_implemented, date_event_impacted)

data <- data %>%
  left_join(aca, by = c("OSTATE" = "OSTATE")) %>%
  mutate(aca_expansion = case_when(
    is.na(date_event_impacted) ~ 0,          # if state never adopted Medicaid expansion ~ always 0  (Medicaid expansion cannot influence outcome)
    event_date < date_event_impacted ~ 0,    # if estimated conception was before impact date   ~ 0  (Medicaid expansion was in not in effect for the whole pregnancy)
    event_date >= date_event_impacted ~ 1,   # if estimated conception on or after impact_date  ~ 1  (Medicaid expansion was in effect for the entire pregnancy)
    TRUE ~ 0))

# proportion of births > 35
# creating indicator only, state-month proportions calculated in synthetic data creation step
data <- data %>%
  mutate(maternal_age_over_35 = case_when(
    MAGER41 < 35 ~ 0, 
    MAGER41 >= 35 ~ 1, 
    TRUE ~ NA_integer_)) 

# export data
rio::export(data, here::here("data", "data.rds"))

# print message when complete
cat("covariates created")