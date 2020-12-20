function DSet = produceStandardFormatDSet(Spec)
% Produce a dataset in the standard format (described in the README to
% 'modellingTools' repository.

% INPUT
% Spec          Dataset specifications as a structure. With the following
%               fields...
%       NumPtpnt
%       TrialsPerCond
%                   Trials per condition and set size
%       SetSizes    Vector specifying the set sizes to simulate
%       Name        The name of the true model. Should use the same naming
%                   system as in 'enumerateModels'.
%       Params      Struct array specifying the parameters of the observer model,
%                   including measrement noise. (See 'findDefaultModelSettings'
%                   for a list of required parameters.) Can be a single strcture
%                   array, or a structure array as long as the number of
%                   participants to simulate with different parameters for each
%                   participant.
%       StatType    Old feature. Must provide 'circ' for circular statistics.
%       Kappa_s     Vector specifying the KappaS values to simulate. KappaS is
%                   the concetration parameter of the distractors. The number of
%                   values for Kappa_s determines the number of different block 
%                   types.


if length(Spec.Params) == 1
    uniqueParams = false;
elseif length(Spec.Params) == Spec.NumPtpnt
    uniqueParams = true;
end

if isfield(Spec, 'StatType') && ~strcmp(Spec.StatType, 'circ')
    error('Other options have been removed.')
end


SimParams = cell(Spec.NumPtpnt, 1);
for iPtpnt = 1 : Spec.NumPtpnt
    
    for iSetSize = 1 : length(Spec.SetSizes)
        for iBlockType = 1 : length(Spec.Kappa_s)
            distStats.mu_s = 0;
            distStats.kappa_s = Spec.Kappa_s(iBlockType);
            
            if uniqueParams
                theseParams = Spec.Params(iPtpnt);
            else
                theseParams = Spec.Params;
            end
            
            CurrentSim = simSingleCond(...
                Spec.Name, ...
                theseParams, ...
                Spec.TrialsPerCond, ...
                Spec.SetSizes(iSetSize), ...
                iSetSize, ...
                Spec.StatType, ...
                distStats, ...
                iBlockType);
    
            PtpntData(iBlockType, iSetSize) = CurrentSim;
            SimParams{iPtpnt} = theseParams;
            disp('Progress')
        end
    end
    
    % Combined all the data from the different conditions for this participant
    CombinedPtpntData = combineSingleParticipantData(PtpntData);
    
    % Trim any columns from the end of the orientation array that are just
    % NaNs
    while all(isnan(CombinedPtpntData.Raw.Orientation(:, end)))
        CombinedPtpntData.Raw.Orientation(:, end) = [];
    end
    
    Data(iPtpnt) = CombinedPtpntData;
end


% Convert to the standard data format
Spec = rmfield(Spec, 'Params');
DSet.SimSpec = Spec;
DSet.Spec.TimeUnit = 'none';
DSet.Spec.NumBlockTypes = length(Spec.Kappa_s);
DSet.Spec.SetSizes = Spec.SetSizes;

for iPtpnt = 1 : length(Data)
    DSet.P(iPtpnt).Data = Data(iPtpnt).Raw;
    DSet.P(iPtpnt).Sim.Params = SimParams{iPtpnt};    
end
    
    

    
    
    