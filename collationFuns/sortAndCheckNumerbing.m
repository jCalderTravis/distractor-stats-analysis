function sorted = sortAndCheckNumerbing(numbers)
% Sorts numbers, performs some checks and returns if OK

assert(isa(numbers, 'double'))
assert(isvector(numbers))
assert(~any(isnan(numbers)))

sorted = sort(numbers(:));

% Check numbering of participants
if any(diff(sorted)~=1)
    error('Participants numbered with gaps')
elseif length(unique(sorted)) ~= length(sorted)
    error('Duplicate entries')
end