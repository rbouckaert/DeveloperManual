library(tidyverse)
library(SBC)
library(ggplot2)

all.covs <- read_csv("../data/normal_toy_RUV_example_coverage.csv")
all.stats <-
  read_csv("../data/normal_toy_RUV_example_RUV_stats.csv")

all.covs %>% print(n = 50)

all.covs <- all.covs %>%
  mutate(passed = (width >= ci_low & width <= ci_high))

############
### Adapting plot
## Shamelessly cribbed from https://github.com/hyunjimoon/RUV/blob/dbbed5dedd3ff0befe25db9bb27f2bf4d0c488eb/R/plot.R#L96
n_sims <-
  dplyr::summarise(dplyr::group_by(all.stats, variable),
                   count = dplyr::n())$count

max_rank <- all.stats$max_rank
max_rank <- unique(max_rank)
n_sims <- unique(n_sims) / 9
# bins <- RUV:::guess_rank_hist_bins(max_rank, n_sims)
bins <- 20

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

all.stats <- all.stats %>%
  mutate(trunc = factor(paste("t =", trunc),
                        levels = c("t = 0",
                                   "t = 1",
                                   "t = 1.5")))

all.stats <- all.stats %>%
  mutate(n_obs = factor(paste("K =", n_obs),
                        levels = c("K = 5",
                                   "K = 10",
                                   "K = 50")))

final.plot <- ggplot(all.stats, aes(x = rank)) +
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
    colour = "black"
  ) +
  labs(y = "count") +
  facet_grid(n_obs ~ trunc, scales = "free") +
  theme_classic(base_size = 20) +
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

ggsave(
  plot = final.plot,
  filename = "../figures/ruv_normal.pdf",
  scale = 1,
  width = 297,
  height = 210,
  units = "mm",
  dpi = 300
)
