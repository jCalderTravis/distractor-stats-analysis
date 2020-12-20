function plotLocalLogLikeliWithMeas()
% Plots the local log likelihood ratio as a function of the measured orientation,
% for a range of parameter values. Used in a figure to gain intuition for the
% Bayesian observer's decision rule.

kVals = exp([1, 2, 3]);
k_sVals = [0, 1.5];

figure; hold on
ax = gca;
plotLineWidth = 1;
ax.LineWidth = 1;
ax.FontSize = 10;
ax.TickDir = 'out';

x_i = 0 : 0.001 : pi;

for k = kVals
    for k_s = k_sVals
        plot(x_i, localLogLikeliRatio(x_i, k, k_s), ...
            'k', 'LineWidth', plotLineWidth)
    end
end

xticks([0])
yticks([])

xlabel('Measured orientation (x_i)')
ylabel('Local log-likelihood ratio (d_i)')

end

function d_i = localLogLikeliRatio(x_i, k, k_s)

term1 = k*cos(x_i);
numer = besseli(0, k_s);
denom = besseli(0, sqrt((k^2) + (k_s^2) + (2*k*k_s*cos(x_i))));

d_i = term1 + log(numer./denom);

assert(isequal(size(d_i), size(x_i)))

end


        