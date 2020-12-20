function allModels = enumerateModels(preset)
% Creates a cell array (vector) containing the names of all models. "Model
% names" are actually structures describing the properties of the models.

% INPUT
% preset: 'key' models only. Infernce type, and whether observer uses block type 
% are the only things varied. Leave empty for all models.

allModels = cell(32, 1);
binarySpecArray = dec2bin(1:32);
binarySpecArray(:, 1) = [];
binarySpecArray = sortrows(binarySpecArray);

for iModel = 1 : size(binarySpecArray, 1)
    Spec = struct();
    
    if strcmp(binarySpecArray(iModel, 1), '1')
        Spec.Inference = 'bayes';
    
        if strcmp(binarySpecArray(iModel, 2), '1')
            Spec.Prior = 'true';
        else
            Spec.Prior = 'biased';
        end
    else
        Spec.Inference = 'min'; 
        
        if strcmp(binarySpecArray(iModel, 2), '1')
            Spec.SetSizeThresh = 'variable';
        else
            Spec.SetSizeThresh = 'fixed';
        end
    end
    
    if strcmp(binarySpecArray(iModel, 3), '1')
        Spec.SetSizePrec = 'variable';
    else
        Spec.SetSizePrec = 'fixed';
    end
    
    if strcmp(binarySpecArray(iModel, 4), '1')
        Spec.Lapses = 'yes';
    else
        Spec.Lapses = 'no';
    end
    
    if strcmp(binarySpecArray(iModel, 5), '1')
        Spec.BlockTypes = 'ignore';
    else
        Spec.BlockTypes = 'use';
    end
    
    allModels{iModel, 1} = Spec;
end

% Check output
for iModel = 1 : (length(allModels)-1)
    for iCompareModel = (iModel+1) : length(allModels)
        if isequal(allModels{iModel}, allModels{iCompareModel})
            error('Bug')
        end
    end
end

% Pick requested models
if nargin > 0 && strcmp(preset, 'key')
    allModels = allModels([23, 24, 15, 16]);
end
    
    
    
