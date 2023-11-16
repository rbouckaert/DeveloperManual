library(SBC)
library(tidyverse)
library(ggplot2)
source("aux_normal.r")
####################################
### Special backend code

# Setup caching of results
cache_dir <- "./conjugate_normal"

if (!dir.exists(cache_dir)) {
  dir.create(cache_dir)
}

SBC_backend_analyticNormal <- function(...) {
  args = list(...)
  if (any(names(args) == "data")) {
    stop(
      paste0(
        "Argument 'data' cannot be provided when defining a backend",
        " as it needs to be set by the SBC package"
      )
    )
  }
  
  structure(list(args = args), class = "SBC_backend_analyticNormal")
}

SBC_fit.SBC_backend_analyticNormal <-
  function(backend, generated, cores) {
    args_with_data <- c(backend$args, generated)
    fit <- normal_posterior(data = args_with_data)
    normal_posterior_draws(fit)
  }

# SBC_fit_to_draws_matrix.analyticNormal <- function(fit) {
#   normal_posterior_draws(fit)
# }

SBC_backend_iid_draws.SBC_backend_analyticNormal <-
  function(backend) {
    TRUE
  }

run_simu <- function(nobs) {
  generator_1 <-
    SBC_generator_function(
      generator_func,
      N = nobs,
      m0 = mz,
      v0 = vz,
      sigma_sq = var.y,
      trunc = truncs[1]
    )
  
  generator_2 <-
    SBC_generator_function(
      generator_func,
      N = nobs,
      m0 = mz,
      v0 = vz,
      sigma_sq = var.y,
      trunc = truncs[2]
    )
  
  generator_3 <-
    SBC_generator_function(
      generator_func,
      N = nobs,
      m0 = mz,
      v0 = vz,
      sigma_sq = var.y,
      trunc = truncs[3]
    )
  
  datasets_1 <- generate_datasets(generator_1, Nrep)
  datasets_2 <- generate_datasets(generator_2, Nrep)
  datasets_3 <- generate_datasets(generator_3, Nrep)
  
  results_1 <- compute_SBC(
    datasets_1,
    normal_backend,
    cache_mode = "results",
    cache_location = file.path(cache_dir, "normal1")
  )
  results_2 <- compute_SBC(
    datasets_2,
    normal_backend,
    cache_mode = "results",
    cache_location = file.path(cache_dir, "normal2")
  )
  results_3 <- compute_SBC(
    datasets_3,
    normal_backend,
    cache_mode = "results",
    cache_location = file.path(cache_dir, "normal3")
  )
  
  coverage_1 <- empirical_coverage(results_1$stats,
                                   width = c(0.5, 0.9, 0.95))
  coverage_1$trunc <- truncs[1]
  
  coverage_2 <- empirical_coverage(results_2$stats,
                                   width = c(0.5, 0.9, 0.95))
  coverage_2$trunc <- truncs[2]
  
  coverage_3 <- empirical_coverage(results_3$stats,
                                   width = c(0.5, 0.9, 0.95))
  coverage_3$trunc <- truncs[3]
  
  all.coverages <-
    Reduce(rbind,
           list(coverage_1, coverage_2, coverage_3))
  all.coverages$n_obs <- nobs
  
  s1 <- results_1$stats
  s1$trunc <- truncs[1]
  
  s2 <- results_2$stats
  s2$trunc <- truncs[2]
  
  s3 <- results_3$stats
  s3$trunc <- truncs[3]
  
  all.stats <- Reduce(rbind,
                      list(s1, s2, s3))
  all.stats$n_obs <- nobs
  
  out <- list(coverage.df = all.coverages,
              stats.df = all.stats)
  
  return(out)
}
###########################################
###########################################
mz <- 0
vz <- 1
var.y <- 1

normal_backend <- SBC_backend_analyticNormal(m0 = mz,
                                             v0 = vz,
                                             sigma_sq = var.y)
Nrep <- 500
truncs <- c(0, 1, 3 / 2)
Ns <- c(5, 10, 50)
simu.time <- system.time(simus <- lapply(Ns, run_simu))

simu.time

covs <- do.call(rbind,
                lapply(simus, function(x)
                  x$coverage.df))

stats <- do.call(rbind,
                 lapply(simus, function(x)
                   x$stats.df))

s1 <- simus[[1]]$stats.df
s2 <- simus[[2]]$stats.df
s3 <- simus[[3]]$stats.df

all.ruv.df <- Reduce(rbind, list(s1, s2, s3))

write_csv(all.ruv.df,
          file =  "../data/normal_toy_RUV_example_RUV_stats.csv")

SBC::plot_coverage(subset(s1, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[1]))

SBC::plot_coverage(subset(s1, trunc == truncs[2])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[2]))

SBC::plot_coverage(subset(s1, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[3]))

SBC::plot_coverage(subset(s2, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[1]))

SBC::plot_coverage(subset(s2, trunc == truncs[2]))
ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[2]))

SBC::plot_coverage(subset(s2, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[2]))

SBC::plot_coverage(subset(s3, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[1]))

SBC::plot_coverage(subset(s3, trunc == truncs[2])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[2]))

SBC::plot_coverage(subset(s3, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[3]))

SBC::plot_rank_hist(subset(s1, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[1]))

SBC::plot_rank_hist(subset(s1, trunc == truncs[2])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[2]))

SBC::plot_rank_hist(subset(s1, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[1], " truncation: ", truncs[3]))

SBC::plot_rank_hist(subset(s2, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[1]))

SBC::plot_rank_hist(subset(s2, trunc == truncs[2])) +
  ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[2]))

SBC::plot_rank_hist(subset(s2, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[2], " truncation: ", truncs[3]))

SBC::plot_rank_hist(subset(s3, trunc == truncs[1])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[1]))

SBC::plot_rank_hist(subset(s3, trunc == truncs[2])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[2]))

SBC::plot_rank_hist(subset(s3, trunc == truncs[3])) +
  ggtitle(paste0("N=", Ns[3], " truncation: ", truncs[3]))

## A look at the coverages
covs %>% print(n = 50)

write_csv(covs,
          file = "../data/normal_toy_RUV_example_coverage.csv")
