function logBesseliVals = computeLogBesseliForDuplicatedValues(vals)
% Compute log of besseli of order zero. Useful when vals contains many duplicated
% values. In this case compuation may be sped up by this function. 

uniqueVals = unique(vals);
uniqueResults = log(besseli(0, uniqueVals));

logBesseliVals = NaN(size(vals));

for iVal = 1 : length(uniqueVals)    
    logBesseliVals(vals == uniqueVals(iVal)) = uniqueResults(iVal);
end