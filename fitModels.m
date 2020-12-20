function DSet = fitModels(DSet, modelsToFit, mode, scheduleFolder, numPtpnts)
% Fit the visual search models to the data

% INPUT
% DSet      Standard data format
% modelsToFit   
%           'all' for all models, 'key' for key models, or, [num specifications] 
%           long cell array of model specifications. Each
%           specification should be a struct matching those prodced by
%           enumerateModels
% mode      'cluster', schedule for the cluster, or 'local' runs
%           straight away.
% scheduleFolder
%           Directory in which to save the files ready for the cluster
% numPtpnts Number of participants expected. This value is used as a check.

addpath('.\modellingTools')

if length(DSet.P)~=numPtpnts; error('Unexpected number of participants'); end


%% Modelling time

if ~any(strcmp(mode, {'cluster', 'local'})); error('Incorrect input'); end 

if strcmp(modelsToFit, 'all')
    modelsToFit = enumerateModels;
elseif strcmp(modelsToFit, 'key')
    modelsToFit = enumerateModels('key');
else
    % Nothing to do
end

for iModel = 1 : length(modelsToFit)
    ModelSettings(iModel) = findDefaultModelSettings(modelsToFit{iModel}, DSet); 
end

% We are all set...
if nargin > 3
    DSet = mT_scheduleFits(mode, DSet, ModelSettings, scheduleFolder);
else
    DSet = mT_scheduleFits(mode, DSet, ModelSettings);
end


end

