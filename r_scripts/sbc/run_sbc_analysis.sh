#!/bin/bash
Rscript process_prior_draws.r
Rscript process_posterior_draws.r
Rscript generate_SBC.r

