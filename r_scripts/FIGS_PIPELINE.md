# Pipeline for reproducing figures

## Required software

* R, LaTeX compiler
* R packages: 
  * mvMORPH
  * ggplot2
  * ggpubr
  * gridExtra
  * tikzDevice
  * plotrix
  * psychometric
  * TreeSim

## Phylogenetic Brownian motion (BM) figures

Make sure you have cloned the DeveloperManual repository, and that you go to `r_scripts/` on your terminal (i.e., make it your root folder).
The .R script below will assume that `../figures/` exists.
On the terminal:

```
Rscript bm_sim.R
```

This script should put inside of `../figures/`:

* bmsim_leftpanel.pdf
* bmsim_rightpanel.pdf
* bmsim_cis.tex

You can see what `bmsim_cis.tex` looks like by compiling file `bmsim_cis_doc.tex`. 

## Integrative model "well-calibrated" validation

### Running the simulations

Again, make sure you have `r_scripts/` as your root folder.
Then on the terminal:

```
Rscript integrative_model_sims.R yule_bm -3.25,.2,-2.5,.5 -4.25,.2,-2.5,.5 match
```

The first argument after the script name is the prefix that will appear before file names.
The second argument is a string specifying the log-mean and log-standard deviation of the Yule birth-rate LN prior, and then of the PhyloBM evolutionary rate LN prior.
The third argument means the same as the second argument, except that this will be used in inference should the fourth argument be "mismatch".
The fourth argument sets the simulation and inference model to be the same if "match", and to be different (see third argument) if "mismatch".

This script will create a directory called `validation_files`, and inside that directory it will create `foo_xmls` and `foo_res` where `foo` is the specified prefix (first argument above).

It is your job to then run the `.xml` files produced by this pipeline.

### Parsing the MCMC results