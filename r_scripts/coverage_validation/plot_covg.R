library(ggplot2)
library(gridExtra)
suppressPackageStartupMessages(library(tidyverse, warn.conflicts = FALSE))
suppressPackageStartupMessages(library(dplyr, warn.conflicts = FALSE))
library(tikzDevice)
options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}", "\\usepackage[T1]{fontenc}", "\\usetikzlibrary{calc}", "\\usepackage{amssymb}"))

## run from coverage_validation/

get.plot <- function(p, a.df1, a.df2, y.max, y.min, covg) {
    if (p == "birthRate") {
        ## xlabel = "True value (\u03bb)"
        xlabel = paste0("True value (", expression(lambda), ")")
        titl = paste0("covg. = ", covg)
    }  else if (p == "bmRate") {
        xlabel = "True value (r)"
        titl = paste0("covg. = ", covg)
    } else {
        xlabel = "True value (root age)"
        titl = paste0("covg. = ", covg)
    }

    pl = ggplot() + ggtitle(titl) +
        geom_linerange(data=a.df1, mapping=aes(x=!!sym(p), ymax=!!sym(y.max), ymin=!!sym(y.min)), color="lightblue", alpha=0.5, linewidth=2) +
        geom_linerange(data=a.df2, mapping=aes(x=!!sym(p), ymax=!!sym(y.max), ymin=!!sym(y.min)), color="red", alpha=.4, linewidth=2) +
        geom_abline(slope=1, linetype="dotted") +
        geom_point(data=a.df1, mapping=aes(y=!!sym(paste0(p, ".mean")), x=!!sym(p)), size=.5) +
        geom_point(data=a.df2, mapping=aes(y=!!sym(paste0(p, ".mean")), x=!!sym(p)), size=.5) +
        scale_size(range=c(3,.5)) +
        theme_classic() + ylab("Posterior mean") + xlab(xlabel) +
        theme(
            plot.title = element_text(size=10),
            axis.text = element_text(size=8),
            plot.margin = margin(t=4, r=8, b=8))

    pl
}

load("covg_match_3_to_300_tips_yule_bm.RData")
covg.match.3.300.tib <- enough.ess.no.na.full.tib
## print(covg.match.3.300.tib, n=20, width=Inf)

load("covg_mismatch_3_to_300_tips_yule_bm.RData")
covg.mismatch.3.300.tib <- enough.ess.no.na.full.tib
## print(covg.mismatch.3.300.tib, n=20, width=Inf)

load("covg_match_100_to_200_tips_yule_bm.RData")
covg.match.100.200.tib <- enough.ess.no.na.full.tib
## print(covg.match.100.200.tib, n=20, width=Inf)

cat("\nLoaded tibbles.\n")

## covg <- c(98, 97, 0, 70, 95, 94) # before looking at tree height
covg <- c(98, 97, 96, 0, 70, 5, 95, 94, 98) # looking at tree height

## pls <- vector(mode="list", length=6)
pls <- vector(mode="list", length=9)
i <- j <- 1
for (p in c("birthRate", "bmRate", "tree.height")) {
    filter.by = paste0(p, ".in.hpd")
    y.max = paste0(p, ".95.HPDup")
    y.min = paste0(p, ".95.HPDlo")

    sub.tib.in1 = covg.match.3.300.tib %>% filter(!!sym(filter.by) == TRUE)
    sub.tib.out1 = covg.match.3.300.tib %>% filter(!!sym(filter.by) == FALSE)
    sub.tib.in2 = covg.mismatch.3.300.tib %>% filter(!!sym(filter.by) == TRUE)
    sub.tib.out2 = covg.mismatch.3.300.tib %>% filter(!!sym(filter.by) == FALSE)
    sub.tib.in3 = covg.match.100.200.tib %>% filter(!!sym(filter.by) == TRUE)
    sub.tib.out3 = covg.match.100.200.tib %>% filter(!!sym(filter.by) == FALSE)

    pl1 = get.plot(p, sub.tib.in1, sub.tib.out1, y.max, y.min, covg[i])
    ## pl2 = get.plot(p, sub.tib.in2, sub.tib.out2, y.max, y.min, covg[i+2]) # before tree height
    ## pl3 = get.plot(p, sub.tib.in3, sub.tib.out3, y.max, y.min, covg[i+4]) # before tree height
    pl2 = get.plot(p, sub.tib.in2, sub.tib.out2, y.max, y.min, covg[i+3]) # looking at tree height
    pl3 = get.plot(p, sub.tib.in3, sub.tib.out3, y.max, y.min, covg[i+6]) # looking at tree height

    j = i
    pls[[j]] = pl1
    j = j+3
    pls[[j]] = pl2
    j = j+3
    pls[[j]] = pl3
    i = i+1
}

cat("\nMade plots.\n")

## col.titles = paste("Scenario ", c(1,1,2,2,3,3)) # before looking at tree height
col.titles = paste("Scenario ", c(1,1,1,2,2,2,3,3,3)) # looking at tree height

cat("\nWriting .tex figure with tikz...\n\n")

tikz("graphical_model_coverage.tex", width=7, height=4, standAlone=TRUE, packages =
    c("\\usepackage{tikz}", "\\usepackage[active,tightpage,psfixbb]{preview}", "\\PreviewEnvironment{pgfpicture}", "\\setlength\\PreviewBorder{0pt}"))

grid.arrange(grobs = lapply(c(1,4,7), function(i) {
  arrangeGrob(grobs=pls[i:(i+1)], top=col.titles[i], ncol=1)
}), ncol=3, as.table = FALSE) # no tree height (6 plots)
## grid.arrange(grobs = lapply(c(1,4,7), function(i) {
##   arrangeGrob(grobs=pls[i:(i+2)], top=col.titles[i], ncol=1)
## }), ncol=3, as.table = FALSE) # tree height (9 plots)

dev.off()

tikz("root_age_coverage.tex", width=7, height=2, standAlone=TRUE, packages =
    c("\\usepackage{tikz}", "\\usepackage[active,tightpage,psfixbb]{preview}", "\\PreviewEnvironment{pgfpicture}", "\\setlength\\PreviewBorder{0pt}"))

grid.arrange(pls[[3]], pls[[6]], pls[[9]], nrow=1)

dev.off()

## trying a single plot

## p <- "tree.height"
## y.max <- paste0(p, ".95.HPDup")
## y.min <- paste0(p, ".95.HPDlo")
## filter.by <- paste0(p, ".in.hpd")
## sub.tib.in <- covg.match.3.300.tib %>% filter(!!sym(filter.by) == TRUE)
## sub.tib.out <- covg.match.3.300.tib %>% filter(!!sym(filter.by) == FALSE)
## pl <- get.plot(p, sub.tib.in, sub.tib.out, y.max, y.min, "96")
