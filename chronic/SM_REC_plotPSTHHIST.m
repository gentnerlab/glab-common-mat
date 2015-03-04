function SM_REC_plotPSTHHIST(filein)
%% plot psths G cells only

if ~exist('filein','var')

units = SM_reads2mat('D:\SpikeMatlabSwap\swap.mat');
else
    units = SM_reads2mat(filein);
end


for unitnum = 1:length(units)
    unit = units(unitnum);
    
        %% plothist
    
    [meanrates datarates] = SM_summaryFR(unit);
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

title(['unitid: ' num2str(unit.marker)]);
    
    %% now plot psths
    
    figure
    set(gcf,'color','w');
    
    totnummots = size(unit.stims,1);
    
    for motnum = 1:totnummots
        
       
        
        trials = SM_picktrials(unit,'stim',motnum);
        
        desiredcolumns = 1;
        ncols = desiredcolumns;
        nrows = ceil(totnummots/desiredcolumns);
        
        subplot(nrows,ncols,motnum)
        ax(motnum) = gca;
        
        if ~isempty(trials)
            [ax(motnum) cm xbins] = SM_plot_psth(trials,'smoothmethod','ma','binsize',10,'doerr',1,'ax',ax(motnum),'color',[0 0 1],'errcolor',[0.8 0.8 1]);
        else
            p1=[];
            xbins = [];
        end

        if ~isempty(cm)
           if any(cm>0) 
            [ax(motnum),mmotmax(motnum)] = axmaxY(max(cm));
           else
               ax(motnum) = gca;
               mmotmax(motnum) = 0.1;
        end
        end
        
        cx = xbins(:);
        if ~isempty(cx)
            mmotmaxX(motnum) = max(cx);
            mmotminX(motnum) = min(cx);
        end
        
        %ylabel(unit.stims{motnum,1})
    end
    
    for motnum = 1:totnummots
        axes(ax(motnum));
        axmaxY(max(mmotmax));
        axmaxX(min(mmotmaxX));
        axminX(max(mmotminX));
        
        % set(gca,'ycolor','w');
        
        if motnum ~= 1
           ylabel('');
            xlabel('');
            set(gca,'xticklabel','','yticklabel','')
        else
            set(gca,'ytick',round(max(mmotmax)))
            xmin = (ceil(max(mmotminX)*10))/10;
            xmax = (floor(min(mmotmaxX)*10))/10;
            set(gca,'xtick',[xmin 0 xmax])
            set(gca,'xticklabel',[xmin 0 xmax])
           ylabel('sp/sec');
            xlabel('');
        end
        
        %         if motnum ~= totnummots
        %             ylabel('');
        %             xlabel('');
        %         end
        
        legend(unit.stims{motnum,1})
        legend boxoff
    end
    
%     fname = ['C:\Users\Dan\Documents\My Dropbox\20100800_KnudsenAdvancement\figs\psth_' num2str(unitnum)];
%     saveas(gcf,fname,'png');
    %export_fig(fname,'-png')
end

end
