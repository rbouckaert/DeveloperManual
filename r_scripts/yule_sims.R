library(TreeSim)

n.sim <- 100
age <- 100
## job.prefix <- "yule"
## job.prefix <- "wrongyule"
job.prefix <- "lowsignalyule"
time.needed <- "00:10:00"
jar.path <- "/nesi/project/nesi00390/fkmendes/contraband/calibrated_validation/contraband.jar"
template.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/yule_template.xml" # make sure to un/comment right prior block, and when writing .xml files below

## xmlfolder.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/yule_xmls/"
## xmlfolder.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/wrongyule_xmls/"
xmlfolder.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/lowsignalyule_xmls/"

## xmlprefix <- "yule"
## xmlprefix <- "wrongyule"
xmlprefix <- "lowsignalyule"

## shell.scripts.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/yule_shs/"
## xml.cluster.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/yule_xmls/"
## res.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/yule_res/"
## shell.scripts.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/wrongyule_shs/"
## xml.cluster.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/wrongyule_xmls/"
## res.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/wrongyule_res/"
shell.scripts.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/lowsignalyule_shs/"
xml.cluster.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/lowsignalyule_xmls/"
res.path <- "/nesi/project/nesi00390/fkmendes/method_validation_project/lowsignalyule_res/"

save.path <- "/Users/fkur465/Documents/uoa/method_validation_ms/scripts/"

set.seed(666)
lambda <- rexp(10000, rate=100)
lambdas <- rep(0.0, n.sim)
trs <- vector("list", n.sim)
trs.heights <- vector("list", n.sim)
taxon.strs.4.template <- vector("list", n.sim)

success <- 1
counter <- 1
while (success <= n.sim) {

    tr = sim.bd.age(age, 1, lambda[counter], 0.0, complete=TRUE)[[1]]

    if (!(class(tr) == "numeric")) {
        n.tips = length(tr$tip.label)

        # low-signal yule
        if (n.tips >=5 && n.tips <= 10) {

        # normal and wrong yule
        ## if (n.tips >= 50 && n.tips <= 200) {
            cat(paste0("i=", success), "\n")

            lambdas[success] = lambda[counter]
            trs[[success]] = tr
            taxon.strs.4.template[[success]] = paste(paste0("<taxon id=\"", trs[[success]]$tip.label, "\" spec=\"Taxon\"/>"), collapse="\n")
            success = success + 1
        }
    }

    counter = counter + 1
}

save(lambdas, trs, file=paste0(save.path, xmlprefix, ".RData"))

write.shell.script <- function(shell.scripts.path, sim.idx, time.needed, job.prefix, jar.path, xml.cluster.path, xml.file.prefix) {
    shell.file.name = paste0(shell.scripts.path, xml.file.prefix, sim.idx, ".sh")
    if (file.exists(shell.file.name)) {
        file.remove(shell.file.name)
    }

    xml.file.name = paste0(xml.cluster.path, xml.file.prefix, sim.idx, ".xml")

    write(file=shell.file.name, paste(
        paste0("#!/bin/bash -e\n#SBATCH -J ", job.prefix, sim.idx),
        "#SBATCH -A nesi00390",
        paste0("#SBATCH --time=", time.needed),
        "#SBATCH --mem-per-cpu=1G",
        "#SBATCH --cpus-per-task=1",
        "#SBATCH --ntasks=1",
        "#SBATCH --hint=nomultithread",
        "#SBATCH -D ./",
        paste0("#SBATCH -o ", job.prefix, sim.idx, "_out.txt"),
        paste0("#SBATCH -e ", job.prefix, sim.idx, "_err.txt"),
        paste0("\nsrun java -jar ", jar.path, " -seed 555 ", xml.file.name),
        sep="\n")
        )
}

cat("Writing .xml files.\n")
for (sim.idx in 1:n.sim) {
    xml.file.name = paste0(xmlprefix, sim.idx, ".xml")
    cat(paste0(xmlfolder.path, xml.file.name, "\n"))

    if (file.exists(paste0(xmlfolder.path, xml.file.name))) {
        file.remove(paste0(xmlfolder.path, xml.file.name))
    }

    file.name = basename(gsub(".xml", "", xml.file.name))

    template.lines = readLines(template.path)

    for (line in template.lines) {
        ## line = gsub("\\[birthDiffRateMeanHere\\]", format(0.01, nsmall=1), line) # for exponential prior (normal and low-signal yule)
        line = gsub("\\[birthDiffRateMeanHere\\]", format(0.1, nsmall=1), line) # for LN prior (wrong yule)
        line = gsub("\\[birthDiffRateStdDevHere\\]", format(0.5, nsmall=1), line) # for LN prior (wrong yule)
        line = gsub("\\[TreeHere\\]", write.tree(trs[[sim.idx]]), line)
        line = gsub("\\[TaxonSetHere\\]", taxon.strs.4.template[[sim.idx]], line)
        line = gsub("\\[FileNameHere\\]", paste0(res.path, file.name), line)
        write(line, file=paste0(xmlfolder.path, xml.file.name), append=TRUE)
    }

    write.shell.script(shell.scripts.path, sim.idx, time.needed, job.prefix, jar.path, xml.cluster.path, xmlprefix)
}
