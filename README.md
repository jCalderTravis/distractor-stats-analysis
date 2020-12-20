# distractor-stats-analysis

This repository contains code for the analysis in the paper [_Explaining the effects of distractor statistics in visual search_](https://doi.org/10.1101/2020.01.03.893057). Most code is written for Matlab.

Contact: Joshua Calder-Travis, j.calder.travis@gmail.com

_Those sections of the code used in associated paper have been carefully checked. Nevertheless, no guarantee or warranty is provided for any part of the code._

## Main functions
- `runMultipleLogisicRegressions.m`: Code for running the logistic regressions reported in the paper
- `fitModels.m`: Code for running fits, or for packing all relevant information so that fits can be run on a computer cluster
- `mT_runOneJob.sh`: Code used for submitting jobs on a computer cluster
- `makePlotsForPaper.m`: Code used for making the plots in the paper 
- `attemptModelRecovery.m`: Code for simulating data with different models and then fitting the simulated datasets
- `runAllTests.m`: Code for running various code checks
- `runFullCollationPipeline.m`: Code used for collecting and managing data from the experiment

These functions rely on code in the various subfolders. Therefore, the subfolders need to be on the Matlab path.

## The DSet structure
Where a dataset is requested (`DSet`) it should be in the format described in the
README for the [modellingTools repositotry](https://github.com/jCalderTravis/mat-comp-model-tools).