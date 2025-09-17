# Augmented synthetic control analysis, single state policy

## Last updated September 15, 2025

# Overview

This repository provides code and sample data to estimate the effect of single state's policy on birth outcomes using the augmented synthetic control method (ASCM) utilizing the [`augsynth`](https://github.com/ebenmichael/augsynth) package and to report select results. The policy exposure in this example is Texas Senate Bill 8 (TX SB 8), a 6 week gestational ban on abortion that went into effect on September 1, 2021.

For the purposes of speed and privacy, synthetic sample data prepared to be be used by the [`augsynth`](https://github.com/ebenmichael/augsynth) package is provided (i.e., data have been prepared to begin the analysis at `08-run-singlesynth.R`).

**All results are generated using synthetic data: results do not reflect real trends and are for educational purposes only.**

# Instructions

## Installing the `augsynth` package

## Runing the analysis and generating the report

1.  Clone or download the repository
2.  In RStudio's Terminal, navigate to the appropriate home directory
3.  In Terminal, enter `make clean` to remove the results, then `make singlesynth` to run the augmented synthetic control method, diagnostics, and generate the report
4.  Results for each exposure-outcome combination will appear in figures and the newly created `tables` and `report` folders
5.  To clean results and re-run the analysis, in Terminal enter `make clean` and then `make singlesynth`


# Organization

This repository contains the following:

1.  `code/`

-   renames synthetic data
-   prepares data for the `augsynth` package
-   runs ASCM diagnostics
-   generates a report
-   code `01-07` assumes individual-level birth and fetal death data (e.g., NVSS vital records)
-   code `08-15` assumes data aggregated by treatment, time, and state

2.  `data/`

-   synthetic data for two different exposure definitions
-   data for FIPS codes
-   `augsynth` objects

3.  `figures/`

-   plots describing exposure definitions
-   gap plots
-   synthetic weight plots
-   outcome trend plots

4.  `tables/`

-   ATT results
-   summary diagnostic statistics

5.  `report/`

-   `.html` report that summarizes select results

6.  `Makefile`

-   file is used to run analyses starting at `08-run-singlesynth.R` and to clean output
