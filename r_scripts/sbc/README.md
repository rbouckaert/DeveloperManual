## Scripts for simulation-based calibration of phylogenetic algorithms

This implements the techiniques in [Talts et al. (2018)](https://arxiv.org/abs/1804.06788), which are also extensively discussed in the vignettes of the excellent [**SBC**](https://github.com/hyunjimoon/SBC) package, upon which many of the routines in the scripts here depend.

**Dependencies**: **distory** (**ape** too), **tidyverse**, **SBC**, **dplyr**. 

Main scripts are
- [`sbc_configs.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/sbc_configs.r): stores the configurations of the whole SBC analysis: whether to use distances, how many posterior samples to keep, etc. 
- [`functionals_sbcPhylo.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/functionals_sbcPhylo.r): includes the functionals to be computed on a set of posterior draws (of trees).
- [`process_prior_draws.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/process_prior_draws.r): computes functionals on the data-generating trees and binds with data-generating continuous parameters.
- [`process_posterior_draws.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/process_posterior_draws.r): does the same as above, but for the posterior samples.
- [`generate_SBC.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/generate_SBC.r): runs the actual SBC machinery.
- [`analyse_SBC.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/analyse_SBC.r): produces figures and tables.
- [`run_sbc_analysis.sh`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/run_sbc_analysis.sh): shell script to run everything at once.
- [`clean.sh`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/sbc/clean.sh): delete output files so one can start clean. 

### Steps to run an analysis

In the same directory as the above files, create two directories: `sampled_trees/` and `sampled_logs/`, which will contain the `.trees`and `.log` files, respectively.

Then you might want to:
- Check that a file named `true_param_values.RData` exists in the root folder, containing the "true" (data-generating) trees and continuous parameter values;
- Modify the function `get_index()` in `process_posterior_draws.r` to accommodate your naming conventions;
- Check that `f.burnin` and `n.keep`in process_posterior_draws.r` are to your liking;


Finally, you will want to run 
```
./run_sbc_analysis.sh
```

If you need to re-do the computations and want to start afresh, do

```
./clean.sh
```
