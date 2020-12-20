function resp = giveResponseImp2(Model, ParamStruct, Data, orientations)
% A second slower implimentation of giveResponse, for testing the output of
% giveResponse

%% Add noise to the stimuli to generate percepts
numTrials = length(Data.BlockType);
numSims = size(orientations, 3);
percepts = nan(size(orientations));

for iTrial = 1 : numTrials
    for iSim = 1 : numSims
        setSizeCond = Data.SetSizeCond(iTrial);
        
        if strcmp(Model.SetSizePrec, 'variable')
            perceptualNoise = ParamStruct.Kappa_x(setSizeCond);
            
        elseif strcmp(Model.SetSizePrec, 'fixed')
            perceptualNoise = ParamStruct.Kappa_x;
        end
        
        assert(isequal(size(perceptualNoise), [1, 1]))
        
        theseLocs = orientations(iTrial, :, iSim);
        activeLocs = ~isnan(theseLocs);
        noise = circ_vmrnd_fixed(0, perceptualNoise, [1, sum(activeLocs)]);
        
        thesePercepts = theseLocs;
        thesePercepts(activeLocs) = thesePercepts(activeLocs) + noise;
        thesePercepts = vS_mapBackInRange(thesePercepts, -pi, pi);
        percepts(iTrial, :, iSim) = thesePercepts;
    end
end


%% Simulate responses based on percept
resp = NaN(numTrials, 1, numSims);

for iTrial = 1 : numTrials
    for iSim = 1 : numSims
        
        % Which set size condition (numbered 1-4) are we on?
        setSizeNumber = find([2, 3, 4, 6] == Data.SetSize(iTrial));
        assert(isequal(size(setSizeNumber), [1, 1]))
        
        if strcmp(Model.Inference, 'bayes')
            
            % Find the prior
            if strcmp(Model.Prior, 'true')
                prior = 0.5;
                
            elseif strcmp(Model.Prior, 'biased')
                prior = ParamStruct.ObserverPrior;
            end
            
            % Find the stimulus kappa estimate
            if strcmp(Model.BlockTypes, 'ignore')
                kappaSEstimate = ParamStruct.ObserverKappaS;
                
            elseif strcmp(Model.BlockTypes, 'use')
                kappaSEstimate = Data.KappaS(iTrial);
            end
            
            % Find the measurement noise level
            measNoise = ParamStruct.Kappa_x(setSizeNumber);
            
            
            % Compute the likelihood of target and non-target at each location 
            % given the measurement
            trialPercepts = percepts(iTrial, :, iSim);
            relevantLocs = find(~isnan(trialPercepts));
            
            likelyT1_givenX = NaN(length(relevantLocs), 1);
            likelyT0_givenX = NaN(length(relevantLocs), 1);
            
            for iPercept = 1 : length(relevantLocs)
                
                % Perform the computation numerically, by putting down a mesh grid,
                % multiplying different functions on the grid, and integrating by
                % summing
                spacing = 0.01;
                s = -pi : spacing : pi;
                
                noiseTerm = circ_vmpdf(s, trialPercepts(relevantLocs(iPercept)), ...
                    measNoise);
                stimGivenT_0 = circ_vmpdf(s, 0, kappaSEstimate);
                
                likelyT1_givenX(iPercept) = circ_vmpdf(...
                    trialPercepts(relevantLocs(iPercept)), ...
                    0, measNoise);
                likelyT0_givenX(iPercept) = sum(noiseTerm .* stimGivenT_0) ...
                    * spacing;
            end
            
            % Now we need to calculate the probability the target is absent, 
            % and the probability it is in one of the locations
            likelyPresentInLoc = NaN(length(relevantLocs), 1);
            
            for iRelLoc = 1 : length(relevantLocs)
                % Work out the probability that all locations are not targets, 
                % apart from the one hypothesised
                locLikely = likelyT0_givenX;
                locLikely(iRelLoc) = likelyT1_givenX(iRelLoc);
                
                likelyPresentInLoc(iRelLoc) = prod(locLikely);
            end
            
            % And what is the probability the target is not present anywhere?
            likelyAbsent = prod(likelyT0_givenX);
            
            % What is the probability the target is present somewhere?
            likelyPresent = (1/length(relevantLocs)) * sum(likelyPresentInLoc);
            
            % What is the prior ratio
            priorRatio = prior / (1 - prior);
            
            % What is the posterior ratio?
            posteriorRatio = priorRatio*(likelyPresent/likelyAbsent);
            
            % What is the response?
            resp(iTrial, 1, iSim) = double(posteriorRatio>1);
            
        elseif strcmp(Model.Inference, 'min')
            
            % Are we ignoring the block type when applying thresholds?
            if strcmp(Model.BlockTypes, 'ignore')
                relThresholds = ParamStruct.Thresh;
                
            elseif strcmp(Model.BlockTypes, 'use')
                
                if Data.BlockType(iTrial) == 1
                    relThresholds = ParamStruct.Thresh(:, 1);
                elseif Data.BlockType(iTrial) == 2
                    relThresholds = ParamStruct.Thresh(:, 2);
                end
            end
            
            % Lets find the threshold which is relevant on this trial
            thisThresh = relThresholds(setSizeNumber);
            
            mostSimilarItem = min(abs(percepts(iTrial, :, iSim)));
            resp(iTrial, 1, iSim) = double(mostSimilarItem < thisThresh);
        end
        
        % Do we also need to account for lapses?
        if strcmp(Model.Lapses, 'yes') && (rand(1) < ParamStruct.LapseRate)
            resp(iTrial, 1, iSim) = double(rand(1) < 0.5);
        end
        
    end
end


