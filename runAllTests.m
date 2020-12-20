function runAllTests(fitDir)

% INPUT
% firDir: (string) directory containing the results from a fitting run. These
% results will be used in some tests.

addpath('./testFuns')
addpath('./analysisFuns')
addpath('./circstat-matlab')
addpath('./lautils-mat/stats')
addpath('./modellingTools')

% Load and check data
AllDSets = mT_analyseClusterResults(fitDir, 1, true, false, true);
close all; 
assert(length(AllDSets)==1)
DSet = AllDSets{1};
% Check all models in the the same order accross participants
mT_findAppliedModels(DSet) 


%% The tests

convertKappaToSigma('test');
vS_mapBackInRange('test');
testsOfCircStatFunsUsed()
testGiveResponseFun(DSet)
