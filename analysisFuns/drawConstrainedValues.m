function theseVals = drawConstrainedValues(prodVals)
% Draw values until a draw where the values decend down the first axis

% INPUT
% prodVals: Function handle to function which accepts no arguments and produces
% an array of values.

successfulDraw = false;
while ~successfulDraw

    theseVals = prodVals();
    
    % Are the values in the right order?
    differences = diff(theseVals);
    assert(isequal(size(differences), [size(prodVals(), 1)-1, size(prodVals(), 2)]))
    
    if all(differences(:)<=0) 
        successfulDraw = true;
    end
end