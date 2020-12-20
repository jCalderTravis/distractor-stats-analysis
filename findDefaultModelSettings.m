function Settings = findDefaultModelSettings(ModelSpec, DSet)
% For any given model, function produces a set of default settings following the
% specification in the README of the modellingTools submodule.

% INPUT
% ModelSpec     Struct array with fields...
%   Inference       'bayes' or 'min'
%   Prior           Only used for 'bayes' inference. 'biased' or 'true'
%   SetSizeThresh   Only used for 'min' inference. 'variable' or fixed'
%                   determines whether have a diference threshold for each set
%                   size.
%   SetSizePrec     'fixed' or 'variable' precision of orientation perception as
%                   set size increases.
%   Lapses          'yes' or 'no'
%   BlockTypes      'ignore' or 'use'. Has different effect depending on the
%                   inference used. For 'bayes' if 'use' participant uses the
%                   information on the kappa_s for each block. If 'ignore'
%                   participant uses the same incorrect value of kappa_s for all
%                   trials. For 'min', if 'ignore' the participant uses the same
%                   thresholds across all block types.


%% Standard settings

% Some settings we will use for all models
Settings.Algorithm = 'bads';
Settings.ModelName = ModelSpec;
Settings.ComputeTrialLL.FunName = 'vS_computeTrialLL';
nDraws = 1000;
sampleShortcut = false;
Settings.ComputeTrialLL.Args = {ModelSpec, nDraws, sampleShortcut};
Settings.NumStartPoints = 40;
Settings.PresetStartPoints = false;
Settings.NumStartCand = 150; %150
Settings.TrialChunkSize = 'off';
Settings.FindSampleSize = @(Data) length(Data.Response);
Settings.FindIncludedTrials = @(Data) true(size(Data.Response));
Settings.FindIfOutOfBounds = 'none';
Settings = initialiseParamStructArray(Settings, 1);
Settings.SuppressOutput = true;
Settings.ReseedRng = true;
Settings.DebugMode = false;
Settings.JobsPerContainer = 3;


% The parameters have some of the same settings regarless of the model they are 
% put into, so lets define them here.

% Kappa_x
StandardParam(1).Name = 'Kappa_x';
StandardParam(1).FitLog = true;
StandardParam(1).FitSqrt = false;
StandardParam(1).UnpackedOrder = 1;
StandardParam(1).UnpackedShape = [1, 1];
StandardParam(1).LowerBound = @() exp(-6);
StandardParam(1).PLB = @() exp(-4);
StandardParam(1).UpperBound = @() 700;
StandardParam(1).PUB = @() 100;
StandardParam(1).Regulariser = @(param) 0; %sum(min(param, 10));

% LapseRate
StandardParam(2).Name = 'LapseRate';
StandardParam(2).FitLog = false;
StandardParam(2).FitSqrt = false;
StandardParam(2).UnpackedOrder = 1;
StandardParam(2).UnpackedShape = [1, 1];
StandardParam(2).LowerBound = @() 0;
StandardParam(2).PLB = @() 0.005;
StandardParam(2).UpperBound = @() 1; 
StandardParam(2).PUB = @() 0.4;
StandardParam(2).Regulariser = @(param) 0;

% Thresholds
StandardParam(3).Name = 'Thresh';
StandardParam(3).FitLog = true;
StandardParam(3).FitSqrt = false;
StandardParam(3).UnpackedShape = [1, 1];
StandardParam(3).UnpackedOrder = 1;
StandardParam(3).LowerBound(:) = @() exp(-6);
StandardParam(3).PLB = @() pi/50;
StandardParam(3).UpperBound(:) = @() pi;
StandardParam(3).PUB = @() (3*pi)/4;
StandardParam(3).Regulariser = @(param) 0;

% Generative model prior (The observer's incorrect prior)
StandardParam(4).Name = 'ObserverPrior';
StandardParam(4).FitLog = false;
StandardParam(4).FitSqrt = false;
StandardParam(4).UnpackedShape = [1, 1];
StandardParam(4).UnpackedOrder = 1;
StandardParam(4).LowerBound(:) = @() 0;
StandardParam(4).PLB = @() 0.2;
StandardParam(4).UpperBound(:) = @() 1;
StandardParam(4).PUB = @() 0.8;
StandardParam(4).Regulariser = @(param) 0;

% Generative model kappa_s (The observer's incorrect belief about kappa_s, 
% assumed by the observer to be constant across all blocks)
StandardParam(5).Name = 'ObserverKappaS';
StandardParam(5).FitLog = true;
StandardParam(5).FitSqrt = false;
StandardParam(5).UnpackedShape = [1, 1];
StandardParam(5).UnpackedOrder = 1;
StandardParam(5).LowerBound(:) = @() exp(-6);
StandardParam(5).PLB = @() exp(-6);
StandardParam(5).UpperBound(:) = @() 700;
StandardParam(5).PUB = @() 100;
StandardParam(5).Regulariser = @(param) 0;

for iPm = 1 : length(StandardParam)
    StandardParam(iPm).InitialVals = @()drawUniformOnInterval(1, ...
                                                        StandardParam(iPm).PLB(), ...
                                                        StandardParam(iPm).PUB(), ...
                                                        StandardParam(iPm).FitLog);
end


%% Define the models

paramCount = 0;
paramSetCount = 0;

% All models use kappa_x, but how many values of kappa_x there are depends on 
% the model
CurrentParam = StandardParam(1);
if strcmp(ModelSpec.SetSizePrec, 'variable')
    
    CurrentParam = mT_duplicateParams(CurrentParam, ...
        length(DSet.Spec.SetSizes), 1);
    
    % Ensure that values drawn decend down the first axis
    kappaXValsFun = CurrentParam.InitialVals;
    CurrentParam.InitialVals ...
        = @()drawConstrainedValues(kappaXValsFun);
    
elseif ~strcmp(ModelSpec.SetSizePrec, 'fixed')
    error('Unknown model spec')
end

[Settings, paramCount, paramSetCount] ...
        = addParameter(Settings, paramCount, paramSetCount, CurrentParam);


% The 'min' inference model also uses thresholds. The number of these depends on
% whether the observer uses different thhresholds for different set sizes and
% block types.
if strcmp(ModelSpec.Inference, 'min')
    CurrentParam = StandardParam(3);
    
    if strcmp(ModelSpec.SetSizeThresh, 'variable')
        setSizeThresholds = length(DSet.Spec.SetSizes);
        
    elseif strcmp(ModelSpec.SetSizeThresh, 'fixed')
        setSizeThresholds = 1;
    end
    
    if strcmp(ModelSpec.BlockTypes, 'use')
        blockThresholds = DSet.Spec.NumBlockTypes;
        
    elseif strcmp(ModelSpec.BlockTypes, 'ignore')
        blockThresholds = 1;
    end
    
    CurrentParam = mT_duplicateParams(CurrentParam, ...
        setSizeThresholds, blockThresholds);
    
    % Ensure that initial values drawn decend down the first axis
    threshValsFun = CurrentParam.InitialVals;
    CurrentParam.InitialVals ...
        = @()drawConstrainedValues(threshValsFun);
    
    [Settings, paramCount, paramSetCount] ...
        = addParameter(Settings, paramCount, paramSetCount, CurrentParam);
end


% Are lapses being modelled?
if strcmp(ModelSpec.Lapses, 'yes')
    [Settings, paramCount, paramSetCount] ...
        = addParameter(Settings, paramCount, paramSetCount, StandardParam(2));
    
elseif ~strcmp(ModelSpec.Lapses, 'no')
    error('Unknown model spec')
end


% The Bayesian model has some parameters unique to it
if strcmp(ModelSpec.Inference, 'bayes')
    
    % Does the observer use the true prior?
    if strcmp(ModelSpec.Prior, 'biased')
        [Settings, paramCount, paramSetCount] ...
            = addParameter(Settings, paramCount, paramSetCount, StandardParam(4));
        
    elseif ~strcmp(ModelSpec.Prior, 'true')
        error('Incorrect specification of model')
        
    end
    
    % Does the observer use the true kappa_s?
    if strcmp(ModelSpec.BlockTypes, 'ignore')
        [Settings, paramCount, paramSetCount] ...
            = addParameter(Settings, paramCount, paramSetCount, StandardParam(5));
        
    elseif ~strcmp(ModelSpec.BlockTypes, 'use')
        error('Incorrect specification of model')
    end
end

Settings.NumParams = paramCount;

end


function CompleteStruct = modifyStruct(StructA, StructB)
% Modifies the fields in StructA to match the corresponding fields in
% StructB

fields = fieldnames(StructB);

for iField = 1 : length(fields)
    StructA.(fields{iField}) = StructB.(fields{iField});
end

CompleteStruct = StructA;

end


function [Settings, paramCount, paramSetCount] ...
    = addParameter(Settings, paramCount, paramSetCount, ParamToAdd)
% Add a parameter structure to the modelling settings structure 'Settings',
% keeping track of how many parameters are now specified in the model described
% by 'Settings'.

Settings.Params(paramSetCount+1).Name = [];
Settings.Params(paramSetCount+1) = ...
    modifyStruct(Settings.Params(paramSetCount+1), ParamToAdd);

exampleInitialVals = ParamToAdd.InitialVals();
Settings.Params(paramSetCount +1).PackedOrder = ...
    paramCount + 1 : (paramCount + length(exampleInitialVals(:)));

paramSetCount = paramSetCount +1;
paramCount = paramCount + length(exampleInitialVals(:));

end


function Struct = initialiseParamStructArray(Struct, lengthOfStruct)
% Add a 'Params' field to Struct and initialise certain fields.

for iStruct = 1 : lengthOfStruct
    Struct.Params(iStruct).Name = NaN;
    Struct.Params(iStruct).FitLog = NaN;
    Struct.Params(iStruct).FitSqrt = NaN;
    Struct.Params(iStruct).UnpackedOrder = NaN;
    Struct.Params(iStruct).UnpackedShape = NaN;
    Struct.Params(iStruct).InitialVals = NaN;
    Struct.Params(iStruct).LowerBound = NaN;
    Struct.Params(iStruct).PLB = NaN;
    Struct.Params(iStruct).UpperBound = NaN;
    Struct.Params(iStruct).PUB = NaN;
    Struct.Params(iStruct).PackedOrder = NaN;
    Struct.Params(iStruct).Regulariser = NaN;
end

end
      

