# "make singlesynth" will run the synthetic control code and diagnostics 
singlesynth:
	Rscript code/00-name-fake-synth-data.R
	Rscript code/08-run-singlesynth.R
	Rscript code/09-ascm-diagnostics-att.R
	Rscript code/10-ascm-diagnostics-summary.R
	Rscript code/11-ascm-diagnostics-weights.R
	Rscript code/12-ascm-diagnostics-weights-plots.R
	Rscript code/13-ascm-diagnostics-gap-plot.R
	Rscript code/14-ascm-diagnostics-rmse.R
	Rscript code/15-make-outcome-trend-plots.R
	Rscript code/render-report.R

# "make clean" will remove any files listed below (i.e., all output and tables generated from code)
.PHONY: clean
clean:
	# remove both report locations
	rm -rf code/report.html
	rm -rf report/
	rm -rf tables/
	# remove all figures except the exposure definition plots (made separetley from this rep)
	rm -rf figures/gap*
	rm -rf figures/weight*
	rm -rf figures/outcome*
	# remove all data products except the fake synthetic data and the state FIPS codebook
	rm -f data/synth*
	rm -f data/ascm*
	rm -f data/att*
	rm -f data/summary*
	rm -f data/weights*
	rm -f data/rmse*