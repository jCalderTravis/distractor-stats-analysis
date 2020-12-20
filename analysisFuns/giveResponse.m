function resp = giveResponse(Model, ParamStruct, Data, orientations, ...
    sampleShortcut)
% Simulates observer responses

% INPUT
% orientations
%           [num trials X num locations X num sims] array describing the 
%           real orientation of the Gabor patches
% All other inputs
%           See the comments for the function 'vS_computeTrialLL'

% Joshua Calder-Travis 
% j.calder.travis@gmail.com
% GitHub: jCalderTravis


% Add noise to the stimuli to generate percepts
percepts = addNoiseToStim(Model, ParamStruct, Data, orientations, ...
    sampleShortcut);


% What response is given in the current case?
if strcmp(Model.Inference, 'bayes')
    
    % Does the observer use the true kappa_s?
    if strcmp(Model.BlockTypes, 'ignore')
        kappaSEstimate = ParamStruct.ObserverKappaS;
        
    elseif strcmp(Model.BlockTypes, 'use')
        kappaSEstimate = Data.KappaS;
    end
    
    % What prior does the observer use?
    if strcmp(Model.Prior, 'true')
        prior = 0.5;
        
    elseif strcmp(Model.Prior, 'biased')
        prior = ParamStruct.ObserverPrior;
    end
    
    % Are there different KappaX values for each set size?
    if strcmp(Model.SetSizePrec, 'fixed')
        relKappaX = ParamStruct.Kappa_x;
        assert(length(ParamStruct.Kappa_x) == 1) 
        
    elseif strcmp(Model.SetSizePrec, 'variable')
        relKappaX = ParamStruct.Kappa_x(Data.SetSizeCond);
    end
    
    resp = makeBaysianDecision(percepts, Data.SetSize, relKappaX, ...
        kappaSEstimate, 0, prior);


elseif strcmp(Model.Inference, 'min')
    
    % Are we ignoring the set size when applying thresholds?
    if strcmp(Model.SetSizeThresh, 'variable')
       relSetSizes = Data.SetSizeCond; 
        
    elseif strcmp(Model.SetSizeThresh, 'fixed')
        relSetSizes = ones(size(Data.SetSizeCond));
    end
    
    % Are we ignoring the block type when applying thresholds?
    if strcmp(Model.BlockTypes, 'use')
        relBlockTypes = Data.BlockType; 
        
    elseif strcmp(Model.BlockTypes, 'ignore')
        relBlockTypes = ones(size(Data.SetSizeCond));
    end
    
    resp = makeMinRuleDecision(ParamStruct.Thresh, percepts, relSetSizes, ...
            relBlockTypes, 0);
end


% Do we also need to account for lapses?
if strcmp(Model.Lapses, 'yes')
    assert(isequal(size(resp), ...
        [size(orientations, 1), 1, size(orientations, 3)]) || ...
        isequal(size(resp), ...
        [size(orientations, 1), 1]))
    assert(~any(isnan(resp(:))))
    assert(all( (resp(:)==0) | (resp(:)==1) ))
    assert(islogical(resp))
    
    lapse = rand(size(resp)) < ParamStruct.LapseRate;
    resp(lapse) = rand([sum(lapse(:)), 1]) > 0.5;
end

