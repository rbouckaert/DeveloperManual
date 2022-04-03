calculate_ranks_draws_matrix_nonrandom <- function (params, dm) 
{
  max_rank <- posterior::ndraws(dm)
  less_matrix <- sweep(dm, MARGIN = 2, STATS = params, FUN = "<")
  rank_min <- colSums(less_matrix)
  equal_matrix <- sweep(dm, MARGIN = 2, STATS = params, FUN = "==")
  rank_range <- colSums(equal_matrix)
  ranks <- rank_min 
  attr(ranks, "max_rank") <- max_rank
  ranks
}

get_hpd <- function(x, alpha = 0.95){
  raw <- coda::HPDinterval(coda::as.mcmc(x), prob = alpha)
  out <- data.frame(
    variable =  rownames(raw),
    hpd_lwr = as.numeric(raw[, "lower"]),
    hpd_upr = as.numeric(raw[, "upper"]),
    attained_hpd = as.numeric(attr(raw, "Probability"))
  )
  return(
    tibble::as_tibble(out)
  )
}

get_statistics <- function(index, thin_ranks = 1,
                           rank_smooth = TRUE) {
  # require(posterior)
  # require(coda)
  # require(dplyr)
  
  parameters <- f.prior[index, ]
  K <- ncol(parameters)
  postdraws <- posterior.summaries[[index]]
  
  if(parameters$data_set != postdraws$data_set[1]){
    stop("Not the same data set")
  }
  if(ncol(postdraws) != K) stop("Parameters and draws don't match")
  
  fit_matrix <- posterior::as_draws_matrix(postdraws[-K])
  
  HPDs <- get_hpd(postdraws[-K])
  
  if(rank_smooth){
    ranks <- SBC:::calculate_ranks_draws_matrix(variables = parameters[-K],
                                                dm = fit_matrix)
  }else{
    ranks <- calculate_ranks_draws_matrix_nonrandom(variables = parameters[-K],
                                                    dm = fit_matrix)
  }
  
  shared_parameters <- intersect(names(parameters),
                           posterior::variables(fit_matrix))
  
  
  # Make sure the order of parameters matches
  
  fit_matrix <- posterior::subset_draws(fit_matrix,
                                        variable = shared_parameters)
  
  fit_thinned <- posterior::thin_draws(fit_matrix, thin_ranks)
  
  stats <- posterior::summarise_draws(fit_matrix)
  stats <- dplyr::rename(stats, variable =  variable)
  stats$simulated_value <- as.numeric(parameters[-K])
  
  if(!identical(stats$variable, names(ranks))) {
    stop("A naming conflict")
  }
  stats$rank <- ranks
  stats$max_rank <- attr(ranks, "max_rank")
  stats$z_score <- (stats$simulated_value - stats$mean) / stats$sd
  
  stats <- dplyr::select(
    stats, variable, simulated_value,
    rank, z_score, tidyselect::everything())
  
  stats$sim_id <- parameters$data_set
  
  return(
    dplyr::left_join(stats, HPDs)
  )
}

#######################################
load(file = "prior_functionals.RData")
load(file = "posterior.RData")

####
## Excluding stuff not tracked in the posterior
f.prior$treeHeight <- f.prior$nTips <- NULL
#### 

L <- length(posterior.summaries)

sbc.results <- do.call(rbind,
                     lapply(1:L, get_statistics))

warnings()
save(sbc.results, file = "SBC_results.RData")