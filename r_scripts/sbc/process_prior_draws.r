library(ape)
library(distory)
library(plyr)
library(tidyverse)
source("functionals_sbcPhylo.r")
source("sbc_configs.r")
##############################

load("true_param_values.RData")

prior.draws <- trs
L <- length(prior.draws)

if(do_distances){
  set.seed(the_seed)
  reference.tree <- ape::rtree(n = Ntip(prior.draws[[1]]))
  save(reference.tree, file = "reference_tree.RData")
}

lengths.prior <- unlist(parallel::mclapply(prior.draws, functional_1,
                                           mc.cores = Ncores))
maxbranch.prior <- unlist(parallel::mclapply(prior.draws, functional_2,
                                             mc.cores = Ncores))
rangebranch.prior <- unlist(parallel::mclapply(prior.draws, functional_2b,
                                               mc.cores = Ncores))
bl1.prior <- unlist(parallel::mclapply(prior.draws, functional_3,
                                       mc.cores = Ncores))

if(do_distances){
  RFs.prior <-  unlist(parallel::mclapply(prior.draws, functional_4,
                                          mc.cores = Ncores))
  BHVs.prior <-  unlist(parallel::mclapply(prior.draws, functional_5,
                                           mc.cores = Ncores))
  KCs.prior <-  unlist(parallel::mclapply(prior.draws, functional_6,
                                          mc.cores = Ncores))
}

if(do_distances){
  f.prior <- data.frame(tree_length = lengths.prior,
                        max_branch = maxbranch.prior,
                        range_branch = rangebranch.prior,
                        bl1_length = bl1.prior,
                        RF_dist = RFs.prior,
                        BHV_dist = BHVs.prior,
                        KC_dist  = KCs.prior,
                        data_set = paste0("data_set_", 1:L)
  )
}else{
  f.prior <- data.frame(tree_length = lengths.prior,
                        max_branch = maxbranch.prior,
                        range_branch = rangebranch.prior,
                        bl1_length = bl1.prior,
                        data_set = paste0("data_set_", 1:L)
  )
}
row.names(f.prior) <- NULL

true.df$data_set <- paste0("data_set_", true.df$sim)
true.df$sim <- NULL

f.prior <- plyr::join(f.prior, true.df)

f.prior <- f.prior %>% relocate(data_set, .after = last_col())

save(f.prior, file = "prior_functionals.RData")
