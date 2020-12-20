function response = makeMinRuleDecision(thresholds, percept, setSizeCond, ...
    blockType, mu_s)
% Make the decision

% INPUT
% thresholds    A set of [numSetSizes x blockTypes] thresholds, which are applied
%           to the item most similar to the target to determine the response
% percept   [numTrials x setSize x num sims] array of stimulus percepts
% mu_s      Center of the distractor distribution

% Joshua Calder-Travis 
% j.calder.travis@gmail.com
% GitHub: jCalderTravis


% Check input
if size(percept, 2) > 8; error('Bug'); end

% We use implicit expansion below so it is very important that all input
% vectors are the expected shape.
inputVectors = {setSizeCond, blockType, mu_s};

for iInputVec = 1 : length(inputVectors)
    vecSize = size(inputVectors{iInputVec});

    if (length(vecSize) ~= 2) || (vecSize(2) ~= 1)
        error('Bug')
    end
end


% Find the item that is closest to the target
closestItem = min(abs(percept - mu_s), [], 2);

% Find the relevant threshold for each trial
thresholdIndex = sub2ind(size(thresholds), setSizeCond, blockType);

activeThreshold = NaN(size(closestItem, 1), 1, 1);
activeThreshold(:) = thresholds(thresholdIndex);

% If the closest item is below the threshold respond that the target is present
response = closestItem < activeThreshold;


assert(isequal(size(response), [size(percept, 1), 1, size(percept, 3)]) || ...
    isequal(size(response), [size(percept, 1), 1]))

