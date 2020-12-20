function checkDataConsistency(saveDir, skip)
% Checks for consistency amoung the three representations of the data. All three
% representations should be present in the directory saveDir. The
% representations are...
% (a) The data as outputed by the experiment script
% (b) The data saved in CSV files by convertToStandardFormat.m
% (c) The data saved as a matlab structure by convertToStandardFormat.m

% INPUT
% skip: Vector of doubles. Code skips some checks on these participants. Helpful
% if data from a participant was not included in analysis. 


% Load the Matlab structure
Loaded = load([saveDir '\StandardFormat']);
DSet = Loaded.DSet;

%% Find number of participants according to each of the three represnetations
numPtpnts = length(DSet.P);
assert(numPtpnts == length(dir([saveDir '\ptpnt*_Session1_expInfo.mat'])))
assert(numPtpnts == length(dir([saveDir '\Ptpnt*.csv'])))


%% Check consistency between CSV and matlab strcuture data
for iP = 1 : numPtpnts
    csvData = readtable([saveDir '\Ptpnt' num2str(iP) '.csv']);
    assert(size(csvData, 1) == length(DSet.P(iP).Data.Response))

    fieldsToMatch = {'Session', 'BlockNum', 'BlockType', 'SetSize', ...
        'Target', 'TargetLoc', 'KappaS', 'Response', 'Accuracy'};
    for iF = 1 : length(fieldsToMatch)
        assert(isequaln(DSet.P(iP).Data.(fieldsToMatch{iF}), ...
            csvData.(fieldsToMatch{iF})))
    end
    
    % Have to check orientation seperately
    for iO = 1 : size(DSet.P(iP).Data.Orientation, 2)
        csvFieldName = ['Orientation_' num2str(iO)];
        assert(isequaln(round(DSet.P(iP).Data.Orientation(:, iO), 8), ...
            round(csvData.(csvFieldName), 8)))
    end 
end


%% Check for consistency between CSV and original datafiles
for iP = 1 : numPtpnts
    if any(iP == skip)
       disp(['Skipping checks on data from participant ' num2str(iP)])
       continue
    end
    
    csvData = readtable([saveDir '\Ptpnt' num2str(iP) '.csv']);
    numBlocks = size(unique([csvData.Session, csvData.BlockNum], 'rows'), 1);
    originalFiles = dir([saveDir '\ptpnt' num2str(iP) '_test_Session*Block*.mat']);
    assert(numBlocks == length(originalFiles))
    
    trialNumInBlock = NaN;
    previousBlock = NaN;
    for iTrial = 1 : size(csvData, 1)
        sessionNum = csvData.Session(iTrial);
        blockNum = csvData.BlockNum(iTrial);
        if blockNum ~= previousBlock
            trialNumInBlock = 1;
            previousBlock = blockNum;
        else
            trialNumInBlock = trialNumInBlock +1;
        end
        
        Loaded = load([saveDir '\ptpnt' num2str(iP) ...
            '_test_Session' num2str(sessionNum) 'Block' num2str(blockNum) '.mat']);
        OriginalData = Loaded.BlockData;
        
        % Loop through fields
        fieldsInCSV = {'SetSize', 'Target', 'TargetLoc', ...
            'RT', 'Response', 'Accuracy'};
        fieldsInOriginal = {'SetSize', 'Target', 'TargetLoc', ...
            'RT', 'Resp', 'Acc'};
        
        for iF = 1 : length(fieldsInCSV)
            assert(isequaln(csvData.BlockType(iTrial), ...
                OriginalData.BlockType))
        end
        
        % Have to check block type seperately
        assert(isequaln(round(csvData.(fieldsInCSV{iF})(iTrial), 8), ...
                round(OriginalData.(fieldsInOriginal{iF})(trialNumInBlock), 8)))
        
        % Also have to check orientation seperately.
        % Rememeber have subtracted off half pi from orientations when collating
        % the data.
        for iO = 1 : size(OriginalData.Orientation, 2)
            csvFieldName = ['Orientation_' num2str(iO)];
            csvValue = csvData.(csvFieldName)(iTrial);
            csvValue = vS_mapBackInRange(csvValue + (pi/2), -pi, pi);
            
            assert(isequaln(round(OriginalData.Orientation(trialNumInBlock, iO), 8), ...
                round(csvValue, 8)))
        end
    end
end


%% Check for consistently within the matlab data structure 

% Check that kappaS and blocktype always match. That is, there is a one-to-one
% relation between blockType and kappaS.
for iP = 1 : length(DSet.P)
    combo = [DSet.P(iP).Data.BlockType, DSet.P(iP).Data.KappaS];
    combo = unique(combo, 'rows');
    
    disp('Block type and Kappa_s combinations...')
    disp(combo)
    
    assert(~any(isnan(combo(:))))
    assert(length(unique(combo(:, 1))) == length((combo(:, 1))))
    assert(length(unique(combo(:, 2))) == length((combo(:, 2))))
end
    
% Check that the orientation of the target is at zero
for iP = 1 : length(DSet.P)
    for iT = 1 : length(DSet.P(iP).Data.Response)
        if DSet.P(iP).Data.Target(iT) == 1
            targetLoc = DSet.P(iP).Data.TargetLoc(iT);
            assert(DSet.P(iP).Data.Orientation(iT, targetLoc) == 0)
        end
    end
end

% Check set size cond, and set size match perfectly such that there is a
% one-to-one relation.
for iP = 1 : length(DSet.P)
    combo = [DSet.P(iP).Data.SetSize, DSet.P(iP).Data.SetSizeCond];
    combo = unique(combo, 'rows');
    
    disp('Set size and set size condition combinations...')
    disp(combo)
    
    assert(~any(isnan(combo(:))))
    assert(length(unique(combo(:, 1))) == length((combo(:, 1))))
    assert(length(unique(combo(:, 2))) == length((combo(:, 2))))
end

