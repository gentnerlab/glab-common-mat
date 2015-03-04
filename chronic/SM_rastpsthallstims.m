function SM_rastpsthallstims(units)


for unitnum = 1:length(units)
    CU = units(unitnum);
    
    axstart = -1;
    axstop = 6;
    
    numstims = size(CU.stims,1);
    figure
    for i = 1:numstims
        axR(i) = subaxis(numstims*2,1,i*2-1,'SpacingVert',0,'MR',0);
        %    ax = subplot(numstims*2,1,i*2-1);
        %    ax = subplot(numstims,1,i);
        SM_plot_rast(CU.trials(CU.stims{i,2},:),'ax',axR(i));
        if i ~= numstims
            xlabel('')
            set(axR(i),'xtick',[]);
        end
        ylabel('');
        axrangeX(axstart,axstop)
        v=axis;
        axis([v(1) v(2) v(3) v(4)+1 ]);
        text(4,v(4)-0.5,CU.stims{i,1})
        
        
        axP(i) = subaxis(numstims*2,1,i*2,'SpacingVert',0,'MR',0);
        %     ax = subplot(numstims*2,1,i*2)
        [ax,psth,xbins,ymax(i)] = SM_plot_psth(CU.trials(CU.stims{i,2},:),'ax',axP(i),'smoothmethod','ma','smoothparam',10);
        axrangeX(axstart,axstop)
        ylabel('');
        xlabel('');
        set(axP(i),'xtick',[]);
        set(axP(i),'ytick',[]);
        
    end
    
        suplabel(sprintf('marker: %d (max: %4.2f)',CU.marker,max(ymax)),'t');

        
    for i = 1:numstims
        axes(axP(i));
        axmaxY(max(ymax));
    end
    
    

end

end