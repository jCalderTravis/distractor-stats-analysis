function CollatedData = collateOnePtpntData(directory, ptpntNum)
% Collate the data from all blocks and sessions for a participant


%% Identify sessions

% How many sessions are there?
settingsFileNames  = [directory ...
    '\ptpnt' num2str(ptpntNum) '_Session*_expInfo.mat'];
SessionSettingsFiles = dir(settingsFileNames);

if length(SessionSettingsFiles) > 9    
    error('Note coded to cope with 9 sessions')
end


% Where the session appears in the file name depends on how many digits the
% participants number takes up.
if ptpntNum >= 10
    relIndex = 16;
else
    relIndex = 15;
end
    
SessionNumbers = arrayfun( ...
    @(fileStruct) str2double(fileStruct.name(relIndex)), SessionSettingsFiles);
SessionNumbers = sortAndCheckNumerbing(SessionNumbers);

if SessionNumbers(1) ~= 1    
    error('Session 1 is missing')
end

numSessions = max(SessionNumbers);

disp(['Sessions identified: Ptpnt ' num2str(ptpntNum), ...
    '.....' num2str(numSessions) '  sessions.'])


%% Loop through sessions

% Note that BlockData.Orienation is not a vecotor but a matrix, and must be
% handled differently
AllData = [];
allOrientations = [];

for iSession = 1 : numSessions
    
    % Load settings so we know how many blocks and trials there are.
    LoadedFiles = load([directory '\ptpnt' num2str(ptpntNum) ...
        '_Session' num2str(iSession) '_expInfo.mat']);
    ExpInfo = LoadedFiles.ExpInfo;
    
    for iBlock = 1 : ExpInfo.NumBlocks

        LoadedFiles = load([directory '\ptpnt' num2str(ptpntNum) ...
            '_test_Session' num2str(iSession) 'Block' num2str(iBlock) '.mat']);
        BlockData = LoadedFiles.BlockData;
        
        % Some of the data is stored as a single value for the whole block.
        % Expand so that there is one value (always the same) for each
        % trial, ready for converting the data into a table.
        BlockData.BlockNum = repmat(BlockData.BlockNum, ...
            size(BlockData.Target, 1), 1);
        
        BlockData.BlockType = repmat(BlockData.BlockType, ...
            size(BlockData.Target, 1), 1);
        
        % Also add to the data the true stimulus distribution concentration
        % parameter from which the distractors were drawn
        BlockData.KappaS = ExpInfo.DistractorKappa(BlockData.BlockType)';
        
        % Also add a column specifying the session number. But we want it
        % to be the first field so we have to do some work...
        BlockAndSessionData = struct();
        BlockAndSessionData.Session = repmat(iSession, ...
            size(BlockData.Target, 1), 1);
        
        fieldsToAdd = fieldnames(BlockData);
        for iField = 1 : length(fieldsToAdd)
            
            BlockAndSessionData.(fieldsToAdd{iField}) = ...
                BlockData.(fieldsToAdd{iField});
        end
        
        % Retrieve orientation data, to add back later
        allOrientations = [allOrientations; BlockAndSessionData.Orientation];
        
        BlockAndSessionData.Orientation = ...
            NaN(size(BlockAndSessionData.Orientation, 1), 1);
        
        % Add the data from this block to the big structure
        AllData = [AllData, BlockAndSessionData];
    end
end

% Turn the array of structs into a struct containing arrays
dataTable = table();

for iBlock = 1 : length(AllData)
    blockData = struct2table(AllData(iBlock));
    dataTable = [dataTable; blockData];
end

CollatedData = table2struct(dataTable, 'ToScalar', true);

% Add back in the orientation data
CollatedData.Orientation = allOrientations;


end

