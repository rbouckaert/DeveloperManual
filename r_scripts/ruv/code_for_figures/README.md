## Code to generate rank-uniformity validation (RUV) plots

**Dependencies**: **ggplot2**, **tidyverse**, **SBC**, **ggplot2**, **gridExtra**, **cowplot**.

Main scripts:

- [`ruv_conceptual_fig.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/ruv_conceptual_fig.r): creates custom histograms and ECDFs for the 'conceptual' presentation of RUV in Figure 6 of the main text. Due to a bug in cowplot, the panels in the conceptual figure had to be processed via [this](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/output/make_ruv_conceptual.sh) bash script.
- [`make_ruv_figs.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/make_ruv_figs.r): creates custom ECDF and histogram plots for the Yule birth-death models. Forms the basis for Figure 7 in the main text and Supplementary figure 4. 
- [`make_coal_ruv_figs.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/make_coal_ruv_figs.r): plots ECDF and histogram for the Robinson-Foulds metric. Forms the basis for Figure 9 (Box 2) in the main text.
- [`plot_normal_toy.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/plot_normal_toy.r): produces the plot in Supplementary figure 3, describing the misspecified normal model (truncated prior) analysis described in Section 2 of the Supplementary material. See also [`normal_ruv_toy.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/normal_ruv_toy.r).
- [`make_ruv_figs_topological.r`](https://github.com/rbouckaert/DeveloperManual/blob/master/r_scripts/ruv/code_for_figures/make_ruv_figs_topological.r): plots ECDFs and histograms for many tree-specific functionals. Forms the basis of Supplementary Figure 2.




