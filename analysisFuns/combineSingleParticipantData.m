function ConvertedDataFinal = combineSingleParticipantData(Data)
% The function simSingleCond simulates data for a signle participant and single 
% condition. This function combines all the simulations for a participant.

% INPUT
% Data: [num block types x num set sizes] struct array. Each structure is
% produced by simSingleCond

% Make the orientation data arrays the same size regardless of how many stimuli
% were in each condition
for iBlockType = 1 : size(Data, 1)
    for iSetSize = 1 : size(Data, 2)
        orientationDataSize = size(Data(iBlockType, iSetSize).Orientation);
        assert(orientationDataSize(2) <= 8) 
        % Code currently only deals with this case
        
        % Pad the orientation data with NaNs until it is 8 columns wide
        Data(iBlockType, iSetSize).Orientation = ...
            [Data(iBlockType, iSetSize).Orientation, ...
            NaN(orientationDataSize(1), 8-orientationDataSize(2))];
    end
end

assert(~isfield(Data, 'Title'))
assert(~isfield(Data, 'NumItems'))


% Collect all orientation data, as this has to be treated slightly differently
% in the combination of data because it is not a vector
allOrientations = [];

for iStruct = 1 : length(Data(:))
    allOrientations = [allOrientations; Data(iStruct).Orientation];
end

% Now we just need to combine all the other data together
Data = rmfield(Data, 'Orientation');
dataTable = table();

for iStruct = 1 : length(Data(:))    
    strcutData = struct2table(Data(iStruct));
    dataTable = [dataTable; strcutData];
end


% Combine everything 
ConvertedData = table2struct(dataTable, 'ToScalar', true);
ConvertedData.Orientation = allOrientations;

for iPtpnt = 1 : length(ConvertedData)
    vars = fieldnames(ConvertedData);
    
    for iVar = 1 : length(vars)
        if isfield(ConvertedData(iPtpnt), vars{iVar})
            
            ConvertedDataFinal(iPtpnt).Raw.(vars{iVar}) = ...
                ConvertedData(iPtpnt).(vars{iVar});
        end
    end
end

    
        
        