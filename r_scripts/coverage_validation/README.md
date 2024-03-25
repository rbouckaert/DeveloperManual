# Coverage validation of an inferential model

Below we document how to prepare the analysis, and then how (after Bayesian inference) to obtain the figures related to coverage validation.

## Scenario 1 (correctly specified, little rejection)

Required script:

* [`integrative_model_sims.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/integrative_model_sims.R)

Executing the above script is done with (from `r_scripts/coverage_validation/`):

```
cd r_scripts/coverage_validation/

Rscript integrative_model_sims_yule_bm.R yule_bm -3.25,.2,-2.5,.5 -2.0,.2,-2.5,.5 match 3 300
```

This script will create the following files inside `validation_files_match_3_to_300_tips/`:

* [`true_param_values.RData`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/true_param_values.RData)
* [`true_param_values.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/true_param_values.csv)

Then it will create directory `yule_bm_res/` for MCMC results, and place .xml files into `yule_bm_xmls/`.

## Scenario 2 (misspecified, lots of rejection)

Required script:

* [`integrative_model_sims.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/integrative_model_sims.R)

Executing the above script is done with (from `r_scripts/coverage_validation/`):

```
cd r_scripts/coverage_validation/

Rscript integrative_model_sims.R yule_bm -3.25,.2,-2.5,.5 -2.0,.2,-2.5,.5 mismatch 3 300
```

This script will create the following files inside `validation_files_mismatch_3_to_300_tips`:

* [`true_param_values.RData`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/true_param_values.RData)
* [`true_param_values.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/cobverage_validation/validation_files_mismatch_3_to_300_tips/true_param_values.csv)

Then it will create directory `yule_bm_res/` for MCMC results, and place .xml files into `yule_bm_xmls/`.

## Scenario 3 (correctly specified, lots of rejection)

Required script:

* [`integrative_model_sims.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/integrative_model_sims.R)

Executing the above script is done with (from `r_scripts/coverage_validation/`):

```
cd r_scripts/coverage_validation/

Rscript integrative_model_sims_yule_bm.R yule_bm -3.25,.2,-2.5,.5 -2.0,.2,-2.5,.5 match 100 200
```

This script will create the following files inside validation_files_match_100_to_200_tips:

* [`true_param_values.RData`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_match_100_to_200_tips/true_param_values.RData);
* [`true_param_values.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_match_100_to_200_tips/true_param_values.csv);

Then it will create directory `yule_bm_res/` for MCMC results, and place .xml files into `yule_bm_xmls/`.

## Organizing files for inference

From local machine:

```
cd method_validation_project/r_scripts/coverage_validation/

tar zcvf validation_files_match_3_to_300_tips.tar.gz validation_files_match_3_to_300_tips/
scp validation_files_match_3_to_300_tips.tar.gz [user_name]@[some_cluster]:[some_dir]/r_scripts/coverage_validation/

tar zcvf validation_files_mismatch_3_to_300_tips.tar.gz validation_files_mismatch_3_to_300_tips/
scp validation_files_mismatch_3_to_300_tips.tar.gz [user_name]@[some_cluster]:[some_dir]/r_scripts/coverage_validation/

tar zcvf validation_files_match_100_to_200_tips.tar.gz validation_files_match_100_to_200_tips/
scp validation_files_match_100_to_200_tips.tar.gz [user_name]@[some_cluster]:[some_dir]/r_scripts/coverage_validation/
```

## Running MCMC on cluster

This step should place `.log` and `.trees` files into:

* `validation_files_match_3_to_300_tips/yule_bm_res/`
* `validation_files_match_3_to_300_tips/yule_bm_res/`
* `validation_files_match_3_to_300_tips/yule_bm_res/`

From the server's `r_scripts/coverage_validation/` directory:

```
cd r_scripts/coverage_validation/

tar zcvf validation_files_match_3_to_300_tips_all.tar.gz validation_files_match_3_to_300_tips/*
tar zcvf validation_files_mismatch_3_to_300_tips_all.tar.gz validation_files_mismatch_3_to_300_tips/*
tar zcvf validation_files_match_100_to_200_tips_all.tar.gz validation_files_match_100_to_200_tips/*
```

Then bring these tarballs into local machine, and untar them.

## Summarizing log files

We need to run LogAnalyser, from `r_scripts/coverage_validation/`

```
cd r_scripts/coverage_validation/

cd validation_files_match_3_to_300_tips/yule_bm_res/
loganalyser *.log -oneline > match_3_to_300_tips_yule_bm.tsv
mv match_3_to_300_tips_yule_bm.tsv ../

cd validation_files_mismatch_3_to_300_tips/yule_bm_res/
loganalyser *.log -oneline > mismatch_3_to_300_tips_yule_bm.tsv
mv mismatch_3_to_300_tips_yule_bm.tsv ../

cd validation_files_match_100_to_200_tips/yule_bm_res/
loganalyser *.log -oneline > match_100_to_200_tips_yule_bm.tsv
mv match_100_to_200_tips_yule_bm.tsv ../
```

And now we can check the effective sample sizes (ESSs):

```
cut -f 10,19,28 validation_files_match_3_to_300_tips/match_3_to_300_tips_yule_bm.tsv
cut -f 10,19,28 validation_files_mismatch_3_to_300_tips/mismatch_3_to_300_tips_yule_bm.tsv
cut -f 10,19,28 validation_files_match_100_to_200_tips/match_100_to_200_tips_yule_bm.tsv
```

which are written into:

* [`match_3_to_300_tips_yule_bm.tsv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_match_3_to_300_tips/match_3_to_300_tips_yule_bm.tsv);
* [`mismatch_3_to_300_tips_yule_bm.tsv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/mismatch_3_to_300_tips_yule_bm.tsv);
* [`match_100_to_200_tips_yule_bm.tsv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_match_100_to_200_tips/match_100_to_200_tips_yule_bm.tsv);

## Calculating coverage

This step will parse and tabulate the results from LogAnalyser together with the true values kept from running scenarios 1, 2 and 3.
Coverage is then calculated:

```
cd r_scripts/coverage_validation/

Rscript coverage_analysis.R validation_files_match_3_to_300_tips/ match_3_to_300_tips_yule_bm.tsv yule_bm 130
Rscript coverage_analysis.R validation_files_mismatch_3_to_300_tips/ mismatch_3_to_300_tips_yule_bm.tsv yule_bm 130
Rscript coverage_analysis.R validation_files_match_100_to_200_tips/ match_100_to_200_tips_yule_bm.tsv yule_bm 130
```

The .R script will place the following files inside `coverage_validation/`:

```
covg_match_3_to_300_tips_yule_bm.RData
covg_mismatch_3_to_300_tips_yule_bm.RData
covg_match_100_to_200_tips_yule_bm.RData
```

These will be used for coverage plots in the next step.

## Plotting coverage plots

Now we run a plotting script from the usual root folder of our coverage validation:

```
cd r_scripts/coverage_validation/
Rscript plot_covg.R
```

This script will go through the three tibbles produced in the previous step (and stored in the .RData files), and generate two .tex files:

* [`graphical_model_coverage.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/graphical_model_coverage.tex);
* [`root_age_coverage.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/root_age_coverage.tex);

These two files can be compiled into .pdf figures.
But before we do that, manually open  `graphical_model_coverage.tex` and replace "lambda" with "$\lambda", and "True value (r)" with "True value ($r$)".

## Calculating coverage of Robinson-Foulds statistic

The inference stats on the RF statistic is in file [`coal_RF_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_RF_dist.csv).
How this file was generated is described [here](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/README.md).

We will run the following script to get the inference stats in the shape we want, and plot the coverage graphs:

```
cd r_scripts/coverage_validation/
Rscript coverage_analysis_plot_tree_stat.R
```

This script will generate the following .tex files

* [`RF_coverage.tex``](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/RF_coverage.tex);

This file can be compiled into a .pdf figure.

## Calculating coverage of other tree distances

The .csv files for the other tree distance metrics are in:

* [`coal_max_branch_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_max_branch_dist.csv);
* [`coal_tree_length_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_tree_length_dist.csv);
* [`coal_range_branch_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_range_branch_dist.csv);
* [`coal_KC_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_KC_dist.csv);
* [`coal_BHV_dist.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/coal_BHV_dist.csv);

We will run the following script to get the inference stats in the shape we want, and plot the coverage graphs:

```
cd r_scripts/coverage_validation/
Rscript coverage_analysis_plot_other_tree_stats.R
```

The script will generate the following .tex file:

* [`tree_stats_coverage.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/tree_stats_coverage.tex);

## Calculating coverage of tree topology

This step was executed by Remco. Frequencies are hardcoded into the .R script:

* [`topology_coverage_analysis.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/topology_coverage_analysis.R)

Executing the script will produce the .tex corresponding to the last figure in the supplement.
