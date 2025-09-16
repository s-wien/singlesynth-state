# creates outcome indidicator variables (rates are calculated at a later step)

# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate)  # handling date class

# load data
here::i_am("code/04-make-outcome.R")

data <- rio::import(here::here("data", "data.rds"), trust = TRUE)

# preterm birth, any 
data <- data %>%
  mutate(ptb = case_when(
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST < 37 ~ 1,
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST >= 37 ~ 0,
    TRUE ~ NA_integer_
  ))

# preterm birth, categories: extremely, very, moderately, late 
data <- data %>%
  mutate(ptb_cat = case_when(
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST >= 37 ~ "term",
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST >= 34 & COMBGEST <= 36 ~ "late PTB",
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST >= 32 & COMBGEST <= 33 ~ "moderately PTB",
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST >= 28 & COMBGEST <= 31 ~ "very PTB",
    BIRTHS == "1" & !is.na(COMBGEST) & COMBGEST < 28 ~ "extremely PTB",
    TRUE ~ NA_character_
  ))

# extremely preterm birth
data <- data %>%
  mutate(ptb_ex = case_when(
    BIRTHS == "1" & !is.na(ptb_cat) & ptb_cat == "extremely PTB" ~ 1,
    BIRTHS == "1" & !is.na(ptb_cat) & ptb_cat != "extremely PTB" ~ 0,
    TRUE ~ NA_integer_
  ))

rio::export(data, here::here("data", "data.rds"))

# print message when complete
cat("outcomes created")