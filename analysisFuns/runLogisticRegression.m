function Betas = runLogisticRegression(DSet, predSet, excldueNoVar)
% Run logistic regression analysis on the visual search data

% INPUT
% predSet: Predictor set to use. Cell array of fieldnames from the following
% list: 'DistMean', 'DistVar', 'MeanVarInt', 'MostSim', 'BlockType', 'SetSize'
% excludeNoVar: true or false. Whether to exclude trials with 2 items, because there is no sensible
% measure of variance on trials with a target.

if length(excldueNoVar) ~= 1; error('Bug'); end
allowedPreds = {'DistMean', 'DistVar', 'MeanVarInt', 'MostSim', ...
    'BlockType', 'SetSize'};
for iPred = 1 : length(predSet)
    assert(ismember(predSet{iPred}, allowedPreds))
end


% Add summary stats to the data
for iP = 1 : length(DSet.P)
    DSet.P(iP).Data = computeStimStats(DSet.P(iP).Data, 'circ', false);
end

% Specify the outcome variables
outcomeName = {'Accuracy', 'Hit_rate', 'FA_rate'};
includedTrials = {@(Preds) true(size(Preds.Resp)), ...
    @(Preds) Preds.Target == 1, ...
    @(Preds) Preds.Target == 0};
outcomeVar = {(@(Preds) Preds.Acc +1), ...
    (@(Preds) Preds.Resp +1), ...
    (@(Preds) Preds.Resp +1)};


disp('****************************************************')
disp('****************************************************')
disp(predSet)
disp('-------------------------------------------------- ')

for iOutcome = 1 : length(outcomeName)
    
    disp(' ')
    disp(outcomeName{iOutcome})
    disp(' ')
    
    betas = NaN(length(predSet)+1, length(DSet.P));
    for iP = 1 : length(DSet.P)
        
        % Define the possible predictors (main effects)
        Preds.DistMean = DSet.P(iP).Data.DistractorMean;
        Preds.DistVar = DSet.P(iP).Data.DistractorVar;
        Preds.MostSim = DSet.P(iP).Data.MostSimilarDistr;
        Preds.BlockType = DSet.P(iP).Data.BlockType;
        Preds.SetSize = DSet.P(iP).Data.SetSize;
        
        % We need to center all main effect predictors, so the corresponding
        % beta is inperpretable. Let's also z-score so that effect sizes 
        % in the t-test (on betas) below are definitely comparable
        fields = fieldnames(Preds);
        
        for iField = 1 : length(fields)
            Preds.(fields{iField}) = zscore(Preds.(fields{iField}));
        end
        
        assert(round(mean(Preds.DistMean), 8)==0)
        assert(round(mean(Preds.BlockType), 8)==0)
        assert(round(mean(Preds.SetSize), 8)==0)
        
        % Define the outcome variables, and data selecction variables.
        % These will go in the Preds structure but will not be centered.
        Preds.Acc = DSet.P(iP).Data.Accuracy;
        Preds.Resp = DSet.P(iP).Data.Response;
        Preds.Target = DSet.P(iP).Data.Target;
        
        assert(all((Preds.Target==0)|(Preds.Target==1)|isnan(Preds.Target)))
        
        % Define more predictors (interactions)
        Preds.MeanVarInt = Preds.DistMean.*Preds.DistVar;
        
        
        % Find the predictor and outcome values, for this comparison
        incTrials = includedTrials{iOutcome}(Preds);
        
        if excldueNoVar
            toExc = DSet.P(iP).Data.SetSize==2;
            incTrials = incTrials & (~toExc);
        end
        
        assert(~any(DSet.P(iP).Data.DistractorVar(incTrials) == 0))
        
        outcomeValues = outcomeVar{iOutcome}(Preds);
        outcomeValues = outcomeValues(incTrials);
        
        predVals = NaN(length(Preds.Resp(incTrials)), length(predSet));
        
        for iPred = 1 : length(predSet)
            predVals(:, iPred) = Preds.(predSet{iPred})(incTrials);
        end
        
        % Run the regression
        theseBetas = mnrfit(predVals, outcomeValues);
        
        % Multiply by -1 because of the conventions used by mnrfit.
        betas(:, iP) = -theseBetas;
    end
    
    % Store results.
    Betas.(outcomeName{iOutcome}) = betas;
    
    % Analyse the betas for each predictor in turn
    df = NaN(length(predSet), 1);
    t_value = NaN(length(predSet), 1);
    p_value = NaN(length(predSet), 1);
    Effect_d = NaN(length(predSet), 1);
    
    for iPred = 1 : length(predSet)
        [~, p_value(iPred), ~, stats] = ttest(betas(iPred+1, :));
        
        df(iPred) = stats.df;
        t_value(iPred) = stats.tstat;
        Effect_d(iPred) = mean(betas(iPred+1, :)) / stats.sd;
    end
    
    % Display Bonforroni corrected H_0 rejection threshold
    criterionValue = 0.05 / length(p_value);
    
    disp(['*** Criterion value: ' num2str(criterionValue) ' ***'])
    disp(' ')
    
    d = {'&'};
    d = repmat(d, length(p_value), 1);
    
    t_value = round(t_value, 2, 'significant');
    Effect_d = round(Effect_d, 2, 'significant');
    p_value = round(p_value, 2, 'significant');
    
    disp(table(d, predSet, d, df, d, t_value, d, ...
        Effect_d, d, p_value))
    
    disp(' ')
end
