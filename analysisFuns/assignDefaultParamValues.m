function Params = assignDefaultParamValues(ModelName)
% Assign some default values to all the parameters in the model ready for a
% simulation. Parameters are produced in the 'unpacked' form (see 
% modellingTools repository README).

% INPUT
% ModelName: One of the "model name" structures produced by enumerateModels


% All models use kappa_x, but how many values of kappa_x depends on the model
if strcmp(ModelName.SetSizePrec, 'variable')
    logKappaX = log([ 2 3 4 5 ]');
    logKappaX = logKappaX + (0.2 * randn); % Add randomness to parameter selection
    Params.Kappa_x = exp(logKappaX);
    
elseif strcmp(ModelName.SetSizePrec, 'fixed')
    logKappaX = log(3.5) + (0.2 * randn);
    Params.Kappa_x = exp(logKappaX);
    
end


% The 'min' inference model also uses thresholds. The number of these depends on
% whether the observer uses different thresholds for different set sizes and
% block types.
if strcmp(ModelName.Inference, 'min')
    if strcmp(ModelName.SetSizeThresh, 'variable')
        Params.Thresh = [4*pi/16 : -pi/16 : pi/16]';
        Params.Thresh = Params.Thresh - (pi/32) + ((pi/16)*rand(1));
        
    elseif strcmp(ModelName.SetSizeThresh, 'fixed')
        Params.Thresh = 2*pi/16;
        Params.Thresh = Params.Thresh - (2*pi/32) + ((2*pi/16)*rand(1));
    end
    
    if strcmp(ModelName.BlockTypes, 'use')
        Params.Thresh = ...
            [Params.Thresh, (Params.Thresh - (pi/32))];
    end
    
    assert(all(Params.Thresh(:)>0))
    assert(all(Params.Thresh(:)<pi))
end


% Are lapses being modelled?
if strcmp(ModelName.Lapses, 'yes')    
    Params.LapseRate = 0.15;
    Params.LapseRate = Params.LapseRate - 0.1 + (0.2 * rand(1));
end


% The Bayesian model has some parameters unique to it
if strcmp(ModelName.Inference, 'bayes')
    
    % Does the observer use the true prior?
    if strcmp(ModelName.Prior, 'biased')
        Params.ObserverPrior = 0.65;
        Params.ObserverPrior = Params.ObserverPrior - 0.3 + (0.6 * rand(1));
    end
    
    % Does the observer use the true kappa_s?
    if strcmp(ModelName.BlockTypes, 'ignore')
        Params.ObserverKappaS = 0.5;
        Params.ObserverKappaS = Params.ObserverKappaS - 0.25 + (2 * rand(1));
    end
end
