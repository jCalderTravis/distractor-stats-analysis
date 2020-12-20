function DSet = convertToStandardFormat(Data, saveDirectory)
% Converts the data produced by collateAllData to the standard data format
% used by the analysis code, and then saves. Also saves CSV versions of the data
% for each participant seperately. 

% Add some hardcoded experiment information. We will check these, thouhgh, below.
DSet.Spec.SetSizes = [2, 3, 4, 6];
DSet.Spec.NumBlockTypes = 2;

TempFormat = Data;

% Look through all strcutures in the array
for iStruct = 1 : length(Data(:))
    
    % Check the hard coded experiment information
    assert(isequal(unique(TempFormat(iStruct).SetSize)', DSet.Spec.SetSizes))
    assert(length(unique(TempFormat(iStruct).BlockType)) ...
        == DSet.Spec.NumBlockTypes) 
    
    % Some fields are to be renamed
    TempFormat(iStruct).Response = Data(iStruct).Resp;
    TempFormat(iStruct).Accuracy = Data(iStruct).Acc; 

    % Currently orientation is coded relative to vertical. Code instead realtive 
    % to the target.
    TempFormat(iStruct).Orientation = Data(iStruct).Orientation - (pi/2);
    TempFormat(iStruct).Orientation = ...
        vS_mapBackInRange(TempFormat(iStruct).Orientation, -pi, pi);
end

% Remove fields which are now duplicated
TempFormat = rmfield(TempFormat, 'Resp');
TempFormat = rmfield(TempFormat, 'Acc');

% Some other fields are to be removed
toRemove = {...
    'RtAbs', 'FixFlipTime', 'FixFlipEnd', 'FixTimeMes2', ...
    'StimulusOnset', 'StimFlipTime', 'StimFlipEnd', 'StimClearFlipTime', ...
    'StimClearFlipEnd', 'TrialDuration'};

for iField = 1 : length(toRemove)    
    TempFormat = rmfield(TempFormat, toRemove{iField});
end

% Save CSV version of the data for each participant
for iPtpnt = 1 : length(Data(:))
    PtpntData = struct2table(TempFormat(iPtpnt));
    writetable(PtpntData, [saveDirectory '/Ptpnt' num2str(iPtpnt) '.csv'])
    
    % Check the target is always recorded as having zero orientation
    targetIndex = sub2ind(size(PtpntData.Orientation), ...
        find(PtpntData.Target), ...
        PtpntData.TargetLoc(logical(PtpntData.Target)));
    targetVals = PtpntData.Orientation(targetIndex);
    assert(isequal(unique(targetVals), 0))
end

% Some more fields are to be removed
toRemove = {'RT'};

for iField = 1 : length(toRemove)    
    TempFormat = rmfield(TempFormat, toRemove{iField});
end

% Convert to standard format.
for iPtpnt = 1 : length(TempFormat)    
    DSet.P(iPtpnt).Data = TempFormat(iPtpnt);
end

% Add a field which provides a numbering of the different possible set
% sizes. 
for iPtpnt = 1 : length(DSet.P) 
    DSet.P(iPtpnt).Data.SetSizeCond = NaN(size(DSet.P(iPtpnt).Data.SetSize));
    for iSetSizeCond = 1 : length(DSet.Spec.SetSizes)
        
        DSet.P(iPtpnt).Data.SetSizeCond( ...
            DSet.P(iPtpnt).Data.SetSize == DSet.Spec.SetSizes(iSetSizeCond)) ...
            = iSetSizeCond;
    end
    
    if any(any(isnan(DSet.P(iPtpnt).Data.SetSizeCond))); error('Bug'); end
end


% Check the target is always recorded as having zero orientation
for iPtpnt = 1 : length(DSet.P)
    targetIndex = sub2ind(size(DSet.P(iPtpnt).Data.Orientation), ...
        find(DSet.P(iPtpnt).Data.Target), ...
        DSet.P(iPtpnt).Data.TargetLoc(logical(DSet.P(iPtpnt).Data.Target)));
    targetVals = DSet.P(iPtpnt).Data.Orientation(targetIndex);
    assert(isequal(unique(targetVals), 0))
end


save([saveDirectory '\StandardFormat'], 'DSet')

