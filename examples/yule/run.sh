#!/bin/zsh

cd xml
mkdir run1
cd run1

for i in  {0..24}; do beast -seed 127$i -overwrite ../analysis-out$i.xml > out$i 2>&1 ; done &
for i in {25..49}; do beast -seed 127$i -overwrite ../analysis-out$i.xml > out$i 2>&1 ; done &
for i in {50..74}; do beast -seed 127$i -overwrite ../analysis-out$i.xml > out$i 2>&1 ; done &
for i in {75..99}; do beast -seed 127$i -overwrite ../analysis-out$i.xml > out$i 2>&1 ; done &


echo "Waiting for beast runs to finish"
wait < <(jobs -p)

loganalyser -oneline *log > summary

applauncher beastvalidation.experimenter.CoverageCalculator -log ../../truth.log -logA summary -out /tmp -showRho true -showESS false -showMean false 

applauncher CladeCoverageCalculator -tru ../../truth.trees -pref analysis-out -png coverage$SL.png -bins 10
open coverage$SL.png



logcombiner -b 10 -log analysis-out?.log analysis-out??.log -o combined.log
applauncher SBCAnalyser -log ../../truth.log -logA combined.log -out /tmp -bins 10
