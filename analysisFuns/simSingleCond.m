function Data = simSingleCond(Model, ParamStruct, nTrials, nItems, ...
    setSizeCond, statType, distStats, blockType)
% Simulate stimuli and responses for a signle condition. 

% INPUT
% Model     The name of the true model. Should use the same naming
%           system as in 'enumerateModels'.
% ParamStruct
%           Standard parameter structure.
% nTrials   Number to simulate
% nItems    Number of items in the display in this condition 
% setSizeCond
%           All the different possible number of nItems in the experiment, should
%           be assigned a number running from 1 to the number of set size 
%           conditions. What is the number for the nItems in this simulation?
%           May be used, for example, to index into ParamStruct.Kappa_x
% statType  Old feature. Must provide 'circ' for circular statistics.
% distStats Struct of distractor statistics. Requred fields...
%   mu_s      Distractor mean
%   kappa_s   Distoractor von Mises concentration parameter
% blockType Each different block type in the experiment should be assigned a
%           number. What is the number for the current block type.

% Joshua Calder-Travis 
% j.calder.travis@gmail.com
% GitHub: jCalderTravis


% Check there are no extra fields in distStats
if strcmp(statType, 'circ')
    requiredFields = {'mu_s', 'kappa_s'};

    names = fieldnames(distStats);    
    if any(~ismember(names, requiredFields))
        error('Incorrect use of fields in distStats.')
    end
else
    error('Other options no longer supported.')    
end
           
assert(isequal(size(nItems), [1, 1]))
assert(isequal(size(setSizeCond), [1, 1]))
assert(isequal(size(blockType), [1, 1]))
assert(isequal(size(distStats.mu_s), [1, 1]))
assert(isequal(size(distStats.kappa_s), [1, 1]))


%% Randomise stimulus properties

% Set the probability of the target being present to 0.5
Data.Target = logical(randi([0 1], nTrials, 1));

% Randomise target locations
Data.TargetLoc = randi([1 nItems], nTrials, 1);
Data.TargetLoc(~Data.Target) = NaN;

% Randomise distractor orientations
Data.Orientation = circ_vmrnd_fixed(distStats.mu_s, distStats.kappa_s, ...
    [nTrials, nItems]);

% Set the orientations of the targets to zero.
% First need to find the indcies in Data.Orientation which correspond to targets
targetIndex = sub2ind([size(Data.Orientation)], ...
    find(Data.Target), Data.TargetLoc(Data.Target));
Data.Orientation(targetIndex) = 0;

% Add some properties of the stimulus to the data struct
Data.SetSize = repmat(nItems, nTrials, 1);
Data.BlockType = repmat(blockType, nTrials, 1);
Data.SetSizeCond = repmat(setSizeCond, nTrials, 1);
Data.KappaS = repmat(distStats.kappa_s, nTrials, 1);


%% Simulate response

% Simulate percept. Perceptual noise will be von Mises distributed.
Data.Response = giveResponse(Model, ParamStruct, Data, Data.Orientation, false);

Data.Accuracy = Data.Response == Data.Target;


