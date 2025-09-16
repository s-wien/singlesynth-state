# Augmented synthetic control analysis and report for single treatment

## Last updated September 15, 2025

# Overview

This repository provides code and sample data to estimate the effect of single state's policy on birth outcomes using the augmented synthetic control method (ASCM) utilizing the [`augsynth`](https://github.com/ebenmichael/augsynth) package and to report select results. The policy exposure in this example is Texas Senate Bill 8 (TX SB 8), a 6 week gestational ban on abortion that went into effect on September 1, 2021. 

For the purposes of speed and privacy, synthetic sample data prepared to be be used by the [`augsynth`](https://github.com/ebenmichael/augsynth) is provided (i.e., data have been prepared to begin the analysis at `08-run-singlesynth.R`). 

**All results are generated using synthetic data, results do not reflect real trends and are for educational purposes only.**

# Instructions

To run the analysis and generate a report:

1.  Check out or download the repository
2.  In RStudio's Terminal, navigate to the appropriate home directory
3.  In Terminal, enter `make singlesynth` to run the augmented synthetic control method, diagnostics, and generate the report
4.  Results for each exposure-outcome combination will appear in the newly created `tables` and `figures` folders
5.  To clean results and re-run the analysis, in Terminal enter `make clean` and then `make singlesynth`

# Organization

This repository contains the following:

1.  `code/`: this contains code assuming individual-level birth and fetal death data (e.g., NVSS vital records) at the begnning of the analysis  
  - `00-name-fake-synth-data` renames the synthetic data
  - `01-make-conception` calculates estimated calendar date for date of conception and date of gestational age at 6 weeks
  - `02-make-cohort` applies cohort inclusion and exclusion criteria
  - `03-` to `05-` creates exposure, outcome, and covariate variables
  - `06-make-synth-data` aggregates data by treatment, state, month, and time-varying confoudners; calculates monthly outcome rates
  - `07-prepare-singlesynth` restricts post-treatment time due to exposure definitions
  - `08-run-singlesynth` runs the `augsynth` package for each combination of exposure and outcome
  - `09-` to `14-` run augmented synthetic control diagnostics
  - `15-make-outcome-trend-plots` creates outcome trend plots
  - `render-report` renders the `report.qmd` file
  
2.  `data/`: includes synthetic data for two different exposure definitions and data for FIPS codes 
3.  `figures/`: will contain pre-made plots describing the two different exposures used in this analysis 
4.  `Makefile`: this file is used to run analyses starting at `08-run-singlesynth.R` and to clean output

At the end of the analyses, you should have the following:

1.  `tables/`: will contain ATTs and diagnostic statistics
2.  `figures/`: will contain additional files containing gap plots and outcome trend plots
3.  `report/`: will contain an `.html` report that summarizes select results 