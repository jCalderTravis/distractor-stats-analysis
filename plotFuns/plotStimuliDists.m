function fig = plotStimuliDists
% Plot the distibtion of stimuli in the two distractor environments for use in
% the figure for the experiment method.

kappaSVals = [0, 1.5];
colours = {[0 0 0], [0 0 0]};

for iPlot = [1, 2]
    subplot(1, 2, iPlot)
    
    startRange = -pi;
    endRange = pi;
    
    theta = startRange : 0.001 : endRange;
    prob = circ_vmpdf(theta, 0, kappaSVals(iPlot));
    
    plt = plot(theta, prob);
    
    xlim([startRange, endRange])
    xticks([startRange, 0, endRange])
    xticklabels({'-90', '0', '90'})
    xlabel('Degrees from target')
    
    ylim([0, 0.5])
    yticks([])
    ylabel({'Probability', 'density'})
    
    plt.LineWidth = 1;
    plt.Color = colours{iPlot}/255;
    
    ax = gca;
    ax.Box = 'off';
    ax.FontName ='Arial';
    ax.FontSize = 10;
    ax.LineWidth = 1;
    set(gca,'TickDir','out');
end

fig = gcf;



