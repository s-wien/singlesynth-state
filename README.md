# Augmented synthetic control analysis, single state policy

## Last updated September 15, 2025

# Overview

This repository provides code and sample data to estimate the effect of single state's policy on birth outcomes using the augmented synthetic control method (ASCM) utilizing the [`augsynth`](https://github.com/ebenmichael/augsynth) package and to report select results. The policy exposure in this example is Texas Senate Bill 8 (TX SB 8), a 6 week gestational ban on abortion that went into effect on September 1, 2021. 

For the purposes of speed and privacy, synthetic sample data prepared to be be used by the [`augsynth`](https://github.com/ebenmichael/augsynth) is provided (i.e., data have been prepared to begin the analysis at `08-run-singlesynth.R`). 

**All results are generated using synthetic data: results do not reflect real trends and are for educational purposes only.**

# Instructions

To run the analysis and generate a report:

1.  Check out or download the repository
2.  In RStudio's Terminal, navigate to the appropriate home directory
3.  In Terminal, enter `make clean` to remove the results, then `make clean` to run the augmented synthetic control method, diagnostics, and generate the report
4.  Results for each exposure-outcome combination will appear in the newly created `tables` and `figures` folders
5.  To clean results and re-run the analysis, in Terminal enter `make clean` and then `make singlesynth`

# Organization

This repository contains the following:

1.  `code/`: code to rename synthetic data, prepare data for the `augsynth` package, run ASCM diagnostics, and generate a report; assumes individual-level birth and fetal death data (e.g., NVSS vital records) at the begnning of the analysis
2.  `data/`: includes synthetic data for two different exposure definitions, data for FIPS codes, and `augsynth` objects 
3.  `figures/`: contains plots describing exposure definitions, gap plots, synthetic weight plots and outcome trend plots
4.  `tables/`: contains ATTs and diagnostic statistics
5.  `report/`: contains an `.html` report that sumarizing select results 
4.  `Makefile`: this file is used to run analyses starting at `08-run-singlesynth.R` and to clean output