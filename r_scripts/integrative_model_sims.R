
suppressMessages(library(TreeSim))
suppressMessages(library(mvMORPH))

n.sim <- 100 # only hardcoded bit

args <- commandArgs(trailingOnly=TRUE)
## example.args <- c("yule_bm", "-3.25,0.2,-2.5,0.5", "-3.25,0.2,-2.5,0.5", "match")

## add command line arg parsing here
if (length(args) != 4) stop("You need to provide (1) a string prefix for file names, (2) log-mean, log-stdev for two LN distributions (Yule and PhyloBM), (3) Same as (2), but for a misspecified model, (4) a string with \'match\' or \'mismatch\' indicating whether (3) is to be used or not", call.=FALSE)

job.prefix <- args[1]
ln.params <- as.numeric(strsplit(args[2], ",")[[1]])
ln.params2 <- as.numeric(strsplit(args[3], ",")[[1]])
model.match <- args[4]

## printing on screen
if (model.match == "match") {
    cat("\nModels are correctly specified!\n")
    cat(paste("\nLN parameters for Yule simulation:", paste0(ln.params[1], ","), ln.params[2], "\n"))
    cat(paste("LN parameters for PhyloBM simulation:", paste0(ln.params[3], ","), ln.params[4], "\n"))
} else if (model.match == "mismatch") {
    cat("\nModels are incorrectly specified on purpose!\n")
    cat(paste("LN parameters for Yule inference:", paste0(ln.params2[1], ","), ln.params2[2], "\n"))
    cat(paste("LN parameters for PhyloBM inference:", paste0(ln.params2[3], ","), ln.params2[4], "\n"))
} else {
    exit("\nargs[4] must be \'match\' or \'mismatch\'\n")
}

## pre-requisites
jar.path <- "./contraband.v0.0.1.jar"
template.path <- "./integrative_model_template.xml"
if (!file.exists(jar.path)) stop(paste("Could not find", jar.path))
if (!file.exists(template.path)) stop(paste("Could not find", template.path))

## sorting out directories for validation
val.path <- "./validation_files/"
xmls.path <- paste0(val.path, job.prefix, "_xmls/")
res.path <- paste0(val.path, job.prefix, "_res/")
if (dir.exists(val.path)) {
    cat("\nDirectory validation_files/ exists within r_scripts/. Overwriting what is inside...\n")
} else {
    dir.create(val.path, showWarnings=FALSE)
    cat("\nCreated validation_files/ and subdirectories within\n")
}
dir.create(xmls.path, showWarnings=FALSE)
dir.create(res.path, showWarnings=FALSE)

###### simulations ######

cat("Simulating Yule trees and continuous characters.\n")

age <- 100
min.sp.count <- 40
max.sp.count <- 200
lambdas <- rep(0.0, n.sim)
trs <- vector("list", n.sim)
trs.heights <- rep(0.0, n.sim)
trs.ntips <- rep(0, n.sim)
taxon.strs.4.template <- vector("list", n.sim)

## Yule simulations
success <- 1
failed <- 0
no.tree <- 0
set.seed(666)
while (success <= n.sim) {
    this.lambda = rlnorm(1, mean=ln.params[1], sd=ln.params[2]) # -3.25, .2 for normal Yule
    this.tr = sim.bd.age(age, 1, this.lambda, 0.0, complete=TRUE)[[1]]

    ## if sim fails, this check returns false
    if (!(class(this.tr) == "numeric")) {
        this.n.tips = length(this.tr$tip.label)
        this.height = max(node.depth.edgelength(this.tr))

        if (this.n.tips >= min.sp.count && this.n.tips <= max.sp.count) {
            lambdas[success] = this.lambda
            trs[[success]] = this.tr
            trs.ntips[success] = this.n.tips
            trs.heights[success] = this.height # this + the root edge should add to 'age'
            taxon.strs.4.template[[success]] = paste(paste0("<taxon id=\"", this.tr$tip.label, "\" spec=\"Taxon\"/>"), collapse="\n")
            success = success + 1

            if (success %% 10 == 0) {
                cat(paste0(success, " trees simulated\n"))
            }
        } else { failed = failed + 1 }
    } else { no.tree = no.tree + 1 }
}
cat(paste0("A total of ", 100 + failed, " trees were simulated. There were ", failed, " outside the taxon count of interest.\n"))

## continuous-character simulations
rs <- rlnorm(100, mean=ln.params[3], sd=ln.params[4]) # -2.5, .5
conttrs <- vector("list", n.sim)
sps.names <- rep(NA, n.sim)
sps.trs <- rep(NA, n.sim)
for (i in 1:n.sim) {
    conttrs[[i]] = mvSIM(trs[[i]], nsim=1, model="BM1", param=list(ntraits=1, sigma=rs[i], theta=0.0))
    sps.names[i] = paste(row.names(conttrs[[i]]), collapse=" ")
    sps.trs[i] = paste(conttrs[[i]], collapse=" ")
}


###### writing xml files ######

cat("\nWriting .xml files.\n")
            
for (i in 1:n.sim) {
    xml.file.name = paste0(xmls.path, job.prefix, i, ".xml")

    if (file.exists(xml.file.name)) { file.remove(xml.file.name) }

    file.name = basename(gsub(".xml", "", xml.file.name))

    template.lines = readLines(template.path)
    
    for (line in template.lines) {
        ## line = gsub("\\[birthDiffRateMeanHere\\]", format(0.01, nsmall=1), line) # for exponential prior (normal and low-signal yule)

        ## bm likelihood
        line = gsub("\\[spNamesHere\\]", sps.names[i], line)
        line = gsub("\\[spTraitValuesHere\\]", sps.trs[i], line)

        ## priors
        ## yule
        if (model.match == "match") {           
            line = gsub("\\[birthDiffRateMeanHere\\]", format(ln.params[1], nsmall=1), line) # print at least 1 decimal place after .
            line = gsub("\\[birthDiffRateStdDevHere\\]", format(ln.params[2], nsmall=1), line)
        } else {
            line = gsub("\\[birthDiffRateMeanHere\\]", format(ln.params2[1], nsmall=1), line) # print at least 1 decimal place after .
            line = gsub("\\[birthDiffRateStdDevHere\\]", format(ln.params2[2], nsmall=1), line)
        }

        ## phyloBM
        line = gsub("\\[bmRateMeanHere\\]", format(ln.params[3], nsmall=1), line)
        line = gsub("\\[bmRateStdDevHere\\]", format(ln.params[4], nsmall=1), line)

        line = gsub("\\[TreeHere\\]", write.tree(trs[[i]]), line)
        line = gsub("\\[TaxonSetHere\\]", taxon.strs.4.template[[i]], line)
        line = gsub("\\[FileNameHere\\]", paste0(res.path, file.name), line)
        write(line, file=xml.file.name, append=TRUE)
    }

    if (i %% 10 == 0) cat(paste0(i, " .xml files written\n"))            
    ## see how this is done in Michael's server
    ## write.shell.script(shell.scripts.path, sim.idx, time.needed, job.prefix, jar.path, xml.cluster.path, xmlprefix)
}


###### writing true files and .RData ######

true.df <- as.data.frame(cbind((1:100), lambdas, rs, trs.heights, trs.ntips))
names(true.df) <- c("sim", "birthRate", "bmRate", "treeHeight", "nTips")

rdata.path <- paste0(val.path, "true_param_values.RData")
save(true.df, trs, file=rdata.path)

cat(paste0("\nSaved true parameter values into ", rdata.path, "\n"))
