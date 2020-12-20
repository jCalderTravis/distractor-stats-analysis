function Figures = compareDataAndModel(RealDSet, modelNum, varargin)
% Simulates data based on the real dataset, RealDSet, using model modelNum, and
% compares the results to the real data through a number of plots.

% INPUT
% varargin  If a participant number is supplied, only data from this participant
% will be analysed.

% OUTPUT
% Figures: Figure handles


if isempty(varargin)
    Settings.ModelPlotType = 'errorShading';
    Settings.DataPlotType = 'scatter';
    Settings.NumBins = 10;
    
else
    relPtpnt = varargin{1};
    
    % Trim DSet to relevant participant
    RealDSet.P = RealDSet.P(relPtpnt);
    
    % Change some settings to make them more suitable for analysing one
    % participant.
    Settings.ModelPlotType = 'line';
    Settings.DataPlotType = 'scatter';
    Settings.NumBins = 5;
end

%% Data prep

% Simulate data using the model
SimDSet = simulateDSetBasedOnReal(RealDSet, modelNum, ...
    struct('TrialsPerCond', 3000));

% Add summary stats to the data
for iPtpnt = 1 : length(RealDSet.P)  
    RealDSet.P(iPtpnt).Data ...
        = computeStimStats(RealDSet.P(iPtpnt).Data, 'circ', false);
end

for iPtpnt = 1 : length(SimDSet.P)  
    SimDSet.P(iPtpnt).Data ...
        = computeStimStats(SimDSet.P(iPtpnt).Data, 'circ', false);
end

Figures = plotCompareTwoDatasets(RealDSet, SimDSet, Settings);


