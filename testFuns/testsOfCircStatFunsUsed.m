function testsOfCircStatFunsUsed()
% Tests for consistently amoung various functions used

mu = -pi : 0.2 : pi;
logKappa =  -9 : 0.1 : 9;
kappa = 1.3.^logKappa;
noise = 0 : 0.1 : 2*pi;


% Test of mean
estMu = nan(size(mu));
for i = 1 : length(mu)
    samples = circ_vmrnd(0, 4, 2000) + mu(i);
    estMu(i) = circ_mean(samples);
end
figure; scatter(mu, estMu)
refline(1, 0)


% Test 2 of mean
estMu = nan(size(mu));
for i = 1 : length(mu)
    samples = circ_vmrnd(mu(i), 4, 2000);
    estMu(i) = circ_mean(samples);
end
figure; scatter(mu, estMu)
refline(1, 0)


% Test 3 of mean
muMat = repmat(mu, 2000, 1);
assert(size(muMat, 1)==2000)
samples = qrandvm(muMat, 4, size(muMat));
figure; scatter(circ_mean(muMat, [], 1), circ_mean(samples, [], 1))
refline(1, 0)


% Test 4 of mean
muMat = repmat(mu', 1, 2000);
assert(size(muMat, 2)==2000)
samples = qrandvm(muMat, 4, size(muMat));
figure; scatter(circ_mean(muMat, [], 2), circ_mean(samples, [], 2))
refline(1, 0)


% Test of variance
estVar = nan(size(kappa));
intendedVar = 1 - (besseli(1, kappa)./besseli(0, kappa));
for i = 1 : length(kappa)
    samples = circ_vmrnd(0, kappa(i), 2000);
    estVar(i) = circ_var(samples);
end
figure; scatter(intendedVar, estVar)
refline(1, 0)


% Test of correlation
estCorr = nan(size(noise));
for i = 1 : length(noise)
    samples = circ_vmrnd(0, 4, 2000);
    noisySamples = samples + (noise(i) .* randn(size(samples)));
    estCorr(i) = circ_corrcc(samples, noisySamples);
end
figure; scatter(noise, estCorr)
