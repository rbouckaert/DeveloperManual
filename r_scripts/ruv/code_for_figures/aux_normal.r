generator_func <- function(N,
                           m0 = 0,
                           v0 = 1,
                           sigma_sq = 1,
                           trunc = 1) {
  theta <- qnorm(p = runif(1, pnorm(trunc), 1),
              mean = m0,
              sd = sqrt(v0))
  
  y <- rnorm(n = N,
             mean = theta,
             sd = sqrt(sigma_sq))
  
  list(variables = list(mu = theta),
       generated = list(N = N,
                        y = y,
                        m0 = m0,
                        v0 = v0,
                        sigma_sq = sigma_sq))
}

normal_posterior <- function(data, ndraws = 500) {
  m0 <- data$m0
  v0 <- data$v0
  ysum <- sum(data$y)
  vstar <- 1 / ((data$N / data$sigma_sq) + (1 / v0))
  mstar <- vstar * (m0 / v0 + ysum / data$sigma_sq)
  
  return(list(
    m_star = mstar,
    v_star = vstar
  ))
}

normal_posterior_draws <- function(fit) {
  posterior.samples <- as.matrix(stats::rnorm(
    n = 200,
    mean = fit$m_star,
    sd = sqrt(fit$v_star)
  ))
  colnames(posterior.samples) <- "mu"
  return(
    posterior::as_draws_matrix(posterior.samples)
  )
}