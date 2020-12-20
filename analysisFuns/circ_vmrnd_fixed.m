function samples = circ_vmrnd_fixed(mu, kappa, shape)
% For kappa_s ~ 0, circ_vmrnd such does not reshape the output. Do the
% reshaping.

assert(isequal(size(mu), [1, 1]))
assert(isequal(size(kappa), [1, 1]))

samples = circ_vmrnd(mu, kappa, shape);

if kappa < 1e-6
    samples = reshape(samples, shape);    
end

if any(samples(:) > pi) || any(samples(:) < -pi)    
    error('Von Misses function is returning unexpected values')
end
