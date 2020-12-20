function plotDencity(DSet)
% Plot the probability dencities over the different distractor statistics, using
% the combined data from all participants. Function sperately plots data from 
% different experiment conditions.

% Add summary stats to real data
for iPtpnt = 1 : length(DSet.P)
    DSet.P(iPtpnt).Data ...
        = computeStimStats(DSet.P(iPtpnt).Data, 'circ', false);
end

% Concatinate all data
totalTrials = 0;

for iP = 1 : length(DSet.P)
    totalTrials = totalTrials + length(DSet.P(iP).Data.Response);
    ptpntData = struct2table(DSet.P(iP).Data);
    
    if iP == 1
        allData = ptpntData;
    else
        allData = [allData; ptpntData];
    end
end

DSet.P(2: end) = [];
DSet.P(1).Data = table2struct(allData, 'ToScalar', true);
assert(length(DSet.P(1).Data.Response) == totalTrials)


% Specify plot variables
numBins = 15;

XVars(1).ProduceVar = @(st) st.DistractorMean;
XVars(1).NumBins = numBins;

XVars(2).ProduceVar = @(st) st.DistractorVar;
XVars(2).NumBins = numBins;

XVars(3).ProduceVar = @(st) st.MostSimilarDistr;
XVars(3).NumBins = numBins;

Rows(1).FindIncludedTrials = @(st) (st.BlockType==1) & (st.Target==1);
Rows(2).FindIncludedTrials = @(st) (st.BlockType==1) & (st.Target==0);
Rows(3).FindIncludedTrials = @(st) (st.BlockType==2) & (st.Target==1);
Rows(4).FindIncludedTrials = @(st) (st.BlockType==2) & (st.Target==0);

Series(1).FindIncludedTrials = @(st) st.SetSize==2;
Series(2).FindIncludedTrials = @(st) st.SetSize==3;
Series(3).FindIncludedTrials = @(st) st.SetSize==4;
Series(4).FindIncludedTrials = @(st) st.SetSize==6;

PlotStyle.General = 'paper';
PlotStyle.Scale = 8;

PlotStyle.Xaxis(1).Title = 'T-D mean (deg)';
PlotStyle.Xaxis(1).Ticks = ...
    [0, pi/8, pi/4, 3*pi/8, pi/2, 5*pi/8, 3*pi/4, 7*pi/8, pi];
PlotStyle.Xaxis(1).TickLabels = {'0', ' ', '', ' ', '45', ' ', '', ' ', '90'};

PlotStyle.Xaxis(2).Title = 'D variance';
PlotStyle.Xaxis(2).Ticks = linspace(0, 1, 11);
PlotStyle.Xaxis(2).TickLabels = string(PlotStyle.Xaxis(2).Ticks);
PlotStyle.Xaxis(2).InvisibleTickLablels = setdiff(1:11, [1, 6, 11]);

PlotStyle.Xaxis(3).Title = 'Min T-D difference (deg)';
PlotStyle.Xaxis(3).Ticks = PlotStyle.Xaxis(1).Ticks;
PlotStyle.Xaxis(3).TickLabels = PlotStyle.Xaxis(1).TickLabels;

PlotStyle.Rows(1).Title = fliplr({'Probability', '{\bf Target present}', '{\bf Uniform distractors}'});
PlotStyle.Rows(2).Title = fliplr({'Probability', '{\bf Target absent}', '{\bf Uniform distractors}'});
PlotStyle.Rows(3).Title = fliplr({'Probability', '{\bf Target present}', '{\bf Concentrated distractors}'});
PlotStyle.Rows(4).Title = fliplr({'Probability', '{\bf Target absent}', '{\bf Concentrated distractors}'});

PlotStyle.Data(1).Name = '2 items';
PlotStyle.Data(1).Colour = [0.6, 0.6, 0.6];
PlotStyle.Data(1).LineStyle = '-';

PlotStyle.Data(2).Name = '3 items';
PlotStyle.Data(2).Colour = [0.4, 0.4, 0.4];
PlotStyle.Data(2).LineStyle = '--';

PlotStyle.Data(3).Name = '4 items';
PlotStyle.Data(3).Colour = [0.2, 0.2, 0.2];
PlotStyle.Data(3).LineStyle = '-.';

PlotStyle.Data(4).Name = '6 items';
PlotStyle.Data(4).Colour = [0, 0, 0];
PlotStyle.Data(4).LineStyle = ':';

figHandle = mT_plotDencities(DSet, XVars, Rows, Series, PlotStyle, 1);



