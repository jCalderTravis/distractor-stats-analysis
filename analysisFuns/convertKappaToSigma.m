function sigma = convertKappaToSigma(kappa)
% Convert the concentration parameter of a von Mises distribution to the
% standard deviation of closely matching wrapped normal. Mapping from
% Stephens (1963) Random Walk on a Circle.

% NOTE 
% This function produces the standard deviation of a closely matched wrapped
% normal. In the paper we then halved this value to get an approximate value for
% standard deviation in physical degrees. We did this because Gabor orientation 
% is rerpesented  in a circular space which, in physcial space, only corresponds 
% to -90 to 90 degrees. Therefore this function does not quite reporduce the 
% sigma values reported in the paper. For this, the output of this function 
% needs to be halved.

% TESTING 
% Pass 'test' as the argument to run a test of the function instead.

if strcmp(kappa, 'test')
   funTest() 
   return
end

sigma = sqrt(-2*log(besseli(1, kappa)./besseli(0, kappa)));

end


function funTest()
    kappaVals =  [0.01, 0.2, 1, 2, 3, 5, 10, 50, 300];
    for kappa = kappaVals
        compareVmAndNorm(kappa)
    end
end

