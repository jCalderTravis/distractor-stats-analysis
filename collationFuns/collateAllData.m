function DataStruct = collateAllData(directory, saveFile, makeOver100Figures)
% Collates all the data from the experiment script into two forms. First, a 
% MATLAB structure, and second, a CSV file. Performs checks on the result.

% NOTE
% collateOnePtpntData assumes all blocks have the same number of trials.

% INPUT
% directory: String. Where to look for files from the experiment script, and where to
% save the collated data
% saveFile: Boolean. Save the collated data?
% makeOver100Figures: This must be set to true for the function to run, but it
% is just to point out that a very large number of figures will be made.

if ~makeOver100Figures
    error('Function must make a very large number of figures.')
end


%% Locate which participant files there are

% Look through the files and work out how many participants there are
block1_FileNames = [directory '\ptpnt*_Session1_expInfo.mat'];
SettingsFiles = dir(block1_FileNames);
numParticipants = length(SettingsFiles);

disp(['Processing report... \n' num2str(numParticipants) ...
    ' participants identified.'])


% We need to identify all the participant numbers
participantNums = nan(numParticipants, 1); 
for index = 1:numParticipants
    
    % Is the 7th letter of the name a number? If so we are into double digits 
    % of participants
    if isstrprop(SettingsFiles(index).name(7), 'digit')    
        relevantIndicies = [6 7];
    else
        relevantIndicies = 6;
    end

    participantNum = str2double(SettingsFiles(index).name(relevantIndicies));
    participantNums(index) = participantNum;
end

participantNums = sortAndCheckNumerbing(participantNums);

% report the identified participants
disp('Participants identified...')
disp(participantNums)


%% Loop through participants collating data
for iPtpnt = 1 : numParticipants
    
    % Numbering of participants may not start from 1 so we must account for this
    ptpntNum = iPtpnt + min(participantNums) -1;

    PtpntData = collateOnePtpntData(directory, ptpntNum);
    
    if iPtpnt == 1
        DataStruct = PtpntData;
    else
        assert(~isequaln(DataStruct(iPtpnt-1), PtpntData))
        assert(isequaln(PtpntData, PtpntData))
        
        DataStruct(iPtpnt) = PtpntData;
    end
end


%% Save and then run checks on the data

if saveFile
    save([directory '\collatedData'], 'Data')
end

checkData(DataStruct, makeOver100Figures)
    
    
    
    