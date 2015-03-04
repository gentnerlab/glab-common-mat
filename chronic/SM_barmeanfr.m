function SM_barmeanfr(units)

for unitID = 1:length(units)
    U = units(unitID);
    
    [meanrates datarates] = SM_summaryFR(U);
    figure;
    [fro,order] = sort(meanrates.stim,'descend');
    stds = [datarates.stim.std];
    rates = meanrates.stim(order);
    stds = stds(order);
    bar(meanrates.stim(order));
    set(gca,'xtick',[1:1:length(meanrates.stimnames)]);
    set(gca,'xticklabel',meanrates.stimnames(order));
    rotateticklabel(gca,70);
    hold on
    plot(1:length(rates),rates+stds,'linestyle','none','marker','.','markerfacecolor','k','markeredgecolor','k')
    plot(1:length(rates),rates-stds,'linestyle','none','marker','.','markerfacecolor','k','markeredgecolor','k')
    
    title(['markerid: ' num2str(U.marker) ' | maxFR: ' num2str(max(rates))]);
end

end