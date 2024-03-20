library(ggplot2)
library(tikzDevice)
options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}", "\\usepackage[T1]{fontenc}", "\\usetikzlibrary{calc}", "\\usepackage{amssymb}"))

raw.pctgs <- c(0.04322949777495232, 0.13711151736745886, 0.2225609756097561, 0.36666666666666664, 0.4166666666666667, 0.5454545454545454, 0.6869565217391305, 0.7686567164179104, 0.8897058823529411, 0.9964046021093)

raw.pctgs <- c(0.027777777777777776, 0.07372400756143667, 0.12455516014234876, 0.15037593984962405, 0.2, 0.24539877300613497, 0.36363636363636365, 0.36936936936936937, 0.3978494623655914, 0.4367816091954023, 0.4931506849315068, 0.6101694915254238, 0.6666666666666666, 0.7142857142857143, 0.6933333333333334, 0.864406779661017, 0.8701298701298701, 0.9152542372881356, 0.9292035398230089, 0.9982754372998276)

x.vals <- seq(0, 0.95, .05)
x.labs <- seq(0, 95, 5)

df <- data.frame(cbind(x.vals, raw.pctgs))

p <- ggplot(data=df, aes(x=x.vals, y=raw.pctgs)) + geom_col(width=0.05, just=0, fill="skyblue") + geom_abline(intercept=0) + scale_x_continuous(breaks=x.vals, labels=as.character(x.labs), expand=c(0,0)) + scale_y_continuous(expand=c(0,0), limits=c(0,1.0)) + xlab("Posterior clade support") + ylab("Frequency of true clades") + theme_classic(base_size=14)
p

tikz("clade_coverage.tex", width=5, height=3, standAlone=TRUE, packages =
                                                                   c("\\usepackage{tikz}", "\\usepackage[active,tightpage,psfixbb]{preview}", "\\PreviewEnvironment{pgfpicture}", "\\setlength\\PreviewBorder{0pt}"))
p
dev.off()
