function produceParamTables(DSet, dir)
% Create and save various tables of parameter values

% INPUT
% dir: Directory where to save the resulting parameter tables


%% Table of parameter values, as fitted

% Need to convert some units first
TmpDSet = DSet;
ParamNames = struct();
for iP = 1 : length(TmpDSet.P)
    for iM = 1 : length(TmpDSet.P(iP).Models)
        
        CurrentParams = TmpDSet.P(iP).Models(iM).BestFit.Params;
        [CurrentParams, ParamNames] ...
            = convertParamsToAsFitted(CurrentParams, ParamNames);
        TmpDSet.P(iP).Models(iM).BestFit.Params = CurrentParams;
    end
end

mT_produceParamStats(TmpDSet, dir, [], ParamNames, 'AsFitted');


%% Table of fitted parameters, in easily interpretable form
% Need to convert some units first
TmpDSet = DSet;
ParamNames = struct();
for iP = 1 : length(TmpDSet.P)
    for iM = 1 : length(TmpDSet.P(iP).Models)
        
        CurrentParams = TmpDSet.P(iP).Models(iM).BestFit.Params;
        [CurrentParams, ParamNames] ...
            = convertParamsToInterpretable(CurrentParams, ParamNames);
        TmpDSet.P(iP).Models(iM).BestFit.Params = CurrentParams;
    end
end

mT_produceParamStats(TmpDSet, dir, [], ParamNames, 'Interpretable');


%% Param bounds, as fitted

AllParamBounds = mT_collectParamBounds(DSet);
BoundsAsFitted = AllParamBounds;
bounds = fieldnames(BoundsAsFitted);
ParamNames = [];
for iB = 1 : length(bounds)
    
    TheseBounds = BoundsAsFitted.(bounds{iB});
    [TheseBounds, TheseParamNames] ...
        = convertParamsToAsFitted(TheseBounds, struct());
    BoundsAsFitted.(bounds{iB}) = TheseBounds;  
    
    if isempty(ParamNames)
        ParamNames = TheseParamNames;
    elseif ~isequal(ParamNames, TheseParamNames)
        error('Bug'); 
    end
end

mT_produceParamBoundsTable(BoundsAsFitted, dir, TheseParamNames, 'AsFitted')


%% Param bounds, in interpretable form

AllParamBounds = mT_collectParamBounds(DSet);
BoundsAsInterpret = AllParamBounds;
bounds = fieldnames(BoundsAsInterpret);
ParamNames = [];
for iB = 1 : length(bounds)
    
    TheseBounds = BoundsAsInterpret.(bounds{iB});
    [TheseBounds, TheseParamNames] ...
        = convertParamsToInterpretable(TheseBounds, struct());
    BoundsAsInterpret.(bounds{iB}) = TheseBounds;  
    
    if isempty(ParamNames)
        ParamNames = TheseParamNames;
    elseif ~isequal(ParamNames, TheseParamNames)
        error('Bug'); 
    end
end

% Some bounds will now need flipping upper to lower, because the transformed
% versions of these params go in the opposite directions to the originals
toFlip = {'Sigma_x', 'ObserverSigmaS'};
for iV = 1 : length(toFlip)
    oldLower = BoundsAsInterpret.LowerBound.(toFlip{iV});
    oldPLB = BoundsAsInterpret.PLB.(toFlip{iV});
    oldPUB = BoundsAsInterpret.PUB.(toFlip{iV});
    oldUpper = BoundsAsInterpret.UpperBound.(toFlip{iV});
    
    BoundsAsInterpret.LowerBound.(toFlip{iV}) = oldUpper;
    BoundsAsInterpret.PLB.(toFlip{iV}) = oldPUB;
    BoundsAsInterpret.PUB.(toFlip{iV}) = oldPLB;
    BoundsAsInterpret.UpperBound.(toFlip{iV}) = oldLower;
end

mT_produceParamBoundsTable(BoundsAsInterpret, dir, TheseParamNames, 'Interpretable')


end


function [ParamsStruct, ParamNames] = convertParamsToAsFitted( ...
    ParamsStruct, ParamNames)

assert(length(ParamsStruct)==1)

if isfield(ParamsStruct, 'Kappa_x')
    ParamsStruct.LnKappa_x = log(ParamsStruct.Kappa_x);
    ParamsStruct = rmfield(ParamsStruct, 'Kappa_x');
    ParamNames.LnKappa_x = '$\log \kappa$';
end

if isfield(ParamsStruct, 'Thresh')
    ParamsStruct.LnThresh = log(ParamsStruct.Thresh);
    ParamsStruct = rmfield(ParamsStruct, 'Thresh');
    ParamNames.LnThresh = '$\log \rho$';
end

% There isn't anything to do to some params, but we remove and re-add
% them so that this conversion operation does not change the order of
% params within the param structure.
if isfield(ParamsStruct, 'LapseRate')
    Tmp = ParamsStruct.LapseRate;
    ParamsStruct = rmfield(ParamsStruct, 'LapseRate');
    ParamsStruct.LapseRate = Tmp;
    ParamNames.LapseRate = '$\lambda$';
end

if isfield(ParamsStruct, 'ObserverPrior')
    Tmp = ParamsStruct.ObserverPrior;
    ParamsStruct = rmfield(ParamsStruct, 'ObserverPrior');
    ParamsStruct.ObserverPrior = Tmp;
    ParamNames.ObserverPrior = '$p_{present}$';
end

if isfield(ParamsStruct, 'ObserverKappaS')
    ParamsStruct.LnObserverKappaS = log(ParamsStruct.ObserverKappaS);
    ParamsStruct = rmfield(ParamsStruct, 'ObserverKappaS');
    ParamNames.LnObserverKappaS = '$\log \kappa_o$';
end

end


function [ParamsStruct, ParamNames] = convertParamsToInterpretable( ....
    ParamsStruct, ParamNames)

if isfield(ParamsStruct, 'Kappa_x')
    ParamsStruct.Sigma_x = rad2deg(convertKappaToSigma(ParamsStruct.Kappa_x)/2);
    ParamsStruct = rmfield(ParamsStruct, 'Kappa_x');
    ParamNames.Sigma_x = '$\sigma$';
end

if isfield(ParamsStruct, 'Thresh')
    ParamsStruct.Thresh_deg = rad2deg(ParamsStruct.Thresh)/2;
    ParamsStruct = rmfield(ParamsStruct, 'Thresh');
    ParamNames.Thresh_deg = '$\rho$';
end

% There isn't anything to do to some params, but we remove and re-add
% them so that this conversion operation does not change the order of
% params within the param structure.
if isfield(ParamsStruct, 'LapseRate')
    Tmp = ParamsStruct.LapseRate;
    ParamsStruct = rmfield(ParamsStruct, 'LapseRate');
    ParamsStruct.LapseRate = Tmp;
    ParamNames.LapseRate = '$\lambda$';
end

if isfield(ParamsStruct, 'ObserverPrior')
    Tmp = ParamsStruct.ObserverPrior;
    ParamsStruct = rmfield(ParamsStruct, 'ObserverPrior');
    ParamsStruct.ObserverPrior = Tmp;
    ParamNames.ObserverPrior = '$p_{present}$';
end

if isfield(ParamsStruct, 'ObserverKappaS')
    ParamsStruct.ObserverSigmaS ...
        = rad2deg(convertKappaToSigma(ParamsStruct.ObserverKappaS)/2);
    ParamsStruct = rmfield(ParamsStruct, 'ObserverKappaS');
    ParamNames.ObserverSigmaS = '$\sigma_o$';
end

end


