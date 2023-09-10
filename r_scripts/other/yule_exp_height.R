library(tikzDevice)
library(phytools)
library(TreeSim)
library(plotrix)
library(ggplot2)

output.path <- "../../figures/"

set.seed(666)

get.exp.tr.h <- function(n.t, birth.rate) {
    sum.res = 0.0
    for (i in 2:n.t) {
        sum.res = sum.res + (1.0 / (i * birth.rate))
    }

    sum.res
}

get.tr.h <- function(a.tr) {
    max(nodeHeights(a.tr))
}

# starting experiment
n.taxa <- 20 # number of species
n.sim <- 5000 # total number of trees (later: 100 data sets of 50 trees)
birth.rates <- seq(0.5, 1.0, by=0.1) # lambdas
exp.tr.hs <- sapply(birth.rates, FUN=get.exp.tr.h, n.t=n.taxa) # expected t_root

trs.list <- rep(list(vector(mode="list", length=n.sim)), length(birth.rates)) # store trees
obs.hs <- rep(list(rep(0.0, n.sim)), length(birth.rates)) # store heights

# simulating trees (takes a while)
for (j in 1:length(birth.rates)) {
    trs = sim.bd.taxa(lambda=birth.rates[j], mu=0.0, n=n.taxa, numbsim=n.sim)
    obs.hs[[j]] = sapply(trs, get.tr.h)
    trs.list[[j]] = trs
}

# dividing into smaller data sets, counting % of time in 95%-CI
i.s <- seq(1, n.sim, n.sim/100)
insides <- rep(0, length(birth.rates))
for (j in 1:length(birth.rates)) {

    chunk.j.obs.hs = obs.hs[[j]]
    inside = 0
    for (i in i.s) {
        chunk.obs.hs = chunk.j.obs.hs[i:(i + n.sim/100 - 1)]
        mean.obs.h = mean(chunk.obs.hs)
        stderr.h = std.error(chunk.obs.hs)
        lower.h = mean.obs.h - 1.96*stderr.h
        upper.h = mean.obs.h + 1.96*stderr.h

        if ((exp.tr.hs[j] > lower.h) & (exp.tr.hs[j] < upper.h)) { inside = inside + 1 }
        # print(paste0("Exp[t]=", exp.tr.hs[2], " [", lower.h, ", ", upper.h, "]"))
    }

    print(paste0("Inside=", inside))
    insides[j] = inside
}

# plotting all samples for visualization
global.mean.obs.h <- sapply(obs.hs, FUN=mean)
global.stderr.h <- sapply(obs.hs, FUN=std.error)
global.lower.h <- global.mean.obs.h - 1.96*stderr.h
global.upper.h <- global.mean.obs.h + 1.96*stderr.h

df <- data.frame(birth.rates, exp.tr.hs, global.mean.obs.h, global.lower.h, global.upper.h)

tikz(paste0(output.path, "yule_exp_height.tex"), width=3, height=2, standAlone=TRUE, packages=c("\\usepackage{tikz}", "\\usepackage{libertine}", "\\usepackage{amsmath}"))
p <- ggplot(df, aes(x=birth.rates, y=exp.tr.hs)) + geom_line(aes(lty="$\\text{E}[t_{\\text{root}}]$")) + geom_ribbon(aes(ymin=global.lower.h, ymax=global.upper.h), alpha=0.3, fill="lightblue") + xlab("Birth rate ($\\lambda$)") + ylab("$t_{\\text{root}}$") + theme_classic() + scale_linetype_manual("", values=c("dotted"))
p
dev.off()
