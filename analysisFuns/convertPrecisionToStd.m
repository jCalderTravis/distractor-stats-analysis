function SD = convertPrecisionToStd(J)
% Converts the Fisher information, J, of the von Mises distirbution, to the
% standard deviation parameter of a similar wrapped normal in degrees

% First convert J, to concentration parameter of the von Mises, k
eqToSolve = @(kappa) precisionFromKappa(kappa) - J;

kappa = fzero(eqToSolve, [0, 100]);

SD = rad2deg(convertKappaToSigma(kappa));

end


function J = precisionFromKappa(kappa)
% Taken from eq.5 of Mazyar et al. (2012), Does precision decrease with set size?

J = kappa .* (besseli(1, kappa) ./ besseli(0, kappa));

end