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

## Phylogenetic Brownian motion (BM) figures

Make sure you have cloned the DeveloperManual repository, and that you go to `r_scripts/` on your terminal (i.e., make it your root folder).
The .R script below will assume that `../figures/` exists.

```
Rscript bm_sim.R
```

This script should put inside of `../figures/`:

* bmsim_leftpanel.pdf
* bmsim_rightpanel.pdf
* bmsim_cis.tex

You can see what `bmsim_cis.tex` looks like by compiling file `bmsim_cis_doc.tex`. 
