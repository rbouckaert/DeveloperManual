library(tidyverse)
covs <- read_csv(file = "../data/normal_toy_RUV_example_coverage.csv")
res <- covs %>% mutate(passes = (width >= ci_low) * (width <= ci_high) )

write_csv(subset(res, width == 0.95),
          file = "covs_95_raw.csv")

subset(res, passes == 1)
