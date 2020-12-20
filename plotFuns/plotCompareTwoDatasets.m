function Figures = plotCompareTwoDatasets(RealDSet, SimDSet, Settings)
% Makes plots comparing two datasets, typically a real dataset (RealDSet), and
% one simulated using a model fitted to the data (SimDSet).

% INPUT
% Settings: Structure with fields, 'ModelPlotType', 'DataPlotType', 'NumBins'

modelPlotType = Settings.ModelPlotType;
dataPlotType = Settings.DataPlotType;
numBins = Settings.NumBins;


%% Plotting: All summary stats with all data combined
plotFig = figure;

plotFig = plotAllSumStatsAllData(RealDSet, plotFig, dataPlotType);
plotFig = plotAllSumStatsAllData(SimDSet, plotFig, modelPlotType);
Figures.AllSumStatsAllData = plotFig;


%% Plotting: Effect of mean and variance interaction
plotFig = figure;

[~, plotFig] = plotEffectOfMeanVarInt(RealDSet, plotFig, dataPlotType);
[~, plotFig] = plotEffectOfMeanVarInt(SimDSet, plotFig, modelPlotType);
Figures.EffectOfMeanVarInt = plotFig;


%% Plotting: Distractor statistics and hit/FA rate different format

plotNames = {'Uniform distractors', 'Concentrated distractors'};
shortNames = {'Uniform', 'Conc'};
relBlockType = [1 2];

for iPlt = 1 : length(plotNames)
    plotFig = figure('Name', plotNames{iPlt});
     
    % Specify plot variables
    XVars(1).ProduceVar = @(st) st.DistractorMean;
    XVars(1).NumBins = numBins;
    XVars(1).FindIncludedTrials = @(st) true(size(st.DistractorMean));
    
    XVars(2).ProduceVar = @(st) st.DistractorVar;
    XVars(2).NumBins = numBins;
    XVars(2).FindIncludedTrials = @(st) ~((st.SetSize==2) & (st.Target==1)); 
    % Exclude trials for which there is only 2 items and the target is present, 
    % because the variance of 1 distractor doesn't make sense
    
    XVars(3).ProduceVar = @(st) st.MostSimilarDistr;
    XVars(3).NumBins = numBins;
    XVars(3).FindIncludedTrials = @(st) true(size(st.DistractorMean));
    

    probPresentReport = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
    
    YVars(1).ProduceVar = probPresentReport;
    YVars(1).FindIncludedTrials = @(st) (st.SetSize==2);
    
    YVars(2).ProduceVar = probPresentReport;
    YVars(2).FindIncludedTrials = @(st) (st.SetSize==3);
    
    YVars(3).ProduceVar = probPresentReport;
    YVars(3).FindIncludedTrials = @(st) (st.SetSize==4);
    
    YVars(4).ProduceVar = probPresentReport;
    YVars(4).FindIncludedTrials = @(st) (st.SetSize==6);
    
    
    Series(1).FindIncludedTrials = ...
        @(st) (st.BlockType==relBlockType(iPlt)) & (st.Target==1);
    Series(2).FindIncludedTrials = ...
        @(st) (st.BlockType==relBlockType(iPlt)) & (st.Target==0);
    
    
    % Populate PlotStyle
    PlotStyle.General = 'paper';
    
    PlotStyle.Xaxis(1).Title = 'T-D mean (deg)';
    PlotStyle.Xaxis(1).Ticks = ...
        [0, pi/8, pi/4, 3*pi/8, pi/2, 5*pi/8, 3*pi/4, 7*pi/8, pi];
    PlotStyle.Xaxis(1).TickLabels = ...
        {'0', ' ', ' ', ' ', '45', ' ', ' ', ' ', '90'};
    
    PlotStyle.Xaxis(2).Title = 'D variance';
    PlotStyle.Xaxis(2).Ticks = [-0.05, linspace(0, 1, 11)];
    PlotStyle.Xaxis(2).TickLabels = string(PlotStyle.Xaxis(2).Ticks);
    PlotStyle.Xaxis(2).InvisibleTickLablels = setdiff([1:12], [2, 7, 12]);
    
    PlotStyle.Xaxis(3).Title = 'Min T-D difference (deg)';
    PlotStyle.Xaxis(3).Ticks = PlotStyle.Xaxis(1).Ticks;
    PlotStyle.Xaxis(3).TickLabels = PlotStyle.Xaxis(1).TickLabels;
    
    yTicks = linspace(0, 1, 11);
    yNoLabelTicks = setdiff(1:11, [1, 6, 11]);
    
    firstLabel = {'Probability', '''present'' report'};
    
    PlotStyle.Yaxis(1).Title = {'{\bf 2 items}', firstLabel{:}};
    PlotStyle.Yaxis(1).Ticks = yTicks;
    PlotStyle.Yaxis(1).InvisibleTickLablels = yNoLabelTicks;
    
    PlotStyle.Yaxis(2).Title = {'{\bf 3 items}', firstLabel{:}};
    PlotStyle.Yaxis(2).Ticks = yTicks;
    PlotStyle.Yaxis(2).InvisibleTickLablels = yNoLabelTicks;
    
    PlotStyle.Yaxis(3).Title = {'{\bf 4 items}', firstLabel{:}};
    PlotStyle.Yaxis(3).Ticks = yTicks;
    PlotStyle.Yaxis(3).InvisibleTickLablels = yNoLabelTicks;
    
    PlotStyle.Yaxis(4).Title = {'{\bf 6 items}', firstLabel{:}};
    PlotStyle.Yaxis(4).Ticks = yTicks;
    PlotStyle.Yaxis(4).InvisibleTickLablels = yNoLabelTicks;
    
    PlotStyle.Yaxis(1).RefVal = 0.5;
    PlotStyle.Yaxis(2).RefVal = 0.5;
    PlotStyle.Yaxis(3).RefVal = 0.5;
    PlotStyle.Yaxis(4).RefVal = 0.5;
    
    PlotStyle.Data(1).Colour = mT_pickColour(7);
    PlotStyle.Data(2).Colour = mT_pickColour(5);
        
    PlotStyle.Data(1).Name = 'Target present (hit rate)';
    PlotStyle.Data(2).Name = 'Target absent (FA rate)';
    
    for i = 1 : length(PlotStyle.Data)
        PlotStyle.Data(i).PlotType = dataPlotType;
    end
    
    plotFig = mT_plotVariableRelations(RealDSet, XVars, YVars, Series, ...
        PlotStyle, plotFig);
    
    
    PlotStyle.Annotate(1, 1).Text = 'A';
    PlotStyle.Annotate(1, 2).Text = 'B';
    PlotStyle.Annotate(1, 3).Text = 'C';
    PlotStyle.Annotate(2, 1).Text = 'D';
    PlotStyle.Annotate(2, 2).Text = 'E';
    PlotStyle.Annotate(2, 3).Text = 'F';
    PlotStyle.Annotate(3, 1).Text = 'G';
    PlotStyle.Annotate(3, 2).Text = 'H';
    PlotStyle.Annotate(3, 3).Text = 'I';
    PlotStyle.Annotate(4, 1).Text = 'J';
    PlotStyle.Annotate(4, 2).Text = 'K';
    PlotStyle.Annotate(4, 3).Text = 'L';
    
    for i = 1 : length(PlotStyle.Data)
        PlotStyle.Data(i).PlotType = modelPlotType;
    end
    
    plotFig = mT_plotVariableRelations(SimDSet, XVars, YVars, Series, ...
        PlotStyle, plotFig);
    
    
    clear XVars YVars Series PlotStyle
    
    Figures.DistractorStatsDifferentFormat.(shortNames{iPlt}) = plotFig;
end


%% Plotting: Distractor variance, set size 3, FA only
plotFig = figure;

% Specify plot variables
XVars(1).ProduceVar = @(st) st.DistractorVar;
XVars(1).NumBins = numBins;
XVars(1).FindIncludedTrials = @(st)true;

YVars(1).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(1).FindIncludedTrials = @(st) (st.SetSize==3) & (st.Target==0);

Series(1).FindIncludedTrials = @(st) st.BlockType==1;
Series(2).FindIncludedTrials = @(st) st.BlockType==2;


% Populate PlotStyle
PlotStyle.General = 'paper';

PlotStyle.Xaxis(1).Title = 'D variance';
PlotStyle.Xaxis(1).Ticks = [-0.05, linspace(0, 1, 11)];
PlotStyle.Xaxis(1).TickLabels = string(PlotStyle.Xaxis(1).Ticks);
PlotStyle.Xaxis(1).InvisibleTickLablels = setdiff([1:11], [2, 7, 12]);

PlotStyle.Yaxis(1).Title = {'{\bf 3 items}', 'FA rate'};
PlotStyle.Yaxis(1).Ticks = linspace(0, 1, 11);
PlotStyle.Yaxis(1).InvisibleTickLablels = setdiff(1:11, [1, 6, 11]);

PlotStyle.Yaxis(1).RefVal = 0.5;

PlotStyle.Data(1).Name = '{Uniform distractors}';
PlotStyle.Data(2).Name = '{Concentrated distractors}';
assert(all(unique(RealDSet.P(1).Data.KappaS( ...
    RealDSet.P(1).Data.BlockType==1))==0))
assert(all(unique(SimDSet.P(1).Data.KappaS( ...
    SimDSet.P(1).Data.BlockType==1))==0))

PlotStyle.Data(1).Colour = mT_pickColour(4);
PlotStyle.Data(2).Colour = mT_pickColour(2);


for i = 1 : length(PlotStyle.Data)
    PlotStyle.Data(i).PlotType = dataPlotType;
end

plotFig = mT_plotVariableRelations(RealDSet, XVars, YVars, Series, ...
    PlotStyle, plotFig);


for i = 1 : length(PlotStyle.Data)
    PlotStyle.Data(i).PlotType = modelPlotType;
end

plotFig = mT_plotVariableRelations(SimDSet, XVars, YVars, Series, ...
    PlotStyle, plotFig);


clear XVars YVars Series PlotStyle

Figures.DistractorVarSet3Only = plotFig;


%% Plotting: Overall performance
plotFig = figure;

% Specify plot variables
XVars(1).ProduceVar = @(st) st.SetSize;
XVars(1).NumBins = 'prebinned';

YVars(1).ProduceVar = @(st, inc) sum(st.Accuracy==1 & inc)/sum(inc);
YVars(1).FindIncludedTrials = @(st) true(size(st.DistractorMean));

YVars(2).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(2).FindIncludedTrials = @(st) st.Target == 1;

YVars(3).ProduceVar = @(st, inc) sum(st.Response==1 & inc)/sum(inc);
YVars(3).FindIncludedTrials = @(st) st.Target == 0;

Series(1).FindIncludedTrials = @(st) (st.BlockType==1);
Series(2).FindIncludedTrials = @(st) (st.BlockType==2);


% Populate PlotStyle
PlotStyle.General = 'paper';

PlotStyle.Xaxis(1).Title = {'Number of items'};
PlotStyle.Xaxis(1).Ticks = [2, 3, 4, 6];

PlotStyle.Yaxis(1).Title = 'Accuracy';
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

PlotStyle.Data(1).Name = '{Uniform distractors}';
PlotStyle.Data(2).Name = '{Concentrated distractors}';
assert(all(unique(RealDSet.P(1).Data.KappaS( ...
    RealDSet.P(1).Data.BlockType==1))==0))
assert(all(unique(SimDSet.P(1).Data.KappaS( ...
    SimDSet.P(1).Data.BlockType==1))==0))

PlotStyle.Data(1).Colour = mT_pickColour(4);
PlotStyle.Data(2).Colour = mT_pickColour(2);


for i = 1 : length(PlotStyle.Data)
    PlotStyle.Data(i).PlotType = dataPlotType;
end

plotFig = mT_plotVariableRelations(RealDSet, XVars, YVars, Series, ...
    PlotStyle, plotFig);


PlotStyle.Annotate(1, 1).Text = 'A';
PlotStyle.Annotate(2, 1).Text = 'B';
PlotStyle.Annotate(3, 1).Text = 'C';

for i = 1 : length(PlotStyle.Data)
    PlotStyle.Data(i).PlotType = modelPlotType;
end

plotFig = mT_plotVariableRelations(SimDSet, XVars, YVars, Series, ...
    PlotStyle, plotFig);


clear XVars YVars Series PlotStyle

Figures.EffectOfSetSize = plotFig;

