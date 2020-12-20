function DSet = runFullCollationPipeline(directory, numTrials, ...
    makeOver100Figures)
% Collates all the data from the experiment script into one structure, and
% checks the result. Then converts all data to standard formats, and saves
% as a matlab structure, and as as CSV files. Further checks are then run.

% INPUT
% numTrials: How many trials do we expect for each participant?
% makeOver100Figures: This must be set to true for the function to run, but it
% is just to point out that a very large number of figures will be made.

if ~makeOver100Figures
    error('Function must make a very large number of figures.')
end

addpath('./collationFuns')
addpath('./circstat-matlab')
addpath('./analysisFuns')

Data = collateAllData(directory, false, makeOver100Figures);
DSet = convertToStandardFormat(Data, directory);

% Don't run checks on data from participant 10 as not all sessions completed
checkDataConsistency(directory, 10) 


% Remove participant data where did not complete all sessions, and resave
toRemove = zeros(length(DSet.P), 1);
for iP = 1 : length(DSet.P)
    
    if length(DSet.P(iP).Data.Response) ~= numTrials
        toRemove(iP) = 1;
    end
end

disp(['Data from ' num2str(sum(toRemove)) ' participants removed.'])

DSet.P(logical(toRemove)) = [];
assert(length(DSet.P) == sum(toRemove==0))

save([directory '\StandardFormat_incompleteRemoved'], 'DSet')


