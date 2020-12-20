function compareVmAndNorm(kappa)
% Plot the von Mises together with an approximation of the von Mises using a
% normal distribution.

x = -pi : 0.0001 : pi;
% But we need to go beyond -pi and pi when calculating the probability density
% function for a wrapped normal distribution...
x2 = repmat(x, 11, 1);
offset = -10*pi : 2*pi : 10*pi;
x2 = x2 + offset';

sigma = convertKappaToSigma(kappa);

y1 = circ_vmpdf(x, 0, kappa);
y2 = sum(normpdf(x2, 0, sigma));

figure; hold on
plot(x, y1)
plot(x, y2)
