library(tidyverse) ## str_sort()
library(dplyr)
library(stringr)
library(gtools) ## mixedsort()

args <- commandArgs(trailingOnly=TRUE)
wd <- args[1]
inf.res <- paste0(wd, args[2])
prefix <- args[3]
n.sim <- args[4]


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

return.not.enough.ess.idxs <- function(a.df, col.name.vec) {
    idxs <- c()
    for (i in 1:nrow(a.df)) {
        for (col.name in col.name.vec) {
            if (a.df[i,col.name] < 200.0) {
                if (!(i %in% idxs)) {
                    idxs <- append(idxs, i)
                }
            }
        }
    }
    idxs
}

##############################
## Path and setup variables ##
##############################

## linux
## wd <- "/home/binho/Documents/academic_gitrepos/method_validation_project/r_scripts/validation_files_match_3_to_300_tips_prior_only/"
## wd <- "/home/binho/Documents/academic_gitrepos/method_validation_project/r_scripts/validation_files_mismatch_3_to_300_tips_prior_only/"
## wd <- "/home/binho/Documents/academic_gitrepos/method_validation_project/r_scripts/validation_files_match_100_to_200_tips/"

## mac
## wd <- "/Users/binho/Documents/academic_repos/method_validation_project/r_scripts/coverage_validation/validation_files_match_3_to_300_tips/"
## wd <- "/Users/binho/Documents/academic_repos/method_validation_project/r_scripts/coverage_validation/validation_files_mismatch_3_to_300_tips/"
## wd <- "/Users/binho/Documents/academic_repos/method_validation_project/r_scripts/coverage_validation/validation_files_match_100_to_200_tips/"

## inference results from LogAnalyser
## inf.res <- paste0(wd, "match_3_to_300_tips_yule_bm.tsv")
## inf.res <- paste0(wd, "mismatch_3_to_300_tips_yule_bm.tsv")
## inf.res <- paste0(wd, "match_100_to_200_tips_yule_bm.tsv")

## prefix <- "yule_bm"
## prefix <- "coal_bm"

## n.sim <- 130


##################################################
## Reading in inference results and cleaning up ##
##################################################

## looking at logs and grabbing problematic ones if there are any
res.dir <- paste0(wd, paste0(prefix, "_res/"))
all.logs <- list.files(path=res.dir, pattern="*.log")
all.logs <- str_sort(all.logs, numeric=T)

missing.logs <- c()
for (i in 1:n.sim) {
    f.name = paste0(prefix, i, ".log")

    if (file.exists(paste0(res.dir, f.name))) {
        cat(paste0("Found ", f.name, "\n"))
    } else {
        missing.logs = append(missing.logs, i) # fast, so will append...
    }
}

inf.df <- read.table(inf.res, header=T, row.names=NULL, stringsAsFactors=FALSE)
idx.order <- match(mixedsort(inf.df$filename), inf.df$filename)
inf.df <- inf.df[idx.order,]

## getting names right
## for (i in 1:ncol(inf.df)) {
##     names(inf.df)[i] = gsub("birthDiffRate", "birthRate", names(inf.df)[i])
## }

## parameters and cols from inf.df we care about
inf.stats <- c(".mean", ".95.HPDlo", ".95.HPDup", ".ESS")
pars <- c("birthRate", "bmRate", "tree.height")
## pars <- c("popSize", "bmRate")
cols.2.grab <- paste0(rep(pars, each=length(inf.stats)), inf.stats)

## now grab and insert missing data in the right rows
inf.mean.hpd <- inf.df[,cols.2.grab]
n.cols.2.insert <- length(cols.2.grab)

for (i in missing.logs) {
    # inserting empty rows for the failed runs
    inf.mean.hpd = rbind(inf.mean.hpd[1:(i-1),], rep(NA, n.cols.2.insert), inf.mean.hpd[-(1:(i-1)),])
}
row.names(inf.mean.hpd) <- seq(1, n.sim) # renumbering rows


#################
## True values ##
#################

rdata <- paste0(wd, "true_param_values.RData")
load(rdata)


#############
## Merging ##
#############

full.df <- cbind(true.df, inf.mean.hpd)
no.na.full.df <- na.omit(full.df) # removing failed runs


##########################
## Throw away ESS < 200 ##
##########################

cols.2.check <- paste0(pars, ".ESS")
small.ess.idxs <- return.not.enough.ess.idxs(no.na.full.df, cols.2.check)

enough.ess.no.na.full.df <- no.na.full.df[-small.ess.idxs,]
names(enough.ess.no.na.full.df)[4] <- pars[3] # renaming treeHeight

#################################
## Printing coverage on screen ##
#################################

tot = nrow(enough.ess.no.na.full.df)
cat("\n\nCoverage per parameter:\n")
for (p in pars) {
    sub.df = enough.ess.no.na.full.df[,c(p, paste0(p, c(".mean", ".95.HPDlo" , ".95.HPDup")))]
    sub.tot = nrow(sub.df)
    if (tot > 100) {
        sub.df = enough.ess.no.na.full.df[1:100,c(p, paste0(p, c(".mean", ".95.HPDlo" , ".95.HPDup")))]
    }
    cat("\n", p, "\n")
    if (length(table(apply(sub.df, 1, check.cov))) == 1) {
        cat(" 0.0 or 100.0\n")
    } else {
        sub.tot = nrow(sub.df)
        cat("", 1.0 - table(apply(sub.df, 1, check.cov))[1] / sub.tot, "\n")
    }
}
cat("... out of ", sub.tot, "\n\n")


##################
## Saving RData ##
##################

## rdata.fp <- str_replace(paste0("covg_", "match_3_to_300_tips_yule_bm.tsv"), ".tsv", ".RData")
## rdata.fp <- str_replace(paste0("covg_", "mismatch_3_to_300_tips_yule_bm.tsv"), ".tsv", ".RData")
## rdata.fp <- str_replace(paste0("covg_", "match_100_to_200_tips_yule_bm.tsv"), ".tsv", ".RData")
rdata.fp <- str_replace(paste0("covg_", args[2]), ".tsv", ".RData")

## dplyr quotes its arguments, so the variable 'new.col' ends up being used
## as a string (and column name in the tibble), and appears as "new.col"
##
## here, however, we already have a quoted string inside 'new.col', so we want
## to tell dplyr to evaluate new.col and grab that string before doing its job
##
## that's what the bang-bang operator, '!!', does -- we need to in turn use the
## vestigial operator ':=', which allows for expressions on both sides of it
##
## we are also forcing the evaluation and extraction of column names as strings,
## stored into cols.2.compare with '!!', and then converting them into R objects
## with sym()
##
## note that we are also using '&' instead of '&&'
cat("Storing in tibbles, and double-checking:\n")
enough.ess.no.na.full.tib <- as_tibble(enough.ess.no.na.full.df)
if (tot > 100) {
    enough.ess.no.na.full.tib <- enough.ess.no.na.full.tib %>% slice_head(n=100)
}

for (p in pars) {
    cols.2.compare <- paste0(p, c("", ".95.HPDlo", ".95.HPDup"))
    new.col = paste0(p, ".in.hpd")
    enough.ess.no.na.full.tib <- enough.ess.no.na.full.tib %>% mutate(
                                                       !!new.col := if_else(
                                                       (!!sym(cols.2.compare[1]) >= !!sym(cols.2.compare[2])) &
                                                       (!!sym(cols.2.compare[1]) <= !!sym(cols.2.compare[3])), TRUE, FALSE))
    cat("\n", p, "\n")
    if (length(table(enough.ess.no.na.full.tib %>% select(!!sym(new.col)))) == 1) {
        cat(" 0.0 or 100.0\n")
    } else {
        cat("", 1.0 - table(enough.ess.no.na.full.tib %>% select(!!sym(new.col)))[1] / sub.tot, "\n")
    }
}


save(enough.ess.no.na.full.tib, file=rdata.fp)

cat("\nWrote:", rdata.fp, "\n")
