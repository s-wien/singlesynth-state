# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               readr,      # read a fixed width file into a tibble
               dplyr,      # tidy package
               tidyr,      # data handling
               lubridate,  # handling date class  
               ggplot2)    # plotting (removed plotly and htmlwidgets)

# load data
here::i_am("code/15-make-outcome-trend-plots.R")

synth_data_treated_6_weeks <- rio::import(here::here("data", "synth_data_treated_6_weeks.rds"), trust = TRUE)
synth_data_treated_any <- rio::import(here::here("data", "synth_data_treated_any.rds"), trust = TRUE)

# default plot theme for the report
theme_set(theme_minimal() + theme(text = element_text(family = "Source Sans Pro")))

# function: create outcome trend plot
# input is synthetic data object, outcome column name, and plot title
# original code provided by Liz Wagner, modified for this analysis 
create_outcome_plot <- function(data, outcome_col, plot_title) {
  
  ggplot(data, aes(x = event_date_num, y = !!sym(outcome_col), group = OSTATE)) +
    geom_line(aes(color = "Control"), linewidth = 0.4, alpha = 0.8) +
    geom_line(data = filter(data, OSTATE == "TX"), 
              aes(color = "Treated"), linewidth = 1.2) +
    scale_color_manual(name = "", values = c("Control" = "grey70", "Treated" = "black")) +
    labs(title = plot_title,
         x = "Time (months until policy treatment)", 
         y = "Proportion (%)") +
    theme_minimal()
}

# define outcome columns and labels
outcomes <- c("fetal_rate" = "Stillbirth rate",
              "ptb_rate" = "PTB rate", 
              "ptb_far_rate" = "PTB FAR rate",
              "ptb_ex_rate" = "Extremely PTB rate",
              "ptb_ex_far_rate" = "Extremely PTB FAR rate")

# define datasets
datasets <- list(
  "6_weeks" = list(data = synth_data_treated_6_weeks, label = "exposed at least 6 weeks gestation"),
  "any" = list(data = synth_data_treated_any, label = "exposed during any portion of pregnancy")
)

# loop through datasets and outcomes
for (dataset_name in names(datasets)) {
  
  # get current dataset info
  current_data <- datasets[[dataset_name]]$data
  exposure_label <- datasets[[dataset_name]]$label
  
  cat("creating plots for:", dataset_name, "\n")
  
  # create plots for each outcome
  for (outcome_col in names(outcomes)) {
    
    # create plot title and filename
    plot_title <- paste0(outcomes[outcome_col], ", ", exposure_label)
    plot_filename <- paste0("outcome_plot_", dataset_name, "_", outcome_col, ".png")
    
    # create and export plot
    outcome_plot <- create_outcome_plot(current_data, outcome_col, plot_title)
    ggsave(here::here("figures", plot_filename), 
           plot = outcome_plot,
           width = 10, height = 6, dpi = 300)
    
    cat("exported plot:", plot_filename, "\n")
  }
  cat("\n")
}

# print message when complete
cat("all outcome trend plots complete")