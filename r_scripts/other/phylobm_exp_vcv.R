library(mvMORPH)
library(ggplot2)
library(ggpubr) ## for ggscatter()
library(psychometric) ## for CIr()
library(gridExtra) ## for grid.arrange()
library(plotrix) ## std.error()
library(tikzDevice)

output.path <- "../../figures/"

ci.var <- function(obs.var, alpha, n) {
    df = n-1
    chisq.v = qchisq(c(alpha/2, 1-alpha/2), df)
    ci.var = (n-1) / chisq.v
    return(obs.var * ci.var)
}

check.ci <- function(start, end, value, reverse=FALSE) {
    if (reverse == TRUE) {
        if (start > value && end < value) return(TRUE)
    } else {
        if (start < value && end > value) return(TRUE)
    }
    FALSE
}

plot.cis <- function(value, out.ci.idx, main.title, xlab, cis, xlims) {
    colors = rep("lightskyblue", 100)
    colors[out.ci.idx] = "red"

    plot(-10,
         xlim = xlims,
         ylim = c(1, 100),
         ylab = "Sample",
         xlab = xlab,
         main = main.title,
         bty = "l")

    for (j in 1:100) {
        lines(c(cis[j, 1], cis[j, 2]),
        c(j, j),
        col = colors[j],
        lwd = 2)
    }

    abline(v = value, lty = 2)
    # recordPlot()
}

tr <- read.newick(text="((A:1.0,B:1.0):5.0,C:6.0);")

set.seed(123)
n.sim <- 10000
n.rep <- 100

sims <- as.data.frame(t(mvSIM(tr, nsim=n.sim, model="BM1", param=list(ntraits=1, sigma=0.1, theta=0.0))))
sims.list <- vector(mode="list", length=n.rep)

j <- 1
for (i in seq(1, n.sim, n.rep)) {
    sims.list[[j]] = sims[i:(i+n.rep-1),]
    j = j+1
}

ab.plot <- ggscatter(sims[1:1000,], x="A", y="B", ellipse=TRUE, shape=20, size=.75, alpha=.25) +
    xlim(-3,3) + ylim(-3,3) + xlab(expression("y"["A"])) + ylab(expression("y"["B"])) +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

ac.plot <- ggscatter(sims[1:1000,], x="A", y="C", ellipse=TRUE, shape=20, size=.75, alpha=.25) +
    xlim(-3,3) + ylim(-3,3) + xlab(expression("y"["A"])) + ylab(expression("y"["C"])) +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

bc.plot <- ggscatter(sims[1:1000,], x="B", y="C", ellipse=TRUE, shape=20, size=.75, alpha=.25) +
    xlim(-3,3) + ylim(-3,3) + xlab(expression("y"["B"])) + ylab(expression("y"["C"])) +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

a.plot <- ggplot(sims[1:1000,], aes(x=A)) + geom_histogram(aes(y =..density..), bins=10, fill = "gray") +
    stat_function(fun = dnorm, args = list(mean = mean(sims[1:1000,]$B), sd = sd(sims[1:1000,]$A))) +
    xlim(-2.8,2.8) + xlab(expression("y"["A"])) + ylab("Density") +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

b.plot <- ggplot(sims[1:1000,], aes(x=B)) + geom_histogram(aes(y =..density..), bins=10, fill = "gray") +
    stat_function(fun = dnorm, args = list(mean = mean(sims[1:1000,]$B), sd = sd(sims[1:1000,]$B))) +
    xlim(-2.8,2.8) + xlab(expression("y"["B"])) + ylab("Density") +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

c.plot <- ggplot(sims[1:1000,], aes(x=C)) + geom_histogram(aes(y =..density..), bins=10, fill = "gray") +
    stat_function(fun = dnorm, args = list(mean = mean(sims[1:1000,]$B), sd = sd(sims[1:1000,]$C))) +
    xlim(-2.8,2.8) + xlab(expression("y"["C"])) + ylab("Density") +
    theme_classic() +
    theme(panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA))

gr <- list(a.plot, ab.plot, b.plot, ac.plot, bc.plot, c.plot)

ci.a.df <- data.frame(matrix(ncol=2, nrow=100))
ci.b.df <- data.frame(matrix(ncol=2, nrow=100))
ci.c.df <- data.frame(matrix(ncol=2, nrow=100))
ci.var.a.df <- data.frame(matrix(ncol=2, nrow=100))
ci.var.b.df <- data.frame(matrix(ncol=2, nrow=100))
ci.var.c.df <- data.frame(matrix(ncol=2, nrow=100))
ci.cor.ab.df <- data.frame(matrix(ncol=2, nrow=100))
ci.cor.ac.df <- data.frame(matrix(ncol=2, nrow=100))
ci.cor.bc.df <- data.frame(matrix(ncol=2, nrow=100))

is.a.within.ci <- rep(FALSE, n.rep)
is.b.within.ci <- rep(FALSE, n.rep)
is.c.within.ci <- rep(FALSE, n.rep)
is.var.a.within.ci <- rep(FALSE, n.rep)
is.var.b.within.ci <- rep(FALSE, n.rep)
is.var.c.within.ci <- rep(FALSE, n.rep)
is.cor.a.within.ci <- rep(FALSE, n.rep)
is.cor.b.within.ci <- rep(FALSE, n.rep)
is.cor.c.within.ci <- rep(FALSE, n.rep)
is.cor.ab.within.ci <- rep(FALSE, n.rep)
is.cor.ac.within.ci <- rep(FALSE, n.rep)
is.cor.bc.within.ci <- rep(FALSE, n.rep)
exp.cor.ab <- 0.5 / 0.6
exp.cor.ac <- 0.0
exp.cor.bc <- 0.0

j <- 1
for (j in 1:n.rep) {
    jth.sim = sims.list[[j]]

    m.a = mean(jth.sim$A)
    m.b = mean(jth.sim$B)
    m.c = mean(jth.sim$C)
    v.a = var(jth.sim$A)
    v.b = var(jth.sim$B)
    v.c = var(jth.sim$C)
    se.a = std.error(jth.sim$A)
    se.b = std.error(jth.sim$B)
    se.c = std.error(jth.sim$C)
    cor.ab = cor(jth.sim$A, jth.sim$B)
    cor.ac = cor(jth.sim$A, jth.sim$C)
    cor.bc = cor(jth.sim$B, jth.sim$C)

    ## CI for mean trait value of A
    ci.a = c(m.a - 1.96 * se.a, m.a + 1.96 * se.a)
    ci.a.df[j,] = ci.a

    ## CI for mean trait value of B
    ci.b = c(m.b - 1.96 * se.b, m.b + 1.96 * se.b)
    ci.b.df[j,] = ci.b

    ## CI for mean trait value of C
    ci.c = c(m.c - 1.96 * se.c, m.c + 1.96 * se.c)
    ci.c.df[j,] = ci.c

    ## CI for trait-value var of A
    ci.var.a = ci.var(v.a, 0.05, 100)
    ci.var.a.df[j,] = ci.var.a

    ## CI for trait-value var of B
    ci.var.b = ci.var(v.b, 0.05, 100)
    ci.var.b.df[j,] = ci.var.b

    ## CI for trait-value var of C
    ci.var.c = ci.var(v.c, 0.05, 100)
    ci.var.c.df[j,] = ci.var.c

    ## the CI is built by first transforming r into Fisher's Z, which is normally distributed,
    ## see (https://support.sas.com/resources/papers/proceedings/proceedings/sugi31/170-31.pdf)

    ## CI for trait-value correlation b/w A and B
    ci.cor.ab = CIr(r=cor.ab, n=100, level = .95)
    ci.cor.ab.df[j,] = ci.cor.ab

    ## CI for trait-value correlation b/w A and C
    ci.cor.ac = CIr(r=cor.ac, n=100, level = .95)
    ci.cor.ac.df[j,] = ci.cor.ac

    ## CI for trait-value correlation b/w B and C
    ci.cor.bc = CIr(r=cor.bc, n=100, level = .95)
    ci.cor.bc.df[j,] = ci.cor.bc

    ## seeing if within CI for mean trait values
    is.a.within.ci[j] = check.ci(ci.a[1], ci.a[2], 0.0)
    is.b.within.ci[j] = check.ci(ci.b[1], ci.b[2], 0.0)
    is.c.within.ci[j] = check.ci(ci.c[1], ci.c[2], 0.0)

    ## seeing if within CI for vars
    is.var.a.within.ci[j] = check.ci(ci.var.a[1], ci.var.a[2], 0.6, reverse=TRUE)
    is.var.b.within.ci[j] = check.ci(ci.var.b[1], ci.var.b[2], 0.6, reverse=TRUE)
    is.var.c.within.ci[j] = check.ci(ci.var.c[1], ci.var.c[2], 0.6, reverse=TRUE)

    ## seeing if wihin CI for corrs
    is.cor.ab.within.ci[j] = check.ci(ci.cor.ab[1], ci.cor.ab[2], exp.cor.ab)
    is.cor.ac.within.ci[j] = check.ci(ci.cor.ac[1], ci.cor.ac[2], exp.cor.ac)
    is.cor.bc.within.ci[j] = check.ci(ci.cor.bc[1], ci.cor.bc[2], exp.cor.bc)

    j = j + 1
}

table(is.a.within.ci) # mean A, 95
table(is.b.within.ci) # mean B, 97
table(is.c.within.ci) # mean C, 98
table(is.var.a.within.ci) # var A, 93
table(is.var.b.within.ci) # var B, 97
table(is.var.c.within.ci) # var C, 97
table(is.cor.ab.within.ci) # cor A, 96
table(is.cor.ac.within.ci) # cor B, 96
table(is.cor.bc.within.ci) # cor C, 97

## second batch of graphs
out.a.idx <- which(!is.a.within.ci)
out.b.idx <- which(!is.b.within.ci)
out.c.idx <- which(!is.c.within.ci)

out.var.a.idx <- which(!is.var.a.within.ci)
out.var.b.idx <- which(!is.var.b.within.ci)
out.var.c.idx <- which(!is.var.c.within.ci)

out.cor.ab.idx <- which(!is.cor.ab.within.ci)
out.cor.ac.idx <- which(!is.cor.ac.within.ci)
out.cor.bc.idx <- which(!is.cor.bc.within.ci)

## pl.a <- plot.cis(0.0, out.a.idx, expression(paste("CI"["95"], " of y"["A"])), ci.a.df, c(-.5,.5))
## pl.b <- plot.cis(0.0, out.b.idx, expression(paste("CI"["95"], " of y"["B"])), ci.b.df, c(-.5,.5))
## pl.c <- plot.cis(0.0, out.c.idx, expression(paste("CI"["95"], " of y"["C"])), ci.c.df, c(-.5,.5))

## pl.var.a <- plot.cis(0.6, out.cor.ab.idx, expression(paste("CI"["95"], " of Var[y"["A"], "]")), ci.var.a.df, c(.2,1.25))
## pl.var.b <- plot.cis(0.6, out.var.b.idx, expression(paste("CI"["95"], " of Var[y"["B"], "]")), ci.var.b.df, c(.2,1.25))
## pl.var.c <- plot.cis(0.6, out.var.c.idx, expression(paste("CI"["95"], " of Var[y"["C"], "]")), ci.var.c.df, c(.2,1.25))

## pl.cor.ab <- plot.cis(exp.cor.ab, out.cor.ab.idx, expression(paste("CI"["95"], " of Cor[y"["A"], ", y"["B"], "]")), ci.cor.ab.df, c(0.6,1.0))
## pl.cor.ac <- plot.cis(exp.cor.ac, out.cor.ac.idx, expression(paste("CI"["95"], " of Cor[y"["A"], ", y"["C"], "]")), ci.cor.ac.df, c(-.6,.5))
## pl.cor.bc <- plot.cis(exp.cor.bc, out.cor.bc.idx, expression(paste("CI"["95"], " of Cor[y"["B"], ", y"["C"], "]")), ci.cor.bc.df, c(-.6,.5))

pdf(file=paste0(output.path, "phylobm_exp_vcv_rightpanel.pdf"), width=5, height=5)
grid.arrange(grobs = gr, layout_matrix=rbind(c(1, NA, NA), c(2, 3, NA), c(4, 5, 6)))
dev.off()

## pdf(file=paste0(output.path, "bmsim_leftpanel.pdf"), width=4, height=4)
## plot(tr)
## dev.off()

cat("\n\nPreparing tikz figure. Takes a little while...\n\n")

tikz(file=paste0(output.path, "phylobm_exp_vcv_cis.tex"))
par(mfrow=c(3,3))
plot.cis(0.0, out.a.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of y"["A"])), expression("y"["A"]), ci.a.df, c(-.5,.5))
plot.cis(0.0, out.b.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of y"["B"])), expression("y"["B"]), ci.b.df, c(-.5,.5))
plot.cis(0.0, out.c.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of y"["C"])), expression("y"["C"]), ci.c.df, c(-.5,.5))
plot.cis(0.6, out.cor.ab.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Var[y"["A"], "]")), expression(paste("Var[y"["A"], "]")), ci.var.a.df, c(.2,1.25))
plot.cis(0.6, out.var.b.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Var[y"["B"], "]")), expression(paste("Var[y"["B"], "]")), ci.var.b.df, c(.2,1.25))
plot.cis(0.6, out.var.c.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Var[y"["C"], "]")), expression(paste("Var[y"["C"], "]")), ci.var.c.df, c(.2,1.25))
plot.cis(exp.cor.ab, out.cor.ab.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Cor[y"["A"], ", y"["B"], "]")), expression(paste("Cor[y"["A"], ", y"["B"], "]")), ci.cor.ab.df, c(0.6,1.0))
plot.cis(exp.cor.ac, out.cor.ac.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Cor[y"["A"], ", y"["C"], "]")), expression(paste("Cor[y"["A"], ", y"["C"], "]")), ci.cor.ac.df, c(-.6,.5))
plot.cis(exp.cor.bc, out.cor.bc.idx, expression(paste("CI"["95"], "\\hspace{1.5pt}of Cor[y"["B"], ", y"["C"], "]")), expression(paste("Cor[y"["B"], ", y"["C"], "]")), ci.cor.bc.df, c(-.6,.5))
dev.off()
