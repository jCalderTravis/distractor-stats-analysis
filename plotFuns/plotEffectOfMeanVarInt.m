function [DSet, plotFig] = plotEffectOfMeanVarInt(DSet, varargin)
% Plot acc, hit rate, and FA as a function variance, seperately for different
% means

% INPUT
% varargin{1}: A figure handle to a figure to plot on to.
% varargin{2}: Plot type to use. Default is 'scatter'.
% varargin{3}: If set to true plots 7 series instead of 3

% Deal with optional inputs
if isempty(varargin)
    plotFig = figure;
else
    plotFig = varargin{1};
end

if length(varargin) > 1
    plotType = varargin{2};
else
    plotType = 'scatter';
end

if (length(varargin) > 2) && varargin{3}
    numSeries = 7;
else
    numSeries = 3;
end

% Add summary stats to real data
for iPtpnt = 1 : length(DSet.P)
    DSet.P(iPtpnt).Data ...
        = computeStimStats(DSet.P(iPtpnt).Data, 'circ', false);
end

%% Binning 
% Split the data by distractor mean and variance
BinSettings.DataType = 'integer';
BinSettings.BreakTies = false;
BinSettings.Flip = false;
BinSettings.EnforceZeroPoint = false;
BinSettings.NumBins = numSeries;
BinSettings.SepBinning = false;

edges = NaN(length(DSet.P), BinSettings.NumBins+1);

for iP = 1 : length(DSet.P)
    distMean = DSet.P(iP).Data.DistractorMean;
    distVar = DSet.P(iP).Data.DistractorVar;
    blockType = DSet.P(iP).Data.BlockType;
    blockType(DSet.P(iP).Data.SetSize == 2) = NaN; % Use this to exclude trials
    
    [binnedDistMean, ~, ~, theseEdges] = mT_makeVarOrdinal(...
        BinSettings, distMean, blockType);
    [binnedDistVar, ~, ~] = mT_makeVarOrdinal(...
        BinSettings, distVar, blockType);
    
    edges(iP, :) = theseEdges{:};
    DSet.P(iP).Data.BinnedDistMean = binnedDistMean;
    DSet.P(iP).Data.BinnedDistVar = binnedDistVar;
    
    assert(mean(distMean(binnedDistMean==1)) < mean(distMean(binnedDistMean==2)))
    assert(mean(distMean(binnedDistMean==2)) < mean(distMean(binnedDistMean==3)))
    assert(all(all(distMean(binnedDistMean==1) < distMean(binnedDistMean==3)')))
end

disp('***********')
disp('Mean edges in radians in gabor-defined circular space:')
disp(mean(edges))
disp('***********')

disp('***********')
disp('Mean edges in physical degrees:')
disp(mean(edges)*(90/pi))
disp('***********')


%% Plotting
numBins = 10;

% Specify plot variables
XVars(1).ProduceVar = @(st) st.DistractorVar;
XVars(1).NumBins = numBins;
XVars(1).FindIncludedTrials = @(st) ~(st.SetSize==2); 
% Exclude trials for which there is only 2 items, because the
% variance of 1 distractor doesn't make sense

YVars(1).ProduceVar = @(st, inc) mean(st.Accuracy(inc) == 1);
YVars(1).FindIncludedTrials = @(st) true(size(st.DistractorMean));

YVars(2).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(2).FindIncludedTrials = @(st) (st.Target==1);

YVars(3).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(3).FindIncludedTrials = @(st) (st.Target==0);


Series(1).FindIncludedTrials = @(st) st.BinnedDistMean == 1;
Series(2).FindIncludedTrials = @(st) st.BinnedDistMean == 2;
Series(3).FindIncludedTrials = @(st) st.BinnedDistMean == 3;

if numSeries == 7
    Series(4).FindIncludedTrials = @(st) st.BinnedDistMean == 4;
    Series(5).FindIncludedTrials = @(st) st.BinnedDistMean == 5;
    Series(6).FindIncludedTrials = @(st) st.BinnedDistMean == 6;
    Series(7).FindIncludedTrials = @(st) st.BinnedDistMean == 7;
end

% Populate PlotStyle
PlotStyle.General = 'paper';

% If plot type is error shading don't do annotations as we are likely plotting
% onto a pre-existing plot
if ~strcmp(plotType, 'errorShading')
    PlotStyle.Annotate(1, 1).Text = 'A';
    PlotStyle.Annotate(2, 1).Text = 'B';
    PlotStyle.Annotate(3, 1).Text = 'C';
end

PlotStyle.Xaxis(1).Title = 'D variance';
PlotStyle.Xaxis(1).Ticks = [-0.05, linspace(0, 1, 11)];
PlotStyle.Xaxis(1).TickLabels = string(PlotStyle.Xaxis(1).Ticks);
PlotStyle.Xaxis(1).InvisibleTickLablels = setdiff([1:12], [2, 7, 12]);

PlotStyle.Yaxis(1).Title = {'Accuracy'};
PlotStyle.Yaxis(1).Ticks = linspace(0.4, 1, 7);
PlotStyle.Yaxis(1).TickLabels = string(PlotStyle.Yaxis(1).Ticks);
PlotStyle.Yaxis(1).InvisibleTickLablels = [2 : 2 : 7];
PlotStyle.Yaxis(1).RefVal = 0.5;

PlotStyle.Yaxis(2).Title = {'Hit rate'};
PlotStyle.Yaxis(2).Ticks = linspace(0.4, 1, 7);
PlotStyle.Yaxis(2).TickLabels = string(PlotStyle.Yaxis(2).Ticks);
PlotStyle.Yaxis(2).InvisibleTickLablels = [2 : 2 : 7];
PlotStyle.Yaxis(2).RefVal = 0.5;

PlotStyle.Yaxis(3).Title = {'FA rate'};
PlotStyle.Yaxis(3).Ticks = linspace(0, 1, 5);
PlotStyle.Yaxis(3).TickLabels = string(PlotStyle.Yaxis(3).Ticks);
PlotStyle.Yaxis(3).InvisibleTickLablels = [2 : 2 : 5];
PlotStyle.Yaxis(3).RefVal = 0.5;

PlotStyle.Legend.Title = 'T-D mean';

PlotStyle.Data(1).Name = 'small';
PlotStyle.Data(1).Colour = mT_pickColour(3);
PlotStyle.Data(1).PlotType = plotType;

PlotStyle.Data(2).Name = 'med';
PlotStyle.Data(2).Colour = mT_pickColour(1);
PlotStyle.Data(2).PlotType = plotType;

PlotStyle.Data(3).Name = 'large';
PlotStyle.Data(3).Colour = mT_pickColour(6);
PlotStyle.Data(3).PlotType = plotType;

if numSeries == 7
    PlotStyle.Data(4).Name = '-';
    PlotStyle.Data(4).Colour = mT_pickColour(2);
    PlotStyle.Data(4).PlotType = plotType;
    
    PlotStyle.Data(5).Name = '-';
    PlotStyle.Data(5).Colour = mT_pickColour(4);
    PlotStyle.Data(5).PlotType = plotType;
    
    PlotStyle.Data(6).Name = '-';
    PlotStyle.Data(6).Colour = mT_pickColour(5);
    PlotStyle.Data(6).PlotType = plotType;
    
    PlotStyle.Data(7).Name = '-';
    PlotStyle.Data(7).Colour = mT_pickColour(3);
    PlotStyle.Data(7).PlotType = plotType;
end


plotFig = mT_plotVariableRelations(DSet, XVars, YVars, Series, ...
    PlotStyle, plotFig);


