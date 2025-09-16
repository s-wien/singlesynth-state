# packages
pacman::p_load(rio,        # file loading
               here,       # easy file referencing
               tidyverse,  # universe of tidy packages
               ggplot2)    # plotting

# default plot theme for the report
theme_set(theme_minimal() + theme(text = element_text(family = "Source Sans Pro")))

# load data
here::i_am("code/12-ascm-diagnostics-weights-plots.R")

# create list of weights file names
weights_files <- list.files(here::here("tables"),            # data folder
                            pattern = "^weights.*\\.xlsx$", # starts with "weights", is an .rds file
                            full.names = FALSE)

# loop to import all weights results (files starting with "weights" in the filename)
for (filename in weights_files) {
  
  # create object name (remove .rds extension)
  object_name <- tools::file_path_sans_ext(filename)
  
  # import and assign to global environment
  assign(object_name, rio::import(here::here("tables", filename), trust = TRUE))
  
  # state which object imported
  cat("imported:", object_name, "\n")
}

# function: ascm diagnostic, create weight plots
# input is each weight file
# creates plots for 1) absolute weights and 2) proportional weights
# original code provided by Liz Wagner, modified for this analysis 
create_weights_plots <- function(weights_data) {
  
  # create absolute weight plot
  plot_abs <- ggplot(weights_data, aes(x = reorder(POSTAL, -V1), y = V1)) +
    geom_bar(stat = "identity", fill = "orange") +
    labs(x = "State", y = "Weight", title = "Synthetic control absolute weights") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # create proportional weight plot
  plot_prop <- ggplot(weights_data, aes(x = reorder(POSTAL, -proportion), y = proportion)) +
    geom_bar(stat = "identity", fill = "#446B73") +
    labs(x = "State", y = "Proportion", title = "Synthetic control proportional weights") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(list(plot_abs = plot_abs, plot_prop = plot_prop))
}

# loop to process each weights object and export plots
for (filename in weights_files) {
  
  # get object name (created during import)
  weights_object_name <- tools::file_path_sans_ext(filename)
  
  # print which object is being processed
  cat("creating plots for:", weights_object_name, "\n")
  
  # get weights data and create plots
  current_weights <- get(weights_object_name)
  plot_results <- create_weights_plots(current_weights)
  
  # create filenames for plots (replaces "weights" with "plot")
  plot_abs_filename <- gsub("^weights", "weight_plot", paste0(weights_object_name, "_absolute.png"))
  plot_prop_filename <- gsub("^weights", "weight_plot", paste0(weights_object_name, "_proportional.png"))
  
  # export plots
  ggsave(here::here("figures", plot_abs_filename), 
         plot_results$plot_abs, 
         width = 10, height = 6, dpi = 300)
  
  ggsave(here::here("figures", plot_prop_filename), 
         plot_results$plot_prop, 
         width = 10, height = 6, dpi = 300)
  
  # print which plots were exported
  cat("exported plots:", plot_abs_filename, "and", plot_prop_filename, "\n\n")
}

# print message when complete
cat("all weight plots complete")