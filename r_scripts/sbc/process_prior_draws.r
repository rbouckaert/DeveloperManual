library(ape)
library(distory)
library(plyr)
library(tidyverse)
source("functionals_sbcPhylo.r")
##############################

load("true_param_values.RData")

# all.trees <- trs
# reference.tree <- 
# save(reference.tree, file = "reference_tree.RData")

prior.draws <- trs
L <- length(prior.draws)

lengths.prior <- unlist(lapply(prior.draws, functional_1))
maxbranch.prior <- unlist(lapply(prior.draws, functional_2))
rangebranch.prior <- unlist(lapply(prior.draws, functional_2b))
bl1.prior <- unlist(lapply(prior.draws, functional_3))
# RFs.prior <-  unlist(lapply(prior.draws, functional_4))
# BHVs.prior <-  unlist(lapply(prior.draws, functional_5))
# KCs.prior <-  unlist(lapply(prior.draws, functional_6))

f.prior <- data.frame(tree_length = lengths.prior,
                     max_branch = maxbranch.prior,
                     range_branch = rangebranch.prior,
                     bl1_length = bl1.prior,
                     # RF_dist = RFs.prior,
                     # BHV_dist = BHVs.prior,
                     # KC_dist  = KCs.prior,
                     data_set = paste0("data_set_", 1:L)
)
row.names(f.prior) <- NULL

true.df$data_set <- paste0("data_set_", true.df$sim)
true.df$sim <- NULL

f.prior <- plyr::join(f.prior, true.df)

f.prior <- f.prior %>% relocate(data_set, .after = last_col())

save(f.prior, file = "prior_functionals.RData")