is_in <- function(x, l, u){
  below <- x >= l
  above <- x <= u
  result <- as.logical(below * above)
  return(result)
}
#######
library(SBC)
library(dplyr)
library(ggplot2)
source("sbc_configs.r")

load(file = "SBC_results.RData")

cat("----- Processing SBC output....------", "\n")

sbc.results$covers <- is_in(x = sbc.results$simulated_value,
                            l = sbc.results$q5,
                            u = sbc.results$q95)

sbc.results$hpd_covers <- is_in(x = sbc.results$simulated_value,
                                l = sbc.results$hpd_lwr,
                                u = sbc.results$hpd_upr)


if(do_distances){
  par.levels <- c( "tree_length",  "max_branch",   "range_branch",
                   "bl1_length",
                   "birthRate", "bmRate",
                   "BHV_dist", "KC_dist", "RF_dist") 
}else{
  par.levels <- c( "tree_length",  "max_branch",   "range_branch",
                   "bl1_length",
                   "birthRate", "bmRate") 
}

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
    RF_dist = "RF[0](tau)",
    BHV_dist = "BHV[0](tau)",
    KC_dist = "KC[0](tau)"
  )
  return(
    plyr::llply(as.character(newval),
                function(x) parse(text = x))
  )
}

ecdf_plot <- SBC::plot_ecdf(sbc.results) +
  facet_wrap(~factor(variable,
                     levels = par.levels),
             labeller = custom_label_parsed) +
  theme_bw(base_size = 20)

hist_plot <- SBC::plot_rank_hist(sbc.results) +
  facet_wrap(~factor(variable,
                     levels = par.levels),
             labeller = custom_label_parsed) +
  theme_bw(base_size = 20)


interval_plot <- ggplot(
  data = sbc.results,
  aes(x = simulated_value, y = mean, colour = hpd_covers)
) + 
  geom_pointrange(data = sbc.results,
                  mapping = aes(x = simulated_value, y = mean,
                                ymin = hpd_lwr, ymax = hpd_upr,
                                colour = hpd_covers)) +
  facet_wrap(~factor(variable,
                     levels = par.levels),
             labeller = custom_label_parsed,
             scales = "free") +
  scale_x_continuous("Generating value") + 
  scale_y_continuous("Posterior mean (HPD)") + 
  geom_abline(intercept = 0, slope = 1,
              linetype = "longdash") + 
  theme_bw(base_size = 20)


ggsave(
  file = "plot_SBC_ECDF.pdf",
  plot = ecdf_plot,
  scale = 1,
  width = 297,
  height = 210,
  units = "mm",
  dpi = 300
)

ggsave(
  file = "plot_SBC_histogram.pdf",
  plot = hist_plot,
  scale = 1,
  width = 297,
  height = 210,
  units = "mm",
  dpi = 300
)

ggsave(
  file = "plot_SBC_intervals.pdf",
  plot = interval_plot,
  scale = 1,
  width = 297,
  height = 210,
  units = "mm",
  dpi = 300
)

## Coverage
mean_ci <- function(x, alpha = 0.95){
  n <- length(x)
  qs <- qbinom(p = c(.025, .975), size = n, prob = alpha)
  return(
    c(
      mean = mean(x),
      lwr = qs[1]/n,
      upr = qs[2]/n
    )
  )
}

coverage_bci <- aggregate(covers ~ variable, mean_ci,
                          alpha = .95, data = sbc.results)
coverage_hpd <- aggregate(hpd_covers ~ variable, mean_ci,
          alpha = .95, data = sbc.results)

bci_table <- tibble::as_tibble(as.matrix(coverage_bci))
names(bci_table) <- c("quantity", "coverage", "cover_lwr", "cover_upr")

hpd_table <- tibble::as_tibble(as.matrix(coverage_hpd))
names(hpd_table) <- c("quantity", "coverage", "cover_lwr", "cover_upr")

write.table(x = bci_table, file  = "bci.txt", sep = "\t", row.names = FALSE)
write.table(x = hpd_table, file  = "hpd.txt", sep = "\t", row.names = FALSE)

bci.latex <- xtable::xtable(bci_table)
hpd.latex <- xtable::xtable(hpd_table)

print(bci.latex, file  = "bci.tex")
print(hpd.latex, file  = "hpd.tex")
