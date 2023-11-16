library(tidyverse)
library(SBC)
library(ggplot2)
library(gridExtra)
library(cowplot)
##########################
make_ecdf_custom_plot <- function(x){
  pp <- plot_ecdf(x) +
    ggtitle("") +
    theme_classic(base_size = 10) +
    scale_x_continuous("Normalized rank") +
    scale_y_continuous("Cumulative probability") +
    theme(
      legend.position = "none",
      strip.background = element_blank(),
      panel.border = element_blank(),
      axis.line = element_line(),
      strip.text.x = element_blank()
    ) 
  
  return(pp)
}

make_hist_custom_plot <- function(x){
  
  pp <- ggplot(x, aes(x = rank)) +
    geom_segment(aes(
      x = 0,
      y = ci_mean,
      xend = max_rank,
      yend = ci_mean
    ),
    colour = "grey25") +
    scale_x_continuous("Rank") + 
    scale_y_continuous("Count", expand = c(0, 0)) + 
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
      colour = "black"
    ) +
    labs(y = "count") +
    theme_classic(base_size = 10) +
    theme(
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
  
  return(pp)
  
}

cov_plot <- function(p, a.df1, a.df2, y.max, y.min, covg) {
  
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
  
  pl <- ggplot() + ggtitle(titl) +
    geom_linerange(
      data = a.df1,
      mapping = aes(
        x = !!sym(p),
        ymax = !!sym(y.max),
        ymin = !!sym(y.min)
      ),
      color = "lightblue",
      alpha = 0.5,
      linewidth = 2
    ) +
    geom_linerange(
      data = a.df2,
      mapping = aes(
        x = !!sym(p),
        ymax = !!sym(y.max),
        ymin = !!sym(y.min)
      ),
      color = "red",
      alpha = .4,
      linewidth = 2
    ) +
    geom_abline(slope = 1, linetype = "dotted") +
    geom_point(
      data = a.df1,
      mapping = aes(y = !!sym(paste0(p, ".mean")), x = !!sym(p)),
      size = .5
    ) +
    geom_point(
      data = a.df2,
      mapping = aes(y = !!sym(paste0(p, ".mean")), x = !!sym(p)),
      size = .5
    ) +
    scale_size(range = c(3, .5)) +
    theme_classic() + ylab("Posterior mean") + xlab(xlabel) +
    theme(
      plot.title = element_text(size = 10),
      axis.text = element_text(size = 8),
      plot.margin = margin(t = 4, r = 8, b = 8)
    )
  
  pl
}

##########################

for.coverage <- subset(ruv.coal, variable == "RF_dist")[, c("simulated_value", "mean", "q5", "q95")]
write_csv(for.coverage, "../data/SBC_coal_RF_coverage.csv")

n_sims <- 100

max_rank <- ruv.coal$max_rank
max_rank <- unique(max_rank)

bins <- SBC:::guess_rank_hist_bins(max_rank, n_sims)

Alpha <- 0.95

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
    0,
    -0.1 * max_rank,
    1.1 * max_rank,
    max_rank,
    1.1 * max_rank,
    -0.1 * max_rank)

CI_polygon_y <-
  c(ci_lower,
    ci_mean,
    ci_upper,
    ci_upper,
    ci_mean,
    ci_lower,
    ci_lower)

###############

RF.df <- subset(ruv.coal, variable == "RF_dist")

rf.hist <- make_hist_custom_plot(RF.df)
rf.cdf <- make_ecdf_custom_plot(RF.df)


rf.plot <- plot_grid(
  rf.hist,
  rf.cdf,
  align = "v",
  axis = "b",
  labels = c("(a)", "(b)"),
  label_size = 12,
  ncol = 2
)

rf.plot

ggsave(
  plot = rf.plot,
  filename = "../figures/ruv_coal_RF.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = rf.hist,
  filename = "../figures/ruv_coal_RF_hist.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = rf.cdf,
  filename = "../figures/ruv_coal_RF_ECDF.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)

