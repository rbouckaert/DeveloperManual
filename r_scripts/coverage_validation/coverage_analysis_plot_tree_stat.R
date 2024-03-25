suppressPackageStartupMessages(library(tidyverse, warn.conflicts = FALSE))
suppressPackageStartupMessages(library(dplyr, warn.conflicts = FALSE))
library(tikzDevice)
options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}", "\\usepackage[T1]{fontenc}", "\\usetikzlibrary{calc}", "\\usepackage{amssymb}"))

pars <- c("RF")

#########################
## Auxiliary functions ##
#########################

check.cov <- function(row) {
    if (row[1] >= row[3] & row[1] <= row[4]) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}

get.plot <- function(p, a.df1, a.df2, y.max, y.min, covg) {
    xlabel = paste0("True value (", p, ")")
    titl = paste0("covg. = ", covg)

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

############################
## Reading stat summaries ##
############################

stat.tb <- as_tibble(read.table("coal_RF_dist.csv", sep=",", head=TRUE))
stat.tb["sim"] <- 1:100
names(stat.tb)[1:4] <- c("RF", "RF.mean", "RF.95.HPDlo", "RF.95.HPDup")


###################################
## Printing coverage on screen   ##
## and adding new in.hpd. column ##
###################################

cat("\n\nCoverage per parameter:\n")
covg <- rep(0.0, length(pars))
i <- 1
for (p in pars) {
    sub.df = stat.tb[,c(p, paste0(p, c(".mean", ".95.HPDlo" , ".95.HPDup")))]
    sub.tot = nrow(sub.df)
    if (sub.tot > 100) {
        sub.df = stat.tb[1:100,c(p, paste0(p, c(".mean", ".95.HPDlo" , ".95.HPDup")))]
    }
    cat("\n", p, "\n")
    if (length(table(apply(sub.df, 1, check.cov))) == 1) {
        cat(" 0.0 or 100.0\n")
    } else {
        sub.tot = nrow(sub.df)
        cat("", 1.0 - table(apply(sub.df, 1, check.cov))[1] / sub.tot, "\n")
        covg[i] = 1.0 - table(apply(sub.df, 1, check.cov))[1] / sub.tot
    }

    cols.2.compare = paste0(p, c("", ".95.HPDlo", ".95.HPDup"))
    new.col = paste0(p, ".in.hpd")
    stat.tb = stat.tb %>% mutate(!!new.col := if_else(
    (!!sym(cols.2.compare[1]) >= !!sym(cols.2.compare[2])) &
    (!!sym(cols.2.compare[1]) <= !!sym(cols.2.compare[3])), TRUE, FALSE))

    ## double-checking we got the right coverages
    cat("\n", p, "\n")
    if (length(table(stat.tb %>% select(!!sym(new.col)))) == 1) {
        cat(" 0.0 or 100.0\n")
    } else {
        cat("", 1.0 - table(stat.tb %>% select(!!sym(new.col)))[1] / sub.tot, "\n")
    }

    i = i + 1
}
cat("... out of ", sub.tot, "\n\n")


##############################
## Making and storing plots ##
##############################

pls <- vector(mode="list", length=length(pars))
i <- 1
for (p in pars) {
    filter.by = paste0(p, ".in.hpd")
    y.max = paste0(p, ".95.HPDup")
    y.min = paste0(p, ".95.HPDlo")

    sub.tb.in = stat.tb %>% filter(!!sym(filter.by) == TRUE)
    sub.tb.out = stat.tb %>% filter(!!sym(filter.by) == FALSE)

    pl = get.plot(p, sub.tb.in, sub.tb.out, y.max, y.min, covg[i])
    pls[[i]] = pl
}

cat("\nMade plots.\n")


###################
## Drawing plots ##
###################
tikz("RF_coverage.tex", width=2.333, height=2, standAlone=TRUE, packages =
    c("\\usepackage{tikz}", "\\usepackage[active,tightpage,psfixbb]{preview}", "\\PreviewEnvironment{pgfpicture}", "\\setlength\\PreviewBorder{0pt}"))

pls[[1]]

dev.off()
