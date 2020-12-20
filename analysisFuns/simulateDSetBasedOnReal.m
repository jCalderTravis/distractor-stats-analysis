function SimDSet = simulateDSetBasedOnReal(RealDSet, modelNum, UserSpec)
% Simulate a dataset the same size as DSet, and based on the fitted parameters
% in DSet, for modelNum model (as numbered in DSet).

% INPUT
% UserSpec: Structure. Leave empty to simulate data of same size as the 
% fitted data. Provide fields to overwrite the defaults.

for iPtpnt = 1 : length(RealDSet.P)
    
    % Fitted model settings
    Spec.NumPtpnt = 1;
    Spec.TrialsPerCond = sum((RealDSet.P(iPtpnt).Data.BlockType == 1) & ...
        (RealDSet.P(iPtpnt).Data.SetSizeCond == 1));
    Spec.SetSizes = RealDSet.Spec.SetSizes;
    Spec.Kappa_s = unique(RealDSet.P(iPtpnt).Data.KappaS)';
    Spec.StatType = 'circ';
    
    % Apply user specified settings over defaults
    userSpecs = fieldnames(UserSpec);
    
    for iSpec = 1 : length(userSpecs)
        Spec.(userSpecs{iSpec}) = UserSpec.(userSpecs{iSpec});
    end 
    
    Spec.Params = RealDSet.P(iPtpnt).Models(modelNum).BestFit.Params;
    Spec.Name = RealDSet.P(iPtpnt).Models(modelNum).Settings.ModelName;
    
    PtpntData = produceStandardFormatDSet(Spec);
    
    if iPtpnt == 1
        SimDSet = PtpntData;
    else
        SimDSet.P(iPtpnt) = PtpntData.P;
    end
end

SimDSet.Spec.SetSizes = Spec.SetSizes;
SimDSet.Spec.NumBlockTypes = RealDSet.Spec.NumBlockTypes;
assert(isequal(RealDSet.Spec.NumBlockTypes, length(Spec.Kappa_s)))

