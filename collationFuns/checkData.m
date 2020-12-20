function checkData(DataStruct, makeOver100Figures)
% Run various checks on the data produced from the experiment. Uses the
% output of collateAllData.

% INPUT
% makeOver100Figures: This must be set to true for the function to run, but it
% is just to point out that a very large number of figures will be made.

if ~makeOver100Figures
    error('Function must make a very large number of figures.')
end

for iPtpnt = 1 : length(DataStruct(:))
    
    %% Raw data
    
    % Print table of some data
    dataTable = struct2table(DataStruct(iPtpnt));
    dataTable(1:10, :)
    
    % Print some orientation data
    disp(DataStruct(iPtpnt).Orientation(1:10, :))
    
    % Did everything record that was meant to?
    stats = {'FixFlipTime', 'FixFlipEnd', 'FixTimeMes2', 'StimulusOnset', ...
        'StimFlipTime', 'StimFlipEnd', 'StimClearFlipTime', ...
        'StimClearFlipEnd', 'TrialDuration', 'RtAbs', 'RT', 'Session', ...
        'BlockNum', 'BlockType', 'Target', 'Resp', 'Acc', 'SetSize'};
    
    for iStat = 1 : length(stats)
        statData = DataStruct(iPtpnt).(stats{iStat});
        if any(isnan(statData(:))); error('Bug'); end
    end
    
    
    %% Basic summaries
    
    blockTypes = unique(DataStruct(iPtpnt).BlockType)';
    assert(isequal(blockTypes, [1, 2]))
    
    blockOrientations = {[], []}; % Once cell for each block type
    for iTrial = 1 : length(DataStruct(iPtpnt).BlockType)
        
        relevantData = DataStruct(iPtpnt).Orientation(iTrial, :);
        
        % Remove target from consideration
        if ~isnan(DataStruct(iPtpnt).TargetLoc(iTrial))
            relevantData(DataStruct(iPtpnt).TargetLoc(iTrial)) = [];
        end
        
        % And remove any inactive locations
        relevantData(isnan(relevantData)) = [];
        
        thisBlockType = DataStruct(iPtpnt).BlockType(iTrial);
        blockOrientations{thisBlockType} = ...
            [blockOrientations{thisBlockType}; relevantData(:)];
    end
    
    % Check all orientation data is within the expected range
    for iBlockType = blockTypes
        if any(blockOrientations{iBlockType}(:) > pi) || ...
                any(blockOrientations{iBlockType}(:) < -pi)
            error('Bug')
        end
    end
    
    % Make histograms of the orientation data to look at distributions
    figure; hold on
    colours = {'g', 'b'};
    
    for iBlockType = blockTypes
        % Work out the distribution expected in this block type
        trialsInBlock = DataStruct(iPtpnt).BlockType == iBlockType;
        kappaS = DataStruct(iPtpnt).KappaS(trialsInBlock);
        assert(length(unique(kappaS)) == 1)
        kappaS = unique(kappaS);
        
        histogram(blockOrientations{iBlockType}, ...
            'FaceColor', colours{iBlockType}, ...
            'Normalization', 'pdf')
        
        %What did we expect?
        x = -pi : 0.01 : pi;
        y = circ_vmpdf(x, pi/2, kappaS);
        plot(x, y, colours{iBlockType})
    end
    hold off
    
    % Display some stats about the number of trials in each condition
    stats = {'Session', 'BlockNum', 'BlockType', 'Target', 'TargetLoc', ...
        'SetSize', 'Resp', 'Acc'};
    
    for iStat = 1 : length(stats)
        disp(stats{iStat})
        tabulate(DataStruct(iPtpnt).(stats{iStat}))
    end
    
    
    % Plots some histograms of some stats
    figure
    stats = {'RT'};
    for iStat = 1 : length(stats)
        histogram(DataStruct(iPtpnt).(stats{iStat}), 60)
        title(stats{iStat})
    end
    
    
    % Make some plots of the timestamps
    stats = {'RtAbs', 'FixFlipTime', 'StimulusOnset'};
    figure; hold on
    for iStat = 1 : length(stats)
        plot(DataStruct(iPtpnt).(stats{iStat}))
    end
    legend(stats{:})
    
    
    %% Timing
    
    % Look at discrepancies between measures of the same screen flip
    if any((DataStruct(iPtpnt).FixFlipEnd - DataStruct(iPtpnt).FixFlipTime) < 0); error('Bug'); end
    if any((DataStruct(iPtpnt).FixTimeMes2 - DataStruct(iPtpnt).FixFlipEnd) < 0); error('Bug'); end
    if any((DataStruct(iPtpnt).StimFlipEnd - DataStruct(iPtpnt).StimFlipTime) < 0); error('Bug'); end
    if any((DataStruct(iPtpnt).StimClearFlipEnd - DataStruct(iPtpnt).StimClearFlipTime) < 0); error('Bug'); end
    
    disp('Max timing discrepancies.')
    disp(['Fixation onset......' ...
        num2str(max(DataStruct(iPtpnt).FixTimeMes2 - DataStruct(iPtpnt).FixFlipTime))])
    disp(['Stimulus onset......' ...
        num2str(max([DataStruct(iPtpnt).StimFlipEnd - DataStruct(iPtpnt).StimFlipTime]))])
    disp(['Stimulus clear......' ...
        num2str(max([DataStruct(iPtpnt).StimClearFlipEnd - DataStruct(iPtpnt).StimClearFlipTime]))])
    
    
    % Look at timing of events relative to their planned timing
    figure
    histogram(DataStruct(iPtpnt).StimFlipTime - 0.5)
    title('Stim flip relative to requested')
    
    figure
    histogram(DataStruct(iPtpnt).StimClearFlipTime - DataStruct(iPtpnt).StimFlipTime)
    title('Stim duration')

    
    %% Trial by trial checks
    
    % Loop through the trials and check things
    for iTrial = 1 : length(DataStruct(iPtpnt).Target)
        
        % If target is present it has a location and vica verca
        if (DataStruct(iPtpnt).Target(iTrial) == 1) ...
                && isnan(DataStruct(iPtpnt).TargetLoc(iTrial))
            error('Bug')
        end
        
        if (DataStruct(iPtpnt).Target(iTrial) == 0) ...
                && ~isnan(DataStruct(iPtpnt).TargetLoc(iTrial)) 
            error('Bug')
        end
        
        % Set size equals the recorded number of orientations
        if DataStruct(iPtpnt).SetSize(iTrial) ~= ...
                sum(~isnan(DataStruct(iPtpnt).Orientation(iTrial, :) ))    
            error('Bug')
        end
        
        targetOrientation = pi/2;
        if (DataStruct(iPtpnt).Target(iTrial) == 1) && ...
                ~(sum(DataStruct(iPtpnt).Orientation(iTrial, :) == ...
                targetOrientation) == 1)
            error('Bug')
        end

        if (DataStruct(iPtpnt).Target(iTrial) == 0) && ...
                ~(sum(DataStruct(iPtpnt).Orientation(iTrial, :) == ...
                targetOrientation) == 0)
            error('Bug')
        end
        
        % Check timings are possible!
        if DataStruct(iPtpnt).RT(iTrial) < 0; error('Bug'); end
        if DataStruct(iPtpnt).RT(iTrial) < 0.05
            warning('Very fast trial')
        end
        
        if DataStruct(iPtpnt).TrialDuration(iTrial) > ...
                (DataStruct(iPtpnt).RT(iTrial) + 4)    
            error('Bug')
        end
        
        % Check the logic of the response/accuracy mapping
        if (DataStruct(iPtpnt).Target(iTrial) == DataStruct(iPtpnt).Resp(iTrial)) && ...
                ~(DataStruct(iPtpnt).Acc(iTrial) == 1)
            error('Bug')
        end
        
        
        if (DataStruct(iPtpnt).Target(iTrial) ~= DataStruct(iPtpnt).Resp(iTrial)) && ...
                ~(DataStruct(iPtpnt).Acc(iTrial) == 0)
            error('Bug')
        end
        
    end
    
end


