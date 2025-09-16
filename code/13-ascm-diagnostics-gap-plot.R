# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               tidyverse,  # universe of tidy packages
               lubridate,  # handling date class   
               magrittr,   # augmented synthetic controls
               augsynth,   # augmented synthetic controls
               ggplot2)    # plotting

# default plot theme for the report
theme_set(theme_minimal() + theme(text = element_text(family = "Source Sans Pro")))

# load data
here::i_am("code/13-ascm-diagnostics-gap-plot.R")

# create list of file names
ascm_files <- list.files(here::here("data"),          # data folder
                         pattern = "^ascm.*\\.rds$",  # starts with "ascm", is an .rds file
                         full.names = FALSE)

# loop to import all augsynth results that start with "ascm"
for (filename in ascm_files) {
  
  # create object name (remove .rds extension)
  object_name <- tools::file_path_sans_ext(filename)
  
  # import and assign to global environment
  assign(object_name, rio::import(here::here("data", filename), trust = TRUE))
  
  # state which object imported
  cat("imported:", object_name, "\n")
}

# specify policy date
policy_date <- 0

# function: ascm diagnostic, create gap plot
# input is augsynth object, policy date
# extracts plot data to reformat into a gap plot
# original code provided by Liz Wagner, modified for this analysis 
create_gap_plot <- function(augsynth_obj, policy_date) {
  
  # extract summary, plot data from augsynth object
  augsynth_summary <- summary(augsynth_obj)
  plot <- plot(augsynth_summary)
  plot_data <- as.data.frame(plot$data)
  
  # create gap plot
  p <- ggplot(plot_data, aes(x = Time, y = Estimate)) +
    geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), fill = "black", alpha = 0.2) +
    geom_line(color = "black", linewidth = 1) +
    geom_vline(xintercept = policy_date, linetype = "dashed", color = "red", linewidth = 0.3) +
    geom_hline(yintercept = 0, linetype = "solid", color = "black", linewidth = 0.2) +
    scale_x_continuous(breaks = seq(min(plot_data$Time), max(plot_data$Time), by = 2)) + 
    labs(title = "Difference in observed and counterfactual estimates over time",
         x = "Time (months until policy treatment)", 
         y = "Difference") +
    theme_minimal() + 
    theme(legend.position = "right") 
  
  return(p)
}

# loop to process each ascm object and export gap plots
for (filename in ascm_files) {
  
  # get object name (created during import)
  ascm_object_name <- tools::file_path_sans_ext(filename)
  
  # print which object is being processed
  cat("creating gap plot for:", ascm_object_name, "\n")
  
  # get ascm object and create gap plot
  current_ascm <- get(ascm_object_name)
  gap_plot <- create_gap_plot(current_ascm, policy_date)
  
  # create filename for gap plot (replaces "ascm" with "gapplot")
  gap_filename <- gsub("^ascm", "gap_plot", paste0(ascm_object_name, ".png"))
  
  # export gap plot
  ggsave(here::here("figures", gap_filename), 
         plot = gap_plot, 
         width = 10, height = 6, dpi = 300)
  
  # print which gap plot was exported
  cat("exported gap plot:", gap_filename, "\n\n")
}

# print message when complete
cat("all gap plots complete")