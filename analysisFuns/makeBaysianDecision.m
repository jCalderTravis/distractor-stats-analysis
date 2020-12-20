function response = makeBaysianDecision(percept, nItems, kappa_x, kappa_s, ...
    mu_s, prior)
% Make the decision of a Bayesian observer

% INPUT
% percept   [numTrials x setSize x numSamples] array of stimulus percepts
% nItems
% kappa_x   Observer's belief about the concetration parameter of the 
%           measurement noise
% kappa_s   Overserver's belief about the concentration parameter of the 
%           distractor distribution
% mu_s      Center of the distractor distribution. Note function only works for 
%           mu_s == 0
% prior     Observer's prior

% NOTE
% I have only focussed on making the code efficient for when mu_s==0. Lots
% of the same tricks could be used for when this is not the case but they
% have not been implimented.

% Joshua Calder-Travis 
% j.calder.travis@gmail.com
% GitHub: jCalderTravis


% Check input
if ~isequal(size(mu_s), [1, 1]); error('Function doesn''t cover this case'); end
if mu_s ~= 0; error('Function only works for mu_s = 0'); end
if size(percept, 2) > 8; error('Bug'); end

% We use implicit expansion below so it is very important that all input
% vectors are the expected shape.
inputVectors = {nItems, kappa_s, kappa_x, prior};

for iInputVec = 1 : length(inputVectors)    
    vecSize = size(inputVectors{iInputVec});

    if (length(vecSize) ~= 2) || (vecSize(2) ~= 1)
        error('Bug')
    end 
end


% If kappa_s is passed as a single value, expand it into a vector so that
% the calculations for 'termC' below, work.
if size(kappa_s, 1) == 1
    kappa_s = repmat(kappa_s, size(percept, 1), 1);
end

% Same for kappa_x
if size(kappa_x, 1) == 1
    kappa_x = repmat(kappa_x, size(percept, 1), 1);
end


% Do some computations to speed up the loglikelihood calculation later
termA = computeLogBesseliForDuplicatedValues(kappa_s);
termB = cos(percept);

% If kappa_s == 0, then there is a whole term we do not need to calculate.
% Only calculate it when kappa_s ~= 0
termC = NaN(size(percept));
calcTrials = kappa_s ~= 0;

trialTermC = log(besseli(0, kappa_x(~calcTrials)));
termC(~calcTrials, :, :) = repmat(trialTermC, ...
    1, size(percept, 2), size(percept, 3));

if sum(calcTrials) > 0
    termC(calcTrials, :, :) = log(besseli(0, ( (kappa_x(calcTrials).^2) + ...
        (kappa_s(calcTrials).^2) + ...
        (2*kappa_x(calcTrials).*kappa_s(calcTrials).* ...
        termB(calcTrials, :, :)) ).^0.5 ) );
end

d_loc = (kappa_x .* termB) + termA - termC;


% Compute overal loglikelihood ratio that target is present vs. absent
d = log( (1./nItems) .* nansum(exp(d_loc), 2) );

% Compute the log prior ratio
lPrior = log( ((1/prior) -1)^(-1) );

% If d is greater than the negative log prior respond that target is present
response = d > -lPrior;

assert(isequal(size(response), [size(percept, 1), 1, size(percept, 3)]) || ...
    isequal(size(response), [size(percept, 1), 1]))

