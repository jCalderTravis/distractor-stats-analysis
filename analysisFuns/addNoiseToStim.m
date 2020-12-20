function percepts = addNoiseToStim(Model, ParamStruct, Data, stim, sampleShortcut)
% Add noise to observed stimulus. Different noise can be added for different
% trials. The code treats all orieations with the same first index, i.e.
% stim(i, :, :) as coming from the same trial.

% INPUT
% Model: See 'findDefaultModelSettings' for a description of all model 
% variants avaliable.
% ParamStruct: Structure containing a field for each fitted parameter.
% Data: Strcuture containing field for each feature of the
% stimulus/behaviour. Fields contain arrays which are num trials long,
% along the first dimention.
% stim: [num trials X num locations X nDraws] array describing the orientation 
% of the Gabor patches
% sampleShortcut: Instead of sampling from the von Mises. Draw a limited
% number of samples for each level of observer precision and
% then just sample from these. Currently only works when SetSizePrec is
% 'variable'.


% Produce array of simulated von Mises noise. Set up an array where rows are
% trials, and the third dimention indexes different simulations of the trial 
% (the different nDraws).
noise = NaN(size(stim));

% Only need to simulate noise for locations in which a stimulus was presented.
presentedLocs = ~isnan(stim);

% Is the precision of the noise fixed for all trials or does it depend on set
% size?
if strcmp(Model.SetSizePrec, 'fixed')
    assert(isequal(shape(ParamStruct.Kappa_x), [1, 1]))
    relKappaX = ParamStruct.Kappa_x;

    noise(presentedLocs) ...
        = qrandvm(0, relKappaX, sum(presentedLocs(:)));
    
elseif strcmp(Model.SetSizePrec, 'variable')
    if ~sampleShortcut
        
        % Find the relevant Kappa_x value. This depends on the set size.
        assert(isequal(length(unique(Data.SetSizeCond)), ...
            length(ParamStruct.Kappa_x)) || ...
            isequal(length(unique(Data.SetSizeCond)), 1))
        
        relKappaX = ParamStruct.Kappa_x(Data.SetSizeCond);
        assert(isequal(size(relKappaX), size(Data.SetSizeCond)))
        
        relKappaXShaped = repmat(relKappaX, 1, size(stim, 2));
        
        if length(size(stim)) == 3
            relKappaXShaped = repmat(relKappaXShaped, 1, 1, size(stim, 3));
        end
        assert(isequal(size(relKappaXShaped), size(stim)))
        
        relKappaXShaped(~presentedLocs) = NaN;
        
        noise ...
            = qrandvm(0, relKappaXShaped, size(noise));
        
    elseif sampleShortcut
        % Loop through the observer noise levels
        for iNoise = 1 : length(ParamStruct.Kappa_x)
        
            numSamples = 5000;
            vonMisesSamples = qrandvm(0, ParamStruct.Kappa_x(iNoise), numSamples);
            
            relevantLocs = presentedLocs & (Data.SetSizeCond == iNoise);
            
            noise(relevantLocs) ...
                = vonMisesSamples( ...
                randi(numSamples, [sum(relevantLocs(:)), 1, 1]));
        end
    end
end


% Add to the stimuli and then map them back in range if they are outside
% [-pi pi]
assert(isequal(size(stim), size(noise)))
percepts = stim + noise;
percepts = vS_mapBackInRange(percepts, -pi, pi);

% Check we have NaNs in the same place as we started
assert(isequal(isnan(stim), isnan(percepts)))

