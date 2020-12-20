function draw = drawUniformOnInterval(size, lower, upper, logScale)
% Draw arra of values from uniform distribution on the interval lower to upper.

% INPUT
% size: Vector. Size of the array to draw.
% logScale. Boolean. If true draw on uniform distribtuion, but only after taking 
% log of lower and upper input values. Return the drawn values, after 
% taking the exponent. 

originalUpper = upper;
originalLower = lower;

if logScale
    upper = log(upper);
    lower = log(lower);
end

assert(upper > lower)

range = upper - lower;
draw = lower + (rand(size)*range);

if logScale
   draw = exp(draw);
end

if any(draw(:) > originalUpper) || any(draw(:) < originalLower)
    error('bug')
end

end