function runMultipleLogisicRegressions(DSet, numPtpnts)
% Run various logistic regressions

% INPUT
% numPtpnts: Number of participants expected. This value is used as a check.

if length(DSet.P)~=numPtpnts; error('Unexpected number of participants'); end


% Different predictors sets for different regressions...
PredSet{1} = {'DistMean', 'DistVar', 'MeanVarInt'}';
PredSet{2} = {'DistMean', 'DistVar', 'MeanVarInt', 'MostSim', 'BlockType', ...
    'SetSize'}' ;
PredSet{3} = {'DistMean'};
PredSet{4} = {'DistVar'}';
PredSet{5} = {'MostSim'}';

% Specify whether to exclude trials with 2 items, because in this case there 
% is no sensible measure of variance on trials with a target. Each entry
% corresponds to one PredSet.
excldueNoVar = repmat({true}, length(PredSet), 1);

for iSet = 1 : length(PredSet)
    runLogisticRegression(DSet, PredSet{iSet}, excldueNoVar{iSet});
end