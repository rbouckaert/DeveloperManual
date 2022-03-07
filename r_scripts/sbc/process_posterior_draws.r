library(ape)
library(distory)
library(tidyverse)
source("functionals_sbcPhylo.r")

burn_and_thin <- function(dt, b, k){
  N <- nrow(dt)
  nb <- round(b*N) + 1
  burned <- dt[nb:N, ]
  Nstar <- nrow(burned)
  thinned <- burned[round(seq(1, Nstar, length.out = k)), ]
  return(thinned)
}
organise_posterior_draws <- function(post_draws, i, bnin, nkeep){
  out <- data.frame(
    birthRate = post_draws$birthDiffRate,
    bmRate = post_draws$bmRate
  )
  row.names(out) <- NULL
  out <- data.frame(out, data_set = paste0("data_set_", i))
  out <- burn_and_thin(dt = out, b = bnin, k = nkeep)
  return(out)
}

organise_posterior_draws_tree <- function(post_draws, i, bnin, nkeep){
  
  lengths <- unlist(lapply(post_draws, functional_1))
  maxbranch <- unlist(lapply(post_draws, functional_2))
  rangebranch <- unlist(lapply(post_draws, functional_2b))
  bl1 <- unlist(lapply(post_draws, functional_3))
  # RFs <-  unlist(lapply(post_draws, functional_4))
  # BHVs <-  unlist(lapply(post_draws, functional_5))
  # KCs <-  unlist(lapply(post_draws, functional_6))
  
  out <- data.frame(tree_length = lengths,
                  max_branch = maxbranch,
                  range_branch = rangebranch,
                  bl1_length = bl1
                  # RF_dist = RFs,
                  # BHV_dist = BHVs,
                  # KC_dist = KCs
  )
  row.names(out) <- NULL
  out <- data.frame(out, data_set = paste0("data_set_", i))
  out <- burn_and_thin(dt = out, b = bnin, k = nkeep)
  return(out)
}

process_postfile <- function(fl, index, burnin, n_keep, tree = TRUE){
  if(tree){
    draws <- ape::read.nexus(fl)
    ans <- organise_posterior_draws_tree(post_draws = draws, i = index,
                                         bnin = burnin, nkeep = n_keep)
  }else{
    draws <- read.table(fl, header = TRUE)
    ans <- organise_posterior_draws(post_draws = draws, i = index,
                                    bnin = burnin, nkeep = n_keep)
  }
  return(ans)
}

get_index <- function(fl, tree = TRUE){
  if(tree){
    ans <- gsub(".trees", "", gsub(".*/yule_bm", "", fl))
  }else{
    ans <- gsub(".log", "", gsub(".*/yule_bm", "", fl))
  }
  return(as.numeric(ans))
}

##############################

# load(file = "reference_tree.RData")

tree.post.files <- system("ls sampled_trees/*.trees", intern = TRUE)
tree.inds <- sapply(tree.post.files, get_index)
sorted.tree.post.files <- names(sort(tree.inds))

K <- length(sorted.tree.post.files)

logs.post.files <- system("ls sampled_logs/*.log", intern = TRUE)
logs.inds <- sapply(logs.post.files, get_index, FALSE)
sorted.logs.post.files <- names(sort(logs.inds))

f.burnin <- 0.1
n.keep <- 50

posterior.summaries <- parallel::mclapply(1:K, function(i){
  trees <- process_postfile(fl = sorted.tree.post.files[i], index = i,
                            burnin = f.burnin, n_keep = n.keep)
  continuous <- process_postfile(fl = sorted.logs.post.files[i],
                                 index = i, tree = FALSE,
                                 burnin = f.burnin, n_keep = n.keep)
  trees$data_set <- NULL
  out <- cbind(trees, continuous)
  return(out)
}, mc.cores = 8)

save(posterior.summaries,
     file = "posterior.RData")
