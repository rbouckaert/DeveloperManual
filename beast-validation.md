# The BEAST validation package

This package provides tools for validating models implemented in BEAST2. It implements *stochastic* integration-style tests (as opposed to a deterministic unit test).

## Package dependencies

* [MASTER](http://tgvaughan.github.io/MASTER/)
* [BEASTLabs](https://github.com/BEAST2-Dev/BEASTLabs)

## Writing a test

The BEAST validation package is designed around three core object types: it performs a *test* on *statistics* drawn from *samplers*.
BEAST validation tests are implemented within the BEAST 2 XML parser framework. The main Runnable class is [`beast.validation.StochasticValidationTest`](https://github.com/christiaanjs/beast-validation/blob/master/src/beast/validation/StochasticValidationTest.java). `StochasticValidationTest` has inputs for each of the core object types: `samplers`, `statistics` and a `test`. Note that some tests may be designed for one, two or many sampler/statistic pairs.

`StochasticValidationTest` has some additional parameters:
* `alpha`: The significant level to use in the test
* `nSamples`: The number of samples to draw from each sampler
* `printEvery`: How often to report sampling progress
* `sampleLoggers`: Loggers to run for every sample (usually the statistics)
* `resultLoggers`: Loggers to run after testing

There are currently two useful combinations of samplers, statistics and test implemented by BEAST validation.

### Score function validation

This test validates a combination of likelihood and direct simulator using a known property of probability density functions: that the expectation of the gradient of the log-likelihood at the true parameter values is zero (see [`stats-tricks.md`]). The core components of this test are (with a single sampler-statistic pair):

* a simulator: This could be a custom simulator, or make use of one of the generic simulation tools available, such as `beast.simulation.TreeSamplerFromMaster`
* `beast.validation.statistics.NumericalScoreFunctionStatistics`: a statistic that uses a finite differences to calculate the gradient of a likelihood with respect to some parameters 
    - Note that the `RealParameter` objects included in the `parameter` input should be the same provided to the `Distribution` in the `likelihood` input
* `beast.validation.tests.MultivariateNormalZeroMeanTest`: a likelihood ratio test that uses a multivariate normal fit to the gradients to test for zero mean

An important note is that there are some regularity conditions on the parameters you can use in this test. Roughly, they must not affect the support of the data, which excludes the origin time parameter in tree priors. See [`stats-tricks.md`] for further details.

[An example XML for this test on the birth-death-sampling tree prior](https://github.com/christiaanjs/beast-validation/blob/master/examples/birth-death-sampling-score-function-test.xml) can be found in the BEAST validation examples.

### MCMC sampling/simulation comparison

A useful test for an MCMC sampler for a model (likelihood + operators) is if it can produce the same distribution as direct simulation. For phylogenetic models, this would usually be the tree prior. The core components of this test:

* Two samplers
    - a simulator (see the previous test for details)
    - `beast.core.SamplerFromMCMC`
        - extends the normal BEAST MCMC class
        - needs a model/likelihood and operators
        - To test a single, potentially non-ergodic operator, a separate simulator could be used as a global operator with the `beast.simulation.OperatorFromSampler` class
* A multivariate statistic
    - `beast.validation.statistics.UltrametricTreeStatistics` provides some basic statistics on BEAST time trees 
    - For an example of statistics on more complex tree-like objects, see [`bacter.util.ConversionGraphStatsLogger`](https://github.com/tgvaughan/bacter/blob/master/src/bacter/util/ConversionGraphStatsLogger.java)
* `beast.validation.tests.BootstrapMultivariateDistributionTest`: a test that bootstraps a multivariate generalisation of the Kolmogorov-Smirnov (KS) statistic to compare distributions (see [`stats-tricks.md`] for further details)

[An example XML for this test on the birth-death-sampling tree prior](https://github.com/christiaanjs/beast-validation/blob/master/examples/birth-death-sampling-prior-sampling-test.xml) can be found in the BEAST validation examples.

## Running a test

Once you have created an XML and installed the BEAST validation package (pending inclusion in the package repository) using the standard BEAST 2 launcher. Once your test has run, it will provide the result on the console:
```
Performing test...
Test PASSED
p value: 0.284784
```
