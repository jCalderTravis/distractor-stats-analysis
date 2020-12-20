function testGiveResponseFun(DSet)
% Test the giveResponse function by comparing it to a second implimentation. In
% the resulting plot the outcomes should be very highly correlated, indicating
% the two implimentations are producing the same results.

% INPUT
% DSet: A dataset to which models have already been fitted.

nDraws = 2000;
sampleShortcut = false;

for iP = 1 : length(DSet.P)
    for iM = 1 : length(DSet.P(iP).Models)
        Model = DSet.P(iP).Models(iM).Settings.ModelName;
        ParamStruct = DSet.P(iP).Models(iM).BestFit.Params;
        Data = DSet.P(iP).Data;
        
        trialLL_origin = vS_computeTrialLL(Model, nDraws, sampleShortcut, ...
            ParamStruct, Data, []);
        trialLL_test = vS_computeTrialLL(Model, nDraws, sampleShortcut, ...
            ParamStruct, Data, [], 'unitTest');
        
        figure
        scatter(trialLL_origin, trialLL_test)
        refline(1, 0)
        title(['Participant ' num2str(iP) '; model ' num2str(iM)])
    end
end
        

