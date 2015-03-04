function SM_plot_rast(desTrials,varargin)
%SM_rast(desTrials,varargin)
%
%old below
%s2rast5(desTrials{,doTimeAxis{,start{,stop{,ax{,rastcolors}}}}})
%
%desTrials      a cell array of a cell array of trials (as created by reads2mat or reads2chet)
%               each top level cell array will be considered as a different 'condition'
%               and be plotted with a different color
%
%start          the start time (in seconds before stim start)   default = -2
%               you may also supply a vector of values; one for each trial
%
%stop           the stop time (in seconds after stim start)     default = 12
%               you may also supply a vector of values; one for each trial
%
%doTimeAxis     0 = no time dependance of y axis (y axis is repnum)
%               1 = y axis is time of trial (in hours since midnight)
%               2 = y axis is arranged in order of trials (no absolute time)
%
%ax             should be axis handle, if don't want to provide ax, then pass 0
%
%rastcolors     nx3 array of RGB color specifiers to apply to the different conditions

%% deal with varargin

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'legend','legendnames','labels'}
                legendnames = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dotimeaxis','timeaxis'}
                doTimeAxis = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'start'}
                start = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'stop'}
                stop = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'ax','axis','axes'}
                ax = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'nolines','noendlines'}
                noLines = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'linewidth'}
                linewidth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'behavior'}
                behavior = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'unit'}
                unit = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'blocksize'}
                blocksize = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'behax','behavioraxes'}
                bax = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'rastcolors','colors','color'}
                rastcolors = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

%% deal with potential variables

if ischar(desTrials{1}) %if desTrials is itself just a cell array of trials, wrap it in a cell
    tmp = {desTrials};
    clear desTrials;
    desTrials = tmp;
end

if ~exist('rastcolors','var')
    rastcolors = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5];
else
    if isempty(rastcolors) || size(rastcolors,2) ~= 3
        rastcolors = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5];
    end
end

if ~exist('ax','var')
    figure;
    set(gcf, 'Position', [360 635 883 286]);
    ax = gca();
    hold on
else
    if ~ax
        figure;
        set(gcf, 'Position', [360 635 883 286]);
        ax = gca();
        hold on
    else
        axes(ax);
    end
end
hold on

if ~exist('stop','var')
    stop = 12;
elseif isempty(stop)
    stop = 12;
elseif length(stop) > 1
    if length(stop) < size(desTrials,1)
        error('if supplying multiple stop values, there must be one for each desTrial');
    end
end;

if ~exist('start','var')
    start = -2;
elseif isempty(start)
    start = -2;
elseif length(start) > 1
    if length(start) < size(desTrials,1)
        error('if supplying multiple start values, there must be one for each desTrial');
    end
end;

if ~exist('noLines','var')
    noLines = 0;
end

if ~exist('linewidth','var')
    linewidth = 1;
end

if ~exist('doTimeAxis','var')
    doTimeAxis = 0;
else
    if ~isempty(doTimeAxis)
        if doTimeAxis < 0 || doTimeAxis > 2
            fprintf(1,'doTimeAxis is wrong - fix it\n');
            return
        else
            if doTimeAxis == 1 %&& noLines ~= 1
                %TODO get good plusminuslines
                for conditionNum = 1 : length(desTrials)
                    mmax(conditionNum,:) = minmax([desTrials{conditionNum}{:,3}]);
                    numt(conditionNum) = size(desTrials{conditionNum},1);
                end
                yrange = (max(max(mmax))-min(min(mmax)))/(60*60);
                N = sum(numt);
                plusminuslines = (yrange/N)/2; %want this to be some percentage of the range of times...
            end
        end
    else
        doTimeAxis = 0;
    end
end;

if ~exist('behavior','var')
    if exist('blocksize','var')
        behavior = 'gng'; %default to gng
        warning('warning_notallbehaviorparametersset','defaulting to gng, because ''blocksize'' was provided but ''behavior'' was not')
        if ~exist('unit','var')
            error('if provide ''blocksize'', must also provide ''unit''')
        end
        if ~exist('bax','var')
            ax = subplot(1,10,[1 9]);
            hold on
            bax = subplot(1,10,10);
            hold on
        end
    end
else
    if ~exist('unit','var')
        error('if provide ''behavior'', must also provide ''unit''')
    end
    if ~exist('blocksize','var')
        blocksize = 50;
        if ~exist('bax','var')
            ax = subplot(1,10,[1 9]);
            hold on
            bax = subplot(1,10,10);
            hold on
        end
    else
        if ~exist('bax','var')
            ax = subplot(1,10,[1 9]);
            hold on
            bax = subplot(1,10,10);
            hold on
        end
    end
end;


%% get to business
numConditions = length(desTrials);
if numConditions > size(rastcolors,1)
    fprintf(1,'Too many conditions for the available colormap!\n');
    return
end

%get the behavioral data, if requested

if exist('behavior','var')
    behTrials = cell(numConditions,1);
    behaviorindex = NaN(numConditions,1);
    for conditionNum = 1 : numConditions
        [behTrials{conditionNum} behaviorindex(conditionNum) blocksize(conditionNum)] = SM_getBD(unit,'optype',behavior,'blocksize',blocksize);
    end
    behplot = [];
    ratplot = [];
    dprplot = [];
end

allrasttimes=[];
axes(ax);hold on;
if doTimeAxis == 2 %y axis = order of presentation
    orderedTrials={};
    conditionColors = [];
    for conditionNum = 1 : numConditions
        conditionColors = [conditionColors; repmat(conditionNum,size(desTrials{conditionNum},1),1)];
        orderedTrials = [orderedTrials ; desTrials{conditionNum}];
    end
    [trash,order] = sort(cell2mat(orderedTrials(:,3)));
    orderedTrials = orderedTrials(order,:);
    if length(start) > 1
        start = start(order);
        stop = stop(order);
    end
    conditionColors = conditionColors(order);
    torast = orderedTrials(:,10);
    torastTimeLimits = cell2mat(orderedTrials(:,5));
    torasttimes = cell2mat(orderedTrials(:,3))/(60*60);
    allrasttimes = torasttimes;
    for repNum = 1 : length(torast)
        if length(start) > 1
            mintime(repNum) = max(torastTimeLimits(repNum,1),start(repNum));
            maxtime(repNum) = min(torastTimeLimits(repNum,2),stop(repNum));
            windInds = torast{repNum} > mintime(repNum) &  torast{repNum} < maxtime(repNum);
            torastwindowed = torast{repNum}(windInds) - start(repNum); %reference the spike times to the start time
        else
            mintime = max(torastTimeLimits(repNum,1),start);
            maxtime = min(torastTimeLimits(repNum,2),stop);
            windInds = torast{repNum} > mintime &  torast{repNum} < maxtime;
            torastwindowed = torast{repNum}(windInds);
        end
        %plot(ax,torastwindowed,ones(size(torastwindowed,1))*repNum,'o','MarkerFaceColor',rastcolors(conditionColors(repNum),:),'MarkerEdgeColor','none','MarkerSize',3)
        
        for spikenum = 1:length(torastwindowed)
            line([torastwindowed(spikenum) torastwindowed(spikenum)],[repNum-0.45 repNum+0.45],'color',rastcolors(conditionColors(repNum),:),'linewidth',linewidth)
        end
        
        if ~noLines
            if length(start) > 1
            plot(ax,[mintime(repNum)-start(repNum) mintime(repNum)-start(repNum)],[repNum-0.5 repNum+0.5],'linewidth',2,'color','k');
            plot(ax,[maxtime(repNum)-start(repNum) maxtime(repNum)-start(repNum)],[repNum-0.5 repNum+0.5],'linewidth',2,'color','k');  
            else
            plot(ax,[mintime mintime],[repNum-0.5 repNum+0.5],'linewidth',2,'color','k');
            plot(ax,[maxtime maxtime],[repNum-0.5 repNum+0.5],'linewidth',2,'color','k');
            end
        end
        
        if exist('behavior','var')
            %find corresponding behTrial
            behTrialInd = find([behTrials{conditionNum}{:,3}] == orderedTrials{repNum,3}); %should give index of current trial
            if ~isempty(behTrialInd) %hopefully this is because you're on a non behavioral condition
                behplot = [behplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.gnginfo(1),repNum];
                ratplot = [ratplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.ratiocorrect,repNum];
                dprplot = [dprplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.dprime,repNum];
            else
            end
        end
        
    end
else
    totreps = 0;
    for conditionNum = 1 : numConditions
        torast{conditionNum} = desTrials{conditionNum}(:,10);
        torastTimeLimits{conditionNum} = cell2mat(desTrials{conditionNum}(:,5));
        torasttimes{conditionNum} = cell2mat(desTrials{conditionNum}(:,3))/(60*60);
        allrasttimes = [allrasttimes;torasttimes{conditionNum}];
        for repNum = 1 : length(torast{conditionNum})
            if length(start) > 1
                mintime(repNum) = max(torastTimeLimits{conditionNum}(repNum,1),start(repNum));
                maxtime(repNum) = min(torastTimeLimits{conditionNum}(repNum,2),stop(repNum));
                torastwindowed = torast{conditionNum}{repNum}(torast{conditionNum}{repNum} > mintime(repNum) &  torast{conditionNum}{repNum} < maxtime(repNum)) - start(repNum); %reference the spike times to the start time
            else
                mintime = max(torastTimeLimits{conditionNum}(repNum,1),start);
                maxtime = min(torastTimeLimits{conditionNum}(repNum,2),stop);
                torastwindowed = torast{conditionNum}{repNum}(torast{conditionNum}{repNum} > mintime &  torast{conditionNum}{repNum} < maxtime);
            end
            switch doTimeAxis
                case 0 %no time dependance
                    totreps = totreps+1;
                    %plot(ax,torastwindowed,ones(size(torastwindowed,1))*totreps,'o','MarkerFaceColor',rastcolors(conditionNum,:),'MarkerEdgeColor','none','MarkerSize',3)
                    
                    for spikenum = 1:length(torastwindowed)
                        line([torastwindowed(spikenum) torastwindowed(spikenum)],[totreps-0.45 totreps+0.45],'color',rastcolors(conditionNum,:),'linewidth',linewidth)
                    end
                    
                    if ~noLines
                        hold on
                        if length(start) > 1
                        plot(ax,[mintime(repNum)-start(repNum) mintime(repNum)-start(repNum)],[totreps-0.5 totreps+0.5],'linewidth',2,'color','k');
                        plot(ax,[maxtime(repNum)-start(repNum) maxtime(repNum)-start(repNum)],[totreps-0.5 totreps+0.5],'linewidth',2,'color','k');
                        else
                        plot(ax,[mintime mintime],[totreps-0.5 totreps+0.5],'linewidth',2,'color','k');
                        plot(ax,[maxtime maxtime],[totreps-0.5 totreps+0.5],'linewidth',2,'color','k');
                        end
                    end
                    
                    if exist('behavior','var')
                        %find corresponding behTrial
                        behTrialInd = find([behTrials{conditionNum}{:,3}] == desTrials{conditionNum}{repNum,3}); %should give index of current trial
                        if ~isempty(behTrialInd) %hopefully this is because you're on a non behavioral condition
                            behplot = [behplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.gnginfo(1),totreps];
                            ratplot = [ratplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.ratiocorrect,totreps];
                            dprplot = [dprplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.dprime,totreps];
                        else
                        end
                    end
                    
                    
                case 1 %y axis = absolute time
                    
                    %plot(ax,torastwindowed,ones(size(torastwindowed,1))*torasttimes{conditionNum}(repNum),'o','MarkerFaceColor',rastcolors(conditionNum,:),'MarkerEdgeColor','none','MarkerSize',3)
                    
                    for spikenum = 1:length(torastwindowed)
                        line([torastwindowed(spikenum) torastwindowed(spikenum)],[torasttimes{conditionNum}(repNum)-plusminuslines torasttimes{conditionNum}(repNum)+plusminuslines],'color',rastcolors(conditionNum,:),'linewidth',linewidth)
                    end
                    
                    if ~noLines
                        plot(ax,[mintime mintime],[torasttimes{conditionNum}(repNum)-plusminuslines torasttimes{conditionNum}(repNum)+plusminuslines],'linewidth',2,'color','k');
                        plot(ax,[maxtime maxtime],[torasttimes{conditionNum}(repNum)-plusminuslines torasttimes{conditionNum}(repNum)+plusminuslines],'linewidth',2,'color','k');
                    end
                    if exist('behavior','var')
                        %find corresponding behTrial
                        behTrialInd = find([behTrials{conditionNum}{:,3}] == desTrials{conditionNum}{repNum,3}); %should give index of current trial
                        if ~isempty(behTrialInd) %hopefully this is because you're on a non behavioral condition
                            behplot = [behplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.gnginfo(1),torasttimes{conditionNum}(repNum)];
                            ratplot = [ratplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.ratiocorrect,torasttimes{conditionNum}(repNum)];
                            dprplot = [dprplot;behTrials{conditionNum}{behTrialInd,behaviorindex(conditionNum)}.dprime,torasttimes{conditionNum}(repNum)];
                        else
                        end
                    end
            end
        end
    end
end

%% adjust view - time limits and labels
axes(ax);
axpos = get(gca(),'position');
axlims = axis();
hxl = xlabel('Seconds');
xlpos = get(hxl,'position');
if exist('legendnames','var')
    for textNum = 1 : length(legendnames)
        text(axlims(2)-(textNum/length(legendnames))*0.3*(axlims(2)-axlims(1)),xlpos(2),legendnames{textNum},'color',rastcolors(textNum,:));
    end
end
if length(start) > 1
    xmin = 0;
xmax = max(stop-start);
else
xmin = start;
xmax = stop;
end

switch doTimeAxis
    case 0 %no time dependance
        yrangemin = 0.5;
        yrangemax = totreps+0.5;
        axis([xmin xmax yrangemin yrangemax])
        ylabel('repetition # (unordered)')
    case 1 %y axis = absolute time
        mintime = min(min(allrasttimes));
        maxtime = max(max(allrasttimes));
        timerange = maxtime-mintime;
        yrangemin = mintime-0.05*timerange;
        yrangemax = maxtime+0.05*timerange;
        axis([xmin xmax yrangemin yrangemax])
        ylabel('hours since midnight')
    case 2 %y axis = order of presentation
        yrangemin = 0.5;
        yrangemax = size(orderedTrials,1)+0.5;
        axis([xmin xmax yrangemin yrangemax])
        ylabel('repetition # (in presentation order)')
end

if exist('bax','var');
    gnginfocolor = 'k';
    ratiocorrectcolor = 'r';
    axes(bax);
    behplot = behplot(~isnan(behplot(:,1)),:);
    plot(bax,behplot(:,1),behplot(:,2),gnginfocolor,'linewidth',3)
    ratplot = ratplot(~isnan(ratplot(:,1)),:);
    plot(bax,ratplot(:,1),ratplot(:,2),ratiocorrectcolor,'linewidth',2)
    
    axis([0 1 yrangemin yrangemax])
    xlabel('Gnginfo')
    set(gca(),'ytick',[]);
    baxpos = get(gca(),'position');
    set(bax,'position',[axpos(1)+axpos(3)+0.01 axpos(2) baxpos(3) axpos(4)]);
    %             legend({'gnginfo' 'ratcorr'},'location','eastoutside','orientation','vertical')
    %     [legend_h,object_h,plot_h,text_strings] = legend({'gnginfo' 'ratcorr'},'location','best','color','none');
    %     set(object_h(1),'color',gnginfocolor);
    %     set(object_h(2),'color',ratiocorrectcolor);
    %     legend('boxoff');
    yrange = (yrangemax-yrangemin);
    
    text(0.5,yrangemin+0.05*yrange,'gnginfo','color',gnginfocolor,'horizontalalignment','center');
    text(0.5,yrangemin+0.1*yrange,'ratcorr','color',ratiocorrectcolor,'horizontalalignment','center');
    hold on;
    doDprime = 0;
    if doDprime == 1
        dprcolor = 'g';
        bax2 = axes('Position',get(bax,'Position'),'XAxisLocation','top','Color','none','XColor','k','YColor','k');
        hold on
        dprplot = dprplot(~isnan(dprplot(:,1)),:);
        plot(bax2,dprplot(:,1),dprplot(:,2),dprcolor,'linewidth',2)
        if min(dprplot(:,1)) == max(dprplot(:,1))
            xl = min(dprplot(:,1))-0.1;
            xh = min(dprplot(:,1))+0.1;
        else
            xh = max(dprplot(:,1));
            xl = min(dprplot(:,1));
        end
        axis([xl xh yrangemin yrangemax])
        set(gca(),'ytick',[]);
        text(xl+(xh-xl)/2,yrangemin+0.15*yrange,'dprime','color',dprcolor,'horizontalalignment','center');
    end
end

end