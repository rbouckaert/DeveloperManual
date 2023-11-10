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

This script will create the following files inside `validation_files_match_3_to_300_tips`:

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
* [`true_param_values.csv`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/true_param_values.csv)

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

* `validation_files_match_3_to_300_tips/yule_bm_res`
* `validation_files_match_3_to_300_tips/yule_bm_res`
* `validation_files_match_3_to_300_tips/yule_bm_res`

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

## Calculating coverage

This step will parse and tabulate the results from LogAnalyser together with the true values kept from running scenarios 1, 2 and 3.
Coverage is then calculated:

```
cd r_scripts/coverage_validation/

Rscript coverage_analysis.R validation_files_match_3_to_300_tips/ match_3_to_300_tips_yule_bm.tsv yule_bm 130
Rscript coverage_analysis.R validation_files_mismatch_3_to_300_tips/ mismatch_3_to_300_tips_yule_bm.tsv yule_bm 130
Rscript coverage_analysis.R validation_files_match_100_to_200_tips/ match_100_to_200_tips_yule_bm.tsv yule_bm 130
```

The .R script will place the following files inside `coverage_validation/`

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
But before we do that, manually open  [`graphical_model_coverage.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/coverage_validation/graphical_model_coverage.tex) and replace "lambda" with "$\lambda", and "True value (r)" with "True value ($r$)".
