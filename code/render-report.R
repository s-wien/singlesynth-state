# packages
pacman::p_load(quarto,     # render document
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse)  # universe of tidy packages


here::i_am("code/render-report.R")

# create reports folder, don't show warnings
dir.create(here::here("report"), 
           showWarnings = FALSE,
           recursive = TRUE)

# rendering report
quarto_render(input = here::here("code/report.qmd"))

# move copy of report to report folder
file.copy(from = here::here("code/report.html"), 
          to = here::here("report/report.html"), 
          overwrite = TRUE)

# copy supporting libraries for the html report to the report folder
# need this to preserve html formatting
#file.copy(from = here::here("code/report_files"), 
 #         to = here::here("report"),
  #        recursive = TRUE,
   #       overwrite = TRUE)

print("render report complete")