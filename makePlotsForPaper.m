function makePlotsForPaper(Dirs, numPtpnts)
% Makes many of the plots in the paper 

% INPUT
% Dirs: (structure) contains fields 'Plots', 'Data', 'MainFit', and 'SecondFit'
% describing the directory to save plots in, the full filename of the data, and 
% the directories results from the two fitting runs were saved in. 
% numPtpnts: Number of participants expected. This value is used as a check.

addpath('./modellingTools')
addpath('./plotFuns')
addpath('./analysisFuns')

Loaded = load(Dirs.Data);
DSet = Loaded.DSet;
if length(DSet.P)~=numPtpnts; error('Unexpected number of participants'); end


%% Patterns in local log-likelihood

plotLocalLogLikeliWithMeas()
mT_exportNicePdf(14/3, 15.9/3, Dirs.Plots, 'patternsInLocalLL')


%% Plot stimulus distributions

plotStimuliDists;
mT_exportNicePdf(15.9/6, 15.9/2, Dirs.Plots, 'stimulusDensities')

plotDencity(DSet)
mT_exportNicePdf(14*(4/3), 15.9, Dirs.Plots, 'statisticDencities')


%% Data only, effect of distractor statistics

plotFig = plotAllSumStatsAllData(DSet);
plotAllSumStatsAllData(DSet, plotFig, 'line');
mT_exportNicePdf(14, 15.9, Dirs.Plots, 'allDataAllStats')

[~, plotFig] = plotEffectOfMeanVarInt(DSet);
plotEffectOfMeanVarInt(DSet, plotFig, 'line');
mT_exportNicePdf(14, (15.9/2.5), Dirs.Plots, 'meanVarInt')


%% Tables of parameter values

% Load and check data
AllDSets = mT_analyseClusterResults(Dirs.MainFit, 1, true, false, true);
close all
assert(length(AllDSets)==1)
DSet = AllDSets{1};
if length(DSet.P)~=numPtpnts; error('Unexpected number of participants'); end
% Check all models in the the same order accross participants
mT_findAppliedModels(DSet) 

produceParamTables(DSet, Dirs.Plots)


%% Model fit plots

for modelNum = [1, 3]
    
    Figures = compareDataAndModel(DSet, modelNum);
    
    fileNameLeaf = ['_', ...
        DSet.P(1).Models(modelNum).Settings.ModelName.Inference, 'Inference_', ...
        DSet.P(1).Models(modelNum).Settings.ModelName.BlockTypes, 'Blocks'];
    
    figure(Figures.AllSumStatsAllData)
    mT_exportNicePdf(14, 15.9, Dirs.Plots, ...
        ['allDataAllStats_withModelFits', fileNameLeaf])
    
    figure(Figures.EffectOfMeanVarInt)
    mT_exportNicePdf(14, (15.9/2.5), Dirs.Plots, ...
        ['meanVarInt_withModelFit', fileNameLeaf])
    
    figure(Figures.DistractorStatsDifferentFormat.Uniform)
    mT_exportNicePdf(14*(4/3), 15.9, Dirs.Plots, ...
        ['setSizesSeperately_uniform', fileNameLeaf])
    
    figure(Figures.DistractorStatsDifferentFormat.Conc)
    mT_exportNicePdf(14*(4/3), 15.9, Dirs.Plots, ...
        ['setSizesSeperately_conc', fileNameLeaf])
    
    figure(Figures.EffectOfSetSize)
    mT_exportNicePdf(14, (15.9/2.5), Dirs.Plots, ...
        ['effectOfSetSize', fileNameLeaf])
    
end

% Also make a plot of the effect, according to model 2, of distractor variance 
% on FA rate at set size 3, in the two different distractor environements 
modelNum = 2;
Figures = compareDataAndModel(DSet, modelNum);
figure(Figures.DistractorVarSet3Only)
fileNameLeaf = ['_', ...
        DSet.P(1).Models(modelNum).Settings.ModelName.Inference, 'Inference_', ...
        DSet.P(1).Models(modelNum).Settings.ModelName.BlockTypes, 'Blocks'];
mT_exportNicePdf(14*(1/3), 15.9*(1/3), Dirs.Plots, ...
    ['environmentEffect', fileNameLeaf])


%% Model comparison

[aicData, bicData] = mT_collectBicAndAicInfo(DSet);
mT_plotAicAndBic(aicData, bicData, [], 'Real data', false)
mT_exportNicePdf(14, 15.9, Dirs.Plots, 'modelComparison')

% Fit end points
[~, ~, numSuccessFig] = mT_plotFitEndPoints(DSet, false, 1);
figure(numSuccessFig)
mT_exportNicePdf(15.9/2, 15.9/2, Dirs.Plots, 'runFitSucesses_firstFit')


%% Second model fitting round

% Load and check data
AllDSets = mT_analyseClusterResults(Dirs.SecondFit, 1, true, false, true);
close all; 
assert(length(AllDSets)==1)
DSet = AllDSets{1};
if length(DSet.P)~=numPtpnts; error('Unexpected number of participants'); end
% Check all models in the the same order accross participants
mT_findAppliedModels(DSet) 


% Check the start point setup worked as expected, running from the end point of
% previous runs
nChecks = 20;
numModels = length(DSet.P(1).Models)/2;
ptpnts = randi(length(DSet.P), nChecks, 1);
models = randi(length(numModels), nChecks, 1);
fits = randi(length(DSet.P(1).Models(1).Fits), nChecks, 1);

for iC = 1 : nChecks
    if ~isequal(DSet.P(ptpnts(iC)).Models(models(iC)).Fits(fits(iC)).Params, ...
            DSet.P(ptpnts(iC)).Models(models(iC)+numModels ...
                ).Fits(fits(iC)).InitialVals)
        error('Bug'); 
    end
end

% Need to remove the models from the first round of fitting
for iP = 1 : length(DSet.P)
   DSet.P(iP).Models(1:numModels) = []; 
end

[aicData, bicData] = mT_collectBicAndAicInfo(DSet);
mT_plotAicAndBic(aicData, bicData, [], 'Real data', false)
mT_exportNicePdf(14, 15.9, Dirs.Plots, 'modelComparison_secondFittingRun')

% Fit end points
[~, ~, numSuccessFig] = mT_plotFitEndPoints(DSet, false, 1);
figure(numSuccessFig)
mT_exportNicePdf(15.9/2, 15.9/2, Dirs.Plots, 'runFitSucesses_secondFit')








