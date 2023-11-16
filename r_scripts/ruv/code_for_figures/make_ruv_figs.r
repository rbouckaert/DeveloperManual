library(tidyverse)
library(SBC)
library(ggplot2)
library(gridExtra)
library(cowplot)
##########################
make_ecdf_custom_plot <- function(x, k = 1){
  
  scn <- paste0("Scenario_", k)
  ddf <- subset(x, scenario == scn)
  ddf <- ddf %>% mutate(scenario = gsub("_", " ", scn))
  ddf <- ddf %>% mutate(variable = gsub("_", " ", scn))
  
  pp <- plot_ecdf(ddf) +
    theme_classic(base_size = 10) +
    scale_x_continuous("Normalized rank") +
    scale_y_continuous("Cumulative probability") +
    theme(
      legend.position = "none",
      strip.background = element_blank(),
      panel.border = element_blank(),
      axis.line = element_line()
    ) 
  
  return(pp)
}

make_hist_custom_plot <- function(x, k = 1){
  
  scn <- paste0("Scenario_", k)
  ddf <- subset(x, scenario == scn)
  ddf <- ddf %>% mutate(scenario = gsub("_", " ", scn))
  ddf <- ddf %>% mutate(variable = gsub("_", " ", scn))
  
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
    facet_grid(~scenario) +
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
s1 <- read_csv("../data/RUV_scenario_1.csv")
s2 <- read_csv("../data/RUV_scenario_2.csv")
s3 <- read_csv("../data/RUV_scenario_3.csv")

raw.comb <- do.call(rbind, list(s1, s2, s3))

# n_sims <-
#   dplyr::summarise(dplyr::group_by(raw.comb, variable),
#                    count = dplyr::n())$count
# n_sims <- unique(n_sims)
n_sims <- 100

max_rank <- raw.comb$max_rank
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

lambda.df <- subset(raw.comb, variable == "birthRate")
r.df <- subset(raw.comb, variable == "bmRate")

l.hist.s1 <- make_hist_custom_plot(lambda.df, k = 1)
l.hist.s2 <- make_hist_custom_plot(lambda.df, k = 2)
l.hist.s3 <- make_hist_custom_plot(lambda.df, k = 3)

r.hist.s1 <- make_hist_custom_plot(r.df, k = 1)
r.hist.s2 <- make_hist_custom_plot(r.df, k = 2)
r.hist.s3 <- make_hist_custom_plot(r.df, k = 3)

l.cdf.s1 <- make_ecdf_custom_plot(lambda.df, k = 1)
l.cdf.s2 <- make_ecdf_custom_plot(lambda.df, k = 2)
l.cdf.s3 <- make_ecdf_custom_plot(lambda.df, k = 3)

r.cdf.s1 <- make_ecdf_custom_plot(r.df, k = 1)
r.cdf.s2 <- make_ecdf_custom_plot(r.df, k = 2)
r.cdf.s3 <- make_ecdf_custom_plot(r.df, k = 3)


lambda.plot <- plot_grid(
  cbind(ggplotGrob(l.hist.s1),
        ggplotGrob(l.hist.s2),
        ggplotGrob(l.hist.s3)),
  cbind(ggplotGrob(l.cdf.s1),
        ggplotGrob(l.cdf.s2),
        ggplotGrob(l.cdf.s3)),
  align = "v",
  axis = "b",
  labels = c("(a)", "(b)"),
  label_size = 12,
  ncol = 1
)

lambda.plot


r.plot <- plot_grid(
  cbind(ggplotGrob(r.hist.s1),
        ggplotGrob(r.hist.s2),
        ggplotGrob(r.hist.s3)),
  cbind(ggplotGrob(r.cdf.s1),
        ggplotGrob(r.cdf.s2),
        ggplotGrob(r.cdf.s3)),
  align = "v",
  axis = "b",
  labels = c("(a)", "(b)"),
  label_size = 12,
  ncol = 1
)

r.plot

ggsave(
  plot = r.plot,
  filename = "../figures/ruv_Yule_BM_r.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)

ggsave(
  plot = lambda.plot,
  filename = "../figures/ruv_Yule_lambda.pdf",
  scale = 1,
  width = 297,
  height = 210/1.5,
  units = "mm",
  dpi = 300
)
