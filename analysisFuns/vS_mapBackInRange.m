function x = vS_mapBackInRange(x, lowerLim, upperLim)
% Maps the variables in the array x, back into the range lowerLim, and
% upperLim, assuming that they are circular variables and that lowerLim and
% upperLim are at the same location on the circle.

% TESTING
% To run tests pass vS_mapBackInRange('test')

if strcmp(x, 'test')
    testFun()
    x = [];
    return
end
    

if lowerLim >= upperLim; error('incorrect use of inputs'); end

x = mod(x - lowerLim, upperLim - lowerLim) + lowerLim;

end

function testFun()
    initial = (rand(100000, 1)*2*pi) - pi;
    plusMultiple = initial + (randi(6, 100000, 1)*2*pi);
    minusMultiple = initial - (randi(6, 100000, 1)*2*pi);
    
    input = [plusMultiple; minusMultiple];
    expectedOut = [initial; initial];
    
    input = repmat(input, 1, 10);
    expectedOut = repmat(expectedOut, 1, 10);
    
    out = vS_mapBackInRange(input, -pi, pi);
    assert(isequal(round(out, 8), round(expectedOut, 8)))
    
    disp('vS_mapBackInRange passed 1 test')
end