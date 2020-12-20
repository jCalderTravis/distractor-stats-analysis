function attemptModelRecovery(recoveryType, mode, saveDir, varargin)

% INPUT
% recoveryType  Analyse each data set with only the true model, and simply
%               attempt to recover parameters, or analyse will all models,
%               fitting parameters and comparing models. Use 'params', and
%               'models' respectively.
% mode          Run on 'cluster' or 'local'.
% saveDir       Directory for saving simulated data and fits.
% varargin      (Optional). Provide a standard dataset that has been fitted.
%               Then the simulated data will be based on the fitted parameters.

addpath('./modellingTools')
addpath('./analysisFuns')
addpath('./circstat-matlab')
addpath('./lautils-mat/stats')

if isempty(varargin)
    templateDSet = false; 
else
    templateDSet = true;
    Template = varargin{1};
end


%% Simulate

if ~templateDSet
    % Simulate participants from each of the key models
    allModels = enumerateModels('key');
    AllDSets = cell(length(allModels), 1);
    
    GeneralSpec.NumPtpnt = 10;
    GeneralSpec.TrialsPerCond = 256;
    GeneralSpec.SetSizes = [2, 3, 4, 6];
    GeneralSpec.Kappa_s = [0, 1.5];
    GeneralSpec.StatType = 'circ';
    Spec = repmat(GeneralSpec, length(allModels), 1);
    
    for iSpec = 1 : length(allModels)    
        Spec(iSpec).Name = allModels{iSpec};
        
        for iP = 1 : GeneralSpec.NumPtpnt
            Spec(iSpec).Params(iP) = assignDefaultParamValues(allModels{iSpec});
        end
        
        AllDSets{iSpec} = produceStandardFormatDSet(Spec(iSpec));
    end
    
elseif templateDSet
    
    allModels = mT_findAppliedModels(Template);
    AllDSets = cell(length(allModels), 1);
    
    for iSpec = 1 : length(allModels)
        AllDSets{iSpec} = simulateDSetBasedOnReal(Template, iSpec, struct());
    end 
end


%% Model recovery attempts

% Look over all simulations
for iSpec = 1 : length(AllDSets)

    % Analyse the data using each model if requested
    if strcmp(recoveryType, 'models')
        models = allModels;
        trueModelNum= iSpec;
        
    elseif strcmp(recoveryType, 'params')
        models = allModels(iSpec);
        trueModelNum = 1;
    end
    
    % Check things are organised in the way we will probably assume later
    assert(isequal(models{trueModelNum}, AllDSets{iSpec}.SimSpec.Name));
    
    
    if strcmp(mode, 'cluster')
        AllDSets{iSpec} = fitModels(AllDSets{iSpec}, models, ...
            mode, saveDir, length(AllDSets{iSpec}.P));
        
    elseif strcmp(mode, 'local')
        AllDSets{iSpec} = fitModels(AllDSets{iSpec}, models, mode, [], ...
            length(AllDSets{iSpec}.P));
        
    end
end


%% Save if running locally 

if strcmp(mode, 'local')
    AllDSets = mT_removeFunctionHandles(AllDSets, ...
        {'FindSampleSize', 'FindIncludedTrials'});
    save([saveDir '\ModelRecoveryData'], 'AllDSets')
end
