# Validating a simulator

Below we document how to obtain the data and figures for validating simulators (Yule and phylogenetic Brownian motion)

## Validating a Yule simulator

Required script:

* [`yule_exp_height.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/other/yule_exp_height.R)

Executing the above script is done with (from `r_scripts/other/`):

```
Rscript yule_exp_height.R
```

This script will generate the `.tex` tikz file to produce the right-hand side panel of figure 3 from the main manuscript (it is made into a two-panel figure, with a table to its left, within the manuscript `.tex` itself):

* [`yule_exp_height.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/yule_exp_height.tex)

This panel can be compiled on its own:

* [`yule_exp_height.pdf`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/yule_exp_height.pdf)

## Validating a phylogenetic Brownian motion simulator

Required script:

* [`phylobm_exp_vcv.R`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/other/phylobm_exp_vcv.R)
	
As done above, this script is run by:

```
Rscript phylobm_exp_vcv.R
```

This script will generate:

(i) the panel to the right of figure 2 ([`phylobm_exp_vcv_rightpanel.pdf`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/phylobm_exp_vcv_rightpanel.pdf))

(ii) the `.tex` document to make supplementary figure 1 ([`phylobm_exp_vcv_cis.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/phylobm_exp_vcv_cis.tex))
	
Output (i) is assembled into figure 2 using Illustrator ([`phylobm_exp_vcv.pdf`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/phylobm_exp_vcv.pdf)), which we converted into a `.png` ([`phylobm_exp_vcv.png`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/phylobm_exp_vcv.png)).

Output (ii) is compiled into supplementary figure 1 within the supplementary material text.
It is also possible to see what this figure looks like on its own by compiling [`phylobm_exp_vcv_doc.tex`](https://github.com/rbouckaert/DeveloperManual/blob/master/figures/phylobm_exp_vcv_doc.tex).
