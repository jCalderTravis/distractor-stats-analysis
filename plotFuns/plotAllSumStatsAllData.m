function plotFig = plotAllSumStatsAllData(DSet, varargin)
% Plot the individual effects of the summary statistics, using all the data.

% INPUT
% varargin{1}: A figure handle to plot on to.
% varargin{2}: Plot type to use. Default is 'scatter'. Used for the function 
% mT_plotVariableRelations as the option for PlotStyle.Data.PlotType


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

% Add summary stats to real data
for iPtpnt = 1 : length(DSet.P)
    DSet.P(iPtpnt).Data ...
        = computeStimStats(DSet.P(iPtpnt).Data, 'circ', false);
end


% Specify plot variables
numBins = 10;

XVars(1).ProduceVar = @(st) st.DistractorMean;
XVars(1).NumBins = numBins;
XVars(1).FindIncludedTrials = @(st) ~(st.SetSize==2); 
% Exclude trials for which there is only 2 items, because the
% variance of 1 distractor doesn't make sense

XVars(2).ProduceVar = @(st) st.DistractorVar;
XVars(2).NumBins = numBins;
XVars(2).FindIncludedTrials = @(st) ~(st.SetSize==2);

XVars(3).ProduceVar = @(st) st.MostSimilarDistr;
XVars(3).NumBins = numBins;
XVars(3).FindIncludedTrials = @(st) ~(st.SetSize==2);


YVars(1).ProduceVar = @(st, inc) mean(st.Accuracy(inc) == 1);
YVars(1).FindIncludedTrials = @(st) true(size(st.DistractorMean));

YVars(2).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(2).FindIncludedTrials = @(st) (st.Target==1);

YVars(3).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(3).FindIncludedTrials = @(st) (st.Target==0);

Series(1).FindIncludedTrials = @(st) true(size(st.DistractorMean));

PlotStyle.General = 'paper';

if ~strcmp(plotType, 'errorShading')
    PlotStyle.Annotate(1, 1).Text = 'A';
    PlotStyle.Annotate(1, 2).Text = 'B';
    PlotStyle.Annotate(1, 3).Text = 'C';
    PlotStyle.Annotate(2, 1).Text = 'D';
    PlotStyle.Annotate(2, 2).Text = 'E';
    PlotStyle.Annotate(2, 3).Text = 'F';
    PlotStyle.Annotate(3, 1).Text = 'G';
    PlotStyle.Annotate(3, 2).Text = 'H';
    PlotStyle.Annotate(3, 3).Text = 'I';
end

PlotStyle.Xaxis(1).Title = 'T-D mean (deg)';
PlotStyle.Xaxis(1).Ticks = ...
    [-pi/16, 0, pi/8, pi/4, 3*pi/8, pi/2, 5*pi/8, 3*pi/4, 7*pi/8, pi];
PlotStyle.Xaxis(1).TickLabels = {' ', '0', ' ', ' ', ' ', '45', ' ', ' ', ' ', '90'};

PlotStyle.Xaxis(2).Title = 'D variance';
PlotStyle.Xaxis(2).Ticks = [-0.05, linspace(0, 1, 11)];
PlotStyle.Xaxis(2).TickLabels = string(PlotStyle.Xaxis(2).Ticks);
PlotStyle.Xaxis(2).InvisibleTickLablels = setdiff([1:12], [2, 7, 12]);

PlotStyle.Xaxis(3).Title = 'Min T-D difference (deg)';
PlotStyle.Xaxis(3).Ticks = PlotStyle.Xaxis(1).Ticks;
PlotStyle.Xaxis(3).TickLabels = PlotStyle.Xaxis(1).TickLabels;

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

PlotStyle.Data(1).Colour = [0, 0, 0];
PlotStyle.Data(1).PlotType = plotType;

  
plotFig = mT_plotVariableRelations(DSet, XVars, YVars, Series, PlotStyle, plotFig);
