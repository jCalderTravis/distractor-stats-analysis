function trialLL = vS_computeTrialLL(Model, nDraws, sampleShortcut, ...
    ParamStruct, Data, ~, varargin)
% Computes the loglikelihood for the trials passed to it. Complies with the
% specification required for the modellingTools submodule. See README there, 
% and specifically the description of 'Settings.ComputTrialLL' for more info.

% INPUTS
% Model     One of the models produced by enumerateModels
% nDraws    How many times to simulate a response for each trial. These
%           responses will then be used to estimate the likelihood.
% sampleShortcut
%           Instead of sampling from the von Mises, draw a limited
%           number of samples for each level of observer precision and
%           then just sample from these. Currently only works when SetSizePrec 
%           is 'variable'.
% ParamStruct
%           Structure containing a field for each fitted parameter.
% Data      Strcuture containing field for each feature of the
%           stimulus/behaviour. Fields contain arrays which are num trials long,
%           along the first dimention.
% varargin  Leave empty, or specify 'unitTest', to run giveResponseImp2 function
%           instead of giveResponse, so that outputs can be compared.

% OUTPUT
% trialLL   Log-likelihood for each trial as vector


if isempty(varargin)
    unitTest = false;
elseif strcmp(varargin{1}, 'unitTest')
    unitTest = true;
else
    error('Incorrect use of inputs.')
end

    
% Duplicate data along the third dimention, for the number of times want to
% simulate a response from each trial
duplicatedOrientations = repmat(Data.Orientation, 1, 1, nDraws);
 
% Make responses
if ~unitTest
    predictedResp = giveResponse(Model, ParamStruct, Data, ...
        duplicatedOrientations, sampleShortcut);
    
elseif unitTest
    disp('********** UNIT TEST ************')
    predictedResp = giveResponseImp2(Model, ParamStruct, Data, ...
        duplicatedOrientations);
end


% What are the likelihoods of the responses?
likelihoodYes = sum(predictedResp, 3)/size(predictedResp, 3);
assert(all(likelihoodYes(:) >= 0))
assert(all(likelihoodYes(:) <= 1))

% Due to using a finite number of draws, the estimated likelihood can be 0 or 1.
% Avoid taking the log of zero by constraining the likelihood to fall within 
% [(1/nDraws), 1 - (1/nDraws)]
upperLim = 1 - (1/nDraws);
lowerLim = 1/nDraws;
likelihoodYes(likelihoodYes > upperLim) = upperLim;
likelihoodYes(likelihoodYes < lowerLim) = lowerLim;
 
likelihoods = [1-likelihoodYes, likelihoodYes];

% What is the loglikelihood of the actual response
relevantLikelihood = sub2ind([size(likelihoods)], ...
    [1 : size(likelihoods, 1)]', ...
    (Data.Response +1));

trialLL = log(likelihoods(relevantLikelihood));

    
end


