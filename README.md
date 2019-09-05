# Some guidance for developing new methods in BEAST 2

New methods require usually require two parts: an implementation of a model, and MCMC operators for creating proposals for moving through state space (though sometimes just an operator is validated that is much more efficient than previously existing operators). This guide contains some procedures to make sure that the model and operators are correctly implemented. Ideally, we have an independent implementation of a simulator that allows (possibly inefficiently) to sample from the target distribution. If so, we also need to verify that the simulator is correctly implemented. In summary, we need to establish correctness of:

* the simulator implementation (if any)
* the  model implementation
* operator implementations


### Verify correctness of simulator implementation
* simulator implementation -- distributions matches expected distribution (based on theory)

### Verify correctness of model implementation

* model -- inferred distributions matches simulator distribution

### Verify correctness of operator implementations

* operators -- distributions matches simulator distribution

	
Validation only covers cases in as far as the prior covers it -- no study will cover all possible cases. Usually, informative priors are required for validation to work, since broader priors (e.g. some of the default tree priors in BEAST) are not realistic. For instance, given we could create an alignment to analyse, the mutation rate \mu must have been such that the tree height cannot exceed 1/\mu, otherwise there would be saturation, and sequences could not possibly have sufficient information to align.



# Comparing two distributions

Kolmogorov-Smirnov test -- see TraceKSStats in Experimenter package.

# Verify model/operator correctness

BEAST 2 Experimenter package can assist https://github.com/rbouckaert/Experimenter

To run a simulation study:

* set up XML for desired model and sample from prior
* generate (MCMC) analysis for each of the samples (say 100)
* run the BEAST analyses
* use loganalyser to summarise trace files
* run CoverageCalculator to summarise coverage of parameters

Should cover parameters in prior 95% of the time


# Practical tricks of the trade

## Height of trees

* for reasonable computation times, trees should be about 0.5 substitutions high, OR
* sequences should be very long to reliably reconstruct smaller trees
* trees over 1 substitutions are saturated, cannot be reconstructed reliably

One way to enforce this is by 

* a narrow prior on birth rates, or
* putting an MRCA prior on the height of the tree, for coalescent models (this hampers simulator implementations though).

For clock models with mean clock rate != 1, simulate trees with clock rates times tree height approximately 0.5.

For releases, tree priors should be made less informative.

## Setting priors

Priors ideally should be set in realistic ranges, e.g. frequency priors not uniform(0,1) but Dirichlet(4,4,4,4)

## Sequence simulator

`SequenceSimulator` can help generate individual alignments.

To generate N XML files, use `CoverageTestXMLGenerator` in Experimenter package

The sequence length should be long enough that trees can be reasonably reliably recovered -- if the difference between longest and shorted tree is 2 orders of magnitude, nucleotide sequences of 10 thousand sites. When \mu*treeh-height approximate 0.5, sequences of length 1000 are sufficient.

## Log file names

Make sure log files names do not overlap.
Use `logFileName="out$(N).log` and start BEAST with 
`for i in {0..99} do /path/to/beast/bin/beast -D N=$i beast$i.xml; done`



# Trouble shooting

## Coverage gone wrong

One reason coverage can be lower is if the ESSs are too small, which can be easily checked by looking at the minimum ESS for the log entry. If these values are much below 200 the chain length should be increased to be sure any low coverage is not due to insufficient convergence of the MCMC chain. 

## Low coverage

The occasional 91 is acceptable (the 95% HPD = 90 to 98 probability the implementation is correct) but coverage below 90 almost surely indicate an issue with the model or operator implementation. Also, coverage of 99 or 100 should be looked at with suspicion -- it may indicate overly wide uncertainty intervals.

If correct, distributed binomial with p=0.95, N=100:

|k	|	p(x=k)	|	p(x<=k)	|	p(x>=k)|
|---:|-----------|-----------|----------|
| 90	|	0.0167	|	0.0282	|	0.9718|
| 91	|	0.0349	|	0.0631	|	0.9369|
| 92	|	0.0649	|	0.1280	|	0.8720|
| 93	|	0.1060	|	0.2340	|	0.7660|
| 94	|	0.1500	|	0.3840	|	0.6160|
| 95	|	0.1800	|	0.5640	|	0.4360|
| 96	|	0.1781	|	0.7422	|	0.2578|
| 97	|	0.1396	|	0.8817	|	0.1183|
| 98	|	0.0812	|	0.9629	|	0.0371|
| 99	|	0.0312	|	0.9941	|	0.0059|
|100	|	0.0059	|	1.0000	|	0.0000|

source [https://www.di-mgt.com.au/binomial-calculator.html](https://www.di-mgt.com.au/binomial-calculator.html) for different values of p and N.

## Common causes of low coverage

* trees cannot be reconstructed reliably (height should not be too small or large).
* Hastings ratio in operators incorrectly implemented
* bug in model likelihood

# Releasing

## Setting priors in BEAUti template

* Priors should be made as uninformative as possible -- people will use defaults!
* Make sure to consider a number of scenarios, e.g. for clock models, scenarios from [setting up rates](http://www.beast2.org/2015/06/23/help-beast-acts-weird-or-how-to-set-up-rates.html) page on [beast2.org](http://beast2.org).












# Using the Experimenter package

Experimenter is a [BEAST 2](http://beast2.org) package that assists in simulation studies to verify correctness of the implementation. The goal of this particular simulation studies is to make sure that the model or operator implementation is correct by running N analysis on simulated data (using SequenceSimulator) on a tree and site model parameters sampled from a prior.

To run a simulation study:

* set up XML for desired model and sample from prior
* generate (MCMC) analysis for each of the samples (say 100)
* run the analyses
* use loganalyser to summarise trace files
* run CoverageCalculator to summarise coverage of parameters


![Summary of files involved in testing an operator](figures/operatorTest.png)

Make sure to have the [Experimenter](https://github.com/rbouckaert/Experimenter) package installed (details at the end).

## 1. Set up XML for desired model and sample from prior

First, you set up a BEAST analysis in an XML file in the configuration that you want to test. Set the `sampleFromPrior="true"` flag on the element with MCMC in it, and sample from the prior. Make sure that the number of samples in the trace log and tree log is the same and that they are sampled at a frequency such that there will be N useful samples (say N=100).

## 2. Generate (MCMC) analysis for each of the samples 

You can use CoverageTestXMLGenerator to generate BEAST XML files from a template XML file. The XML file used to sample from the prior can be used for this (when setting the sampleFromPrior flag to false). You can run CoverageTestXMLGenerator using the BEAST applauncher utility (or via the `File/Launch Apps` meny in BEAUti).


CoverageTestXMLGenerator generates XML for performing coverage test (using CoverageCalculator) and has the following arguments:

-workingDir <filename>	working directory where input files live and output directory is created
-outDir <string>	output directory where generated XML goes (as sub dir of working dir) (default: mcmc)
-logFile 	trace log file containing model paramter values to use for generating sequence data
-treeFile 	tree log file containing trees to generate sequence data on
-xmlFile 	XML template file containing analysis to be merged with generated sequence data
-skip <integer>	numer of log file lines to skip (default: 1)
-burnin <integer>	percentage of trees to used as burn-in (and will be ignored) (default: 1)
-useGamma [true|false]	use gamma rate heterogeneity (default: true)
-help	 show arguments


```
NB: make sure to set sampleFromPrior="false" in the XML.
```

```
NB: to ensure unique file name, add a parameter to logFileName, e.g.
logFileName="out$(N).log"
```
With this setting, when you run BEAST with `-D N=1` the log file will `be out1.log`.


## 3. Run the analyses

Use your favourite method to run the N analyses, for example with a shell script

```
for i in {0..99} do /path/to/beast/bin/beast -D N=$i beast$i.xml; done

```

where `/path/to/beast` the path to where BEAST is installed.

## 4. Use loganalyser to summarise trace files

Use the loganalyser utility that comes with BEAST in the bin directory. It is important to use the `-oneline` argument so that each log line gets summarised on a single line, which is what `CoverageCalculator` expects. Also, it is important that the log lines are in the same order as the log lines in the sample from the prior, so put the results for single digits before those of double digits, e.g. like so:

```
/path/to/beast/bin/loganalyser -oneline out?.log out??.log > results
```

where `out` the base name of your output log file.

## 5. Run `CoverageCalculator` to summarise coverage of parameters

You can run CoverageCalculator using the BEAST applauncher utility (or via the `File/Launch Apps` meny in BEAUti).

CoverageCalculator calculates how many times entries in log file are covered in an estimated 95% HPD interval and has the following arguments:

- log <filename>	log file containing actual values
- skip <integer>	numer of log file lines to skip (default: 1)
- logAnalyser <filename>	file produced by loganalyser tool using the -oneline option, containing estimated values
- out 	output file for trace log with truth and mean estimates. Not produced if not specified
- help	 show arguments

It produces a report like so:

```
                                                coverage Mean ESS Min ESS
posterior                                       0	   2188.41  1363.02
likelihood                                      0	   4333.99  3042.15
prior                                           33	   1613.20  891.92
treeLikelihood.dna                              0	   4333.99  3042.15
TreeHeight                                      95	   3076.44  2233.29
popSize                                         94	   577.20  331.78
CoalescentConstant                              91	   1620.76  787.30
logP(mrca(root))                                97	   4320.70  3328.88
mrca.age(root)                                  95	   3076.44  2233.29
clockRate                                       0	   3046.64  2174.60
freqParameter.1                                 98	   4332.76  3388.90
freqParameter.2                                 97	   4337.93  3334.29
freqParameter.3                                 96	   4378.30  3462.73
freqParameter.4                                 92	   4348.83  3316.36
```

Coverage should be around 95%. One reason coverage can be lower is if the ESSs are too small, which can be easily checked by looking at the `Mean ESS` and `Min ESS` columns. If these values are much below 200 the chain length should be increased to be sure any low coverage is not due to insufficient convergence of the MCMC chain. The occasional 90 or 91 is acceptable but coverage below 90 almost surely indicate an issue with the model or operator implementation.

The values for posterior, prior and treelikelihood can be ignored: it compares results from sampling from the prior with that of sampling from the posterior so they can be expected to be different.


## Installing Experimenter package

Currently, you need to build from source (which depends on [BEAST 2](https://github.com/CompEvol/beast2) and [BEASTlabs](https://github.com/BEAST2-Dev/BEASTLabs/) code) and install by hand (see "install by hand" section in [managing packages](http://www.beast2.org/managing-packages/).

Quick guide

* clone [BEAST 2](https://github.com/CompEvol/beast2), [BEASTlabs](https://github.com/BEAST2-Dev/BEASTLabs/) and [Experimenter](https://github.com/rbouckaert/Experimenter/) all in same directory.
* build BEAST 2 (using `ant Linux` in the beast2 folder), then BEASTLabs (using `ant addon` in the BEASTLabs folder), then 
Experimenter (again, using `ant addon` in the Experimenter folder) packages.
* install BEASTlabs (using the [package manager](www.beast2.org/managing-packages/#Server_machines), or via BEAUti's `File/Manage pacakges` menu).
* install Experimenter package by creating `Experimenter` folder in your [BEAST package folder](http://www.beast2.org/managing-packages/#Installation_directories), and unzip the file `Experimenter/build/dist/Experimenter.addon.v0.0.1.zip` (assuming version 0.0.1).

