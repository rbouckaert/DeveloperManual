library(tidyverse)
library(SBC)
library(ggplot2)
library(gridExtra)
library(cowplot)
##########################
par.levels <- c(
  "tree_length",
  "max_branch",
  "range_branch",
  "bl1_length",
  "birthRate",
  "bmRate",
  "BHV_dist",
  "KC_dist",
  "RF_dist"
)

par_factor <- function(x) {
  factor(x, par.levels)
}

custom_label_parsed <- function (variable, value) {
  newval <- dplyr::recode(
    value,
    tree_length = "LEN(Phi)",
    range_branch = "R(Phi)",
    max_branch = "LB(Phi)",
    bl1_length = "T[1](Phi)",
    birthRate = "lambda",
    bmRate = "r",
    RF_dist = "RF[0](Phi)",
    BHV_dist = "BHV[0](Phi)",
    KC_dist = "KC[0](Phi)"
  )
  return(plyr::llply(as.character(newval),
                     function(x)
                       parse(text = x)))
}


make_ecdf_custom_plot <- function(x, parname){
  
  ddf <- subset(x, variable == parname)
  
  pp <- plot_ecdf(ddf) +
    theme_classic(base_size = 10) +
    scale_x_continuous("Normalized rank") +
    scale_y_continuous("Cumulative probability") +
    facet_wrap( ~ factor(variable,
                         levels = par.levels),
                labeller = custom_label_parsed) +
    theme(
      legend.position = "none",
      strip.background = element_blank(),
      panel.border = element_blank(),
      axis.line = element_line()
    )
  
  return(pp)
}

make_hist_custom_plot <- function(x, parname){
  
  ddf <- subset(x, variable == parname)  

  pp <- ggplot(ddf, aes(x = rank)) +
    geom_segment(aes(
      x = 0,
      y = ci_mean,
      xend = max_rank,
      yend = ci_mean
    ),
    colour = "grey25") +
    scale_x_continuous("Rank") + 
    scale_y_continuous("Count", expand = c(0, 0)) + 
    facet_wrap( ~ factor(variable,
                         levels = par.levels),
                labeller = custom_label_parsed) +
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
##########################
raw <- read_csv("../data/RUV_topological.csv")

# n_sims <-
#   dplyr::summarise(dplyr::group_by(raw, variable),
#                    count = dplyr::n())$count
# n_sims <- unique(n_sims)
n_sims <- 100

max_rank <- raw$max_rank
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

h.len <- make_hist_custom_plot(raw, parname = "tree_length" )
c.len <- make_ecdf_custom_plot(x = raw, parname = "tree_length")

h.maxb <- make_hist_custom_plot(raw, parname = "max_branch" )
c.maxb <- make_ecdf_custom_plot(x = raw, parname = "max_branch")

h.rgb <- make_hist_custom_plot(raw, parname = "range_branch" )
c.rgb <- make_ecdf_custom_plot(x = raw, parname = "range_branch")

h.rf <- make_hist_custom_plot(raw, parname = "RF_dist" )
c.rf <- make_ecdf_custom_plot(x = raw, parname = "RF_dist")

h.bhv <- make_hist_custom_plot(raw, parname = "BHV_dist" )
c.bhv <- make_ecdf_custom_plot(x = raw, parname = "BHV_dist")

h.kc <- make_hist_custom_plot(raw, parname = "KC_dist" )
c.kc <- make_ecdf_custom_plot(x = raw, parname = "KC_dist")


cdf.plot <- plot_grid(
  cbind(ggplotGrob(c.len),
        ggplotGrob(c.maxb),
        ggplotGrob(c.rgb)),
  cbind(ggplotGrob(c.bhv),
        ggplotGrob(c.kc),
        ggplotGrob(c.rf)),
  align = "v",
  axis = "b",
  labels = "",
  label_size = 12,
  ncol = 1
)

cdf.plot

hist.plot <- plot_grid(
  cbind(ggplotGrob(h.len),
        ggplotGrob(h.maxb),
        ggplotGrob(h.rgb)),
  cbind(ggplotGrob(h.bhv),
        ggplotGrob(h.kc),
        ggplotGrob(h.rf)),
  align = "v",
  axis = "b",
  labels = "",
  label_size = 12,
  ncol = 1
)

hist.plot

ggsave(
  plot = cdf.plot,
  filename = "../figures/ruv_coalescent_ecdfs.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = hist.plot,
  filename = "../figures/ruv_coalescent_histograms.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)
