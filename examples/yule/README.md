This directory contains files to perform a well calibrated simulation study on a Yule prior with HKY, estimated frequencies, and gamma rate heterogeneity with a strict clock fixed at rate 1.

To run the study

* run `beast.truth.xml` to create trace and tree files `truth.log` and `truth.trees`
* run `createxml.sh` script to generate 100 BEAST files
* run `run.sh` to run the 100 BEAST file (may need adaption for operating systems other than OS X)

This generates a 
* coverage analysis
* clade coverage analysis
* RUV analysis
