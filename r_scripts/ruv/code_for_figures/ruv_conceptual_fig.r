library(ggplot2)
# library(gridExtra)
library(cowplot)
##@@@ Inspiration:
## https://dk81.github.io/dkmathstats_site/rvisual-cont-prob-dists.html
## https://github.com/hyunjimoon/RUV/blob/dbbed5dedd3ff0befe25db9bb27f2bf4d0c488eb/R/plot.R
############
##$$ RAP: data-averaged posterior
############
### Underdispersed RAP
s.prior <- 2
s.under <- 1
s.over <- 4
mDisloc <- 5
prior <- function(x)
  dnorm(x, mean = 0, sd = s.prior)
RAP.under <- function(x)
  dnorm(x, mean = 0, sd = s.under)
RAP.over <- function(x)
  dnorm(x, mean = 0, sd = s.over)
RAP.disloc <- function(x)
  dnorm(x, mean = mDisloc, sd = s.prior)

rprior <- function(n)
  rnorm(n = n, mean = 0, sd = s.prior)
rRAP.under <- function(n)
  rnorm(n = n, mean = 0, sd = s.under)
rRAP.over <- function(n)
  rnorm(n = n, mean = 0, sd = s.over)
rRAP.disloc <- function(n)
  rnorm(n = n, mean = mDisloc, sd = s.prior)

#################################
plot_dens <- function(posterior, xl, xu, mh,
                      legend = FALSE) {
  
  a <- 2.85
  b <- 2.85
  
  if (legend) {
    a <- .85
    b <- .85
  }
  
  theplot <- ggplot(data.frame(x = c(xl, xu)),
                    aes(x = x)) +
    stat_function(fun = prior,
                  geom = "area",
                  aes(fill = "Prior"),
                  alpha = 0.25) +
    stat_function(fun = prior) +
    stat_function(fun = posterior,
                  geom = "area",
                  aes(fill = "RAP"),
                  alpha = 0.8) +
    stat_function(fun = posterior) +
    scale_x_continuous(expression(theta),
                       limits = c(xl, xu)) +
    scale_y_continuous("",
                       expand = c(0, 0),
                       limits = c(0, mh)) +
    theme_classic(base_size = 20) +
    scale_fill_manual(
      name = '',
      breaks = c('Prior', 'RAP'),
      values = c('Prior' = 'blue',
                 'RAP' = 'darkblue'),
      guide = guide_legend(override.aes = list(alpha = c(.25, .8)))
    ) +
    theme(
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      legend.position = c(a, b)
    )
  return(theplot)
}

custom_ecdf <- function(ddf, mrank){
   pp <- RUV::plot_ecdf(ddf, max_rank = mrank) +
    theme_classic(base_size = 20) +
    theme(
      legend.position = "none",
      strip.background = element_blank(),
      panel.border = element_blank(),
      axis.line = element_line(),
      strip.text.x = element_blank() 
    )
   return(pp)
}

#########################################
### Prep for RUV rank plot
Nrep <- 1000
max_rank <- 200
n_sims <- Nrep
bins <- 20

Alpha <- 0.95
larger_bin_size <- ceiling(((max_rank + 1) / bins))
smaller_bin_size <- floor(((max_rank + 1) / bins))
larger_bin_size <- ceiling(((max_rank + 1) / bins))
smaller_bin_size <- floor(((max_rank + 1) / bins))
ci_lower <- qbinom(0.5 * (1 - Alpha),
                   size = n_sims,
                   prob  =  smaller_bin_size / max_rank)
ci_mean <- qbinom(0.5,
                  size = n_sims,
                  prob  =  1 / bins)
ci_upper <- qbinom(0.5 * (1 + Alpha),
                   size = n_sims,
                   prob  =  larger_bin_size / max_rank)

CI_polygon_x <-
  c(-0.1 * max_rank,
    0,-0.1 * max_rank,
    1.1 * max_rank,
    max_rank,
    1.1 * max_rank,-0.1 * max_rank)
CI_polygon_y <-
  c(ci_lower,
    ci_mean,
    ci_upper,
    ci_upper,
    ci_mean,
    ci_lower,
    ci_lower)

### End prep
plot_hist <- function(fake.ranks) {
  stats.df <- tibble::tibble(rank = fake.ranks)
  histplot <- ggplot(stats.df, aes(x = rank)) +
    geom_segment(aes(
      x = 0,
      y = ci_mean,
      xend = max_rank,
      yend = ci_mean
    ),
    colour = "grey25") +
    geom_polygon(
      data = data.frame(x = CI_polygon_x, y = CI_polygon_y),
      aes(x = x, y = y),
      fill = "skyblue",
      color = "skyblue1",
      alpha = 0.33
    ) +
    geom_histogram(
      breaks =  seq(0, max_rank, length.out = bins + 1),
      closed = "left" ,
      fill = "#808080",
      colour = "black",
    ) +
    scale_x_continuous("") +
    scale_y_continuous("",
                       expand = c(0, 0)) +
    theme_classic(base_size = 20) +
    theme(
      # axis.ticks.x = element_blank(),
      # axis.text.x = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      legend.position = "none",
      strip.background = element_blank(),
      panel.border = element_blank(),
      axis.line = element_line()
    ) +
    annotate(
      "segment",
      x = -Inf,
      xend = Inf,
      y = -Inf,
      yend = -Inf
    ) +
    annotate(
      "segment",
      x = -Inf,
      xend = -Inf,
      y = -Inf,
      yend = Inf
    )
  return(histplot)
}
#################################
a1 <- 1E-5
xl1 <- qnorm(p = a1, mean = 0, sd = s.over)
xl1 <- xl1 - .2 * xl1
xu1 <- -xl1
mh1 <- dnorm(x = 0, mean = 0, sd = s.under)
mh1 <- mh1 + .05 * mh1

densplot1 <- plot_dens(
  posterior = RAP.over,
  xl = xl1,
  xu = xu1,
  mh = mh1
)

densplot2 <- plot_dens(
  posterior = RAP.under,
  xl = xl1,
  xu = xu1,
  mh = mh1,
  legend = TRUE
)

densplot3 <- plot_dens(
  posterior = RAP.disloc,
  xl = xl1,
  xu = xu1,
  mh = mh1
)

densplot4 <- plot_dens(
  posterior = prior,
  xl = xl1,
  xu = xu1,
  mh = mh1
)
#############

fakeranks.over <- do.call(rbind, parallel::mclapply(1:Nrep, function(i) {
  theta <- rprior(1)
  postdraws <- rRAP.over(n = max_rank)
  r <- sum(postdraws < theta)
  out <- tibble::tibble(sim_id = paste0("rep_", i),
                variable = "mu",
                simulated_value = theta,
                rank = r)
  return(out)
}, mc.cores = 6))

histplot1 <- plot_hist(fake.ranks = fakeranks.over$rank)
cdfplot1 <- custom_ecdf(ddf = fakeranks.over, mrank = max_rank)


fakeranks.under <- do.call(rbind, parallel::mclapply(1:Nrep, function(i) {
  theta <- rprior(1)
  postdraws <- rRAP.under(n = max_rank)
  r <- sum(postdraws < theta)
  out <- tibble::tibble(sim_id = paste0("rep_", i),
                variable = "mu",
                simulated_value = theta,
                rank = r)
  return(out)
}, mc.cores = 6))

histplot2 <- plot_hist(fake.ranks = fakeranks.under$rank)
cdfplot2 <- custom_ecdf(ddf = fakeranks.under, mrank = max_rank)

fakeranks.disloc <- do.call(rbind, parallel::mclapply(1:Nrep, function(i) {
  theta <- rprior(1)
  postdraws <- rRAP.disloc(n = max_rank)
  r <- sum(postdraws < theta)
  out <- tibble::tibble(sim_id = paste0("rep_", i),
                variable = "mu",
                simulated_value = theta,
                rank = r)
  return(out)
}, mc.cores = 6))


histplot3 <- plot_hist(fake.ranks = fakeranks.disloc$rank)
cdfplot3 <- custom_ecdf(ddf = fakeranks.disloc, mrank = max_rank)


fakeranks.correct <- do.call(rbind, parallel::mclapply(1:Nrep, function(i) {
  theta <- rprior(1)
  postdraws <- rprior(max_rank)
  r <- sum(postdraws < theta)
  out <- tibble::tibble(sim_id = paste0("rep_", i),
                        variable = "mu",
                        simulated_value = theta,
                        rank = r)
  return(out)
}, mc.cores = 6))


histplot4 <- plot_hist(fake.ranks = fakeranks.correct$rank)
cdfplot4 <- custom_ecdf(ddf = fakeranks.correct, mrank = max_rank)


### Final plot

pp1 <- plot_grid(ggplotGrob(densplot1),
                 ggplotGrob(histplot1),
                 ggplotGrob(cdfplot1),
                 labels = "(a)",
          ncol = 3, align = "h", axis = "b")


pp2 <- plot_grid(ggplotGrob(densplot2),
                 ggplotGrob(histplot2),
                 ggplotGrob(cdfplot2),
                 labels = "(b)",
                 ncol = 3, align = "h", axis = "b")

pp3 <- plot_grid(ggplotGrob(densplot3),
                 ggplotGrob(histplot3),
                 ggplotGrob(cdfplot3),
                 labels = "(c)",
                 ncol = 3, align = "h", axis = "b")

pp4 <- plot_grid(ggplotGrob(densplot4),
                 ggplotGrob(histplot4),
                 ggplotGrob(cdfplot4),
                 labels = "(d)",
                 ncol = 3, align = "h", axis = "b")

ggsave(
  plot = pp1,
  filename = "../figures/ruv_conceptual_1.pdf",
  scale = 1,
  width = 297,
  height = 210/3.1,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = pp2,
  filename = "../figures/ruv_conceptual_2.pdf",
  scale = 1,
  width = 297,
  height = 210/3.1,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = pp3,
  filename = "../figures/ruv_conceptual_3.pdf",
  scale = 1,
  width = 297,
  height = 210/3.1,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = pp4,
  filename = "../figures/ruv_conceptual_4.pdf",
  scale = 1,
  width = 297,
  height = 210/3.1,
  units = "mm",
  dpi = 300
)

final.plot <- plot_grid(
  pp1, pp2, pp3, pp4,
  ncol = 1
)

ggsave(
  plot = final.plot,
  filename = "../figures/buggy_conceptual.pdf",
  scale = 1,
  width = 297,
  height = 210,
  units = "mm",
  dpi = 300
)
