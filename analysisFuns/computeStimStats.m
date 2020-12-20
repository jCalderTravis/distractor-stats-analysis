function Data = computeStimStats(Data, statType, incTarget)
% Compute some statistics of the simuli.

% INPUT
% Data              Struct array or structure with fields, 'Orientation',
%                   'Target', and 'SetSize'. Additional fields will be added.
% incTarget         If true then the target is treated as a distractor for the
%                   computation of the distractor statistics.

% Joshua Calder-Travis 
% j.calder.travis@gmail.com
% GitHub: jCalderTravis


for iElement = 1 : length(Data(:))
    if ~incTarget
        % First need to find the indcies in Data.Orientation which correspond 
        % to targets
        targetIndex = sub2ind([size(Data(iElement).Orientation)], ...
            find(Data(iElement).Target), ...
            Data(iElement).TargetLoc(logical(Data(iElement).Target)));
        
        % Retrieve the stimuli orientations and remove the target orientations 
        % from these
        distractorAngle = Data(iElement).Orientation;
        
        % Code checks
        targetVals = distractorAngle(targetIndex);
        if isempty(targetVals)
            warning('No target trials found.')
        elseif length(unique(targetVals)) ~= 1
            error('Bug')
        end
        assert(isequal(unique(targetVals), 0))
        
        distractorAngle(targetIndex) = NaN;
        
        distractorAngle = mat2cell(distractorAngle, ...
            ones(size(distractorAngle, 1), 1));
        assert(isequal(size(distractorAngle), [length(Data(iElement).Target), 1]))
        
        distractorAngle = cellfun(@(vector) removeNaNs(vector), distractorAngle, ...
            'UniformOutput', false);
        assert(isequal(size(distractorAngle), [length(Data(iElement).Target), 1]))
        
        % Check the resulting vectors are all the expected length
        for iRow = 1 : length(distractorAngle)
            expectedLength = Data(iElement).SetSize(iRow) ...
                - double(Data(iElement).Target(iRow));
            
            if length(distractorAngle{iRow}) ~= expectedLength; error('bug'); end
        end
        
        % If any cells are now empty replace them with NaNs
        emptyCells = cellfun(@(vector) isempty(vector), distractorAngle);
        distractorAngle(emptyCells) = {NaN};
        
    elseif incTarget
        distractorAngle = Data(iElement).Orientation;

        distractorAngle = mat2cell(distractorAngle, ...
            ones(size(distractorAngle, 1), 1));
        assert(isequal(size(distractorAngle), [length(Data(iElement).Target), 1]))
    end
    
    
    % Compute some statistics of the stimuli
    if strcmp(statType, 'circ')
        [~, Data(iElement).DistractorStd] = cellfun( @(angles) circ_std(angles'), ...
            distractorAngle);
        assert(isequal(size(Data(iElement).DistractorStd), ...
            size(Data(iElement).Target)))
        
        Data(iElement).DistractorVar = cellfun( @(angles) circ_var(angles'), ...
            distractorAngle);
        assert(isequal(size(Data(iElement).DistractorVar), ...
            size(Data(iElement).Target)))
        
        Data(iElement).DistractorMean = cellfun( @(angles) abs(circ_mean(angles')), ...
            distractorAngle);
        assert(isequal(size(Data(iElement).DistractorMean), ...
            size(Data(iElement).Target)))
        
    elseif strcmp(statType, 'real')
        Data(iElement).DistractorStd = cellfun( @(angles) std(angles'), ...
            distractorAngle);
        
        Data(iElement).DistractorVar = cellfun( @(angles) var(angles'), ...
            distractorAngle);
        
        Data(iElement).DistractorMean = cellfun( @(angles) abs(mean(angles')), ...
            distractorAngle);
    else
        error('Bug')
    end
    
    Data(iElement).MostSimilarDistr = cellfun( @(angles) min(abs(angles)), ...
        distractorAngle);
    assert(isequal(size(Data(iElement).MostSimilarDistr), ...
            size(Data(iElement).Target)))
end

end


function vector = removeNaNs(vector)
% Remove the NaNs from a vector

vector(isnan(vector)) = [];

end


