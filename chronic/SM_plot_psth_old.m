function [psth,xbins,ymax] = SM_plot_psth_old(desTrials,varargin)
%[psthout,xbins,ymax] = SM_plot_psth(desTrials,varargin)
%
%


%% deal with varargin

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'ax','axis','axes'}
                ax = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'start'}
                start = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'stop'}
                stop = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'binsize'}
                binsize = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'smoothmethod'}
                smoothmethod = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'smoothparam'}
                smoothparam = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dobar'}
                dobar = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'doerr'}
                doerr = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'nolabels'}
                nolabels = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'legendnames'}
                legendnames = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
                case {'zeroreference'}
                zeroreference = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'linewidth'}
                linewidth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'ymax'}
                inymax = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'psthcolors','colors','color'}
                psthcolors = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'pstherrcolors','errcolors','errcolor'}
                pstherrcolors = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error(sprintf('don''t know what to do with input: %s',varargin{ind}));
        end
    end
    ind=ind+1;
end

%% deal with potential variables
if ischar(desTrials{1}) %if desTrials is itself just a cell array of trials, wrap it in a cell
    desTrials = {desTrials};
end
if ~exist('psthcolors','var')
    psthcolors = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5];
    pstherrcolors = [1 0.8 0.8; 0.8 0.8 1; 0.8 1 0.8; 1 0.8 1; 0.8 1 1; 1 0.9 0.9; 0.9 0.9 1; 0.9 1 0.9];
else
    if isempty(psthcolors) || size(psthcolors,2) ~= 3
        psthcolors = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5];
        pstherrcolors = [1 0.8 0.8; 0.8 0.8 1; 0.8 1 0.8; 1 0.8 1; 0.8 1 1; 1 0.9 0.9; 0.9 0.9 1; 0.9 1 0.9];
    end
end

if ~exist('pstherrcolors','var')
    pstherrcolors = [1 0.8 0.8; 0.8 0.8 1; 0.8 1 0.8; 1 0.8 1; 0.8 1 1; 1 0.9 0.9; 0.9 0.9 1; 0.9 1 0.9];
else
    if isempty(pstherrcolors) || size(pstherrcolors,2) ~= 3
        pstherrcolors = [1 0.8 0.8; 0.8 0.8 1; 0.8 1 0.8; 1 0.8 1; 0.8 1 1; 1 0.9 0.9; 0.9 0.9 1; 0.9 1 0.9];
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
    else
        axes(ax);
    end
    hold on
end
ranges = cell2mat(desTrials(:,5));
if ~exist('stop','var');stop = min(ranges(:,2));elseif isempty(stop); stop = min(ranges(:,2)); end;
if ~exist('start','var'); start = max(ranges(:,1)); elseif isempty(start); start = max(ranges(:,1)); end;
if ~exist('nolabels','var'); nolabels = 0; end
if ~exist('inymax','var'); inymax = 0; end;
if ~exist('dobar','var')
    if ~exist('smoothmethod','var') && ~exist('smoothparam','var')
        dobar = 1;
    elseif exist('smoothmethod','var') && ~exist('smoothparam','var')
        dobar = 0;
        smoothparam = 10;
    elseif ~exist('smoothmethod','var') && exist('smoothparam','var')
        dobar = 0;
        smoothmethod = 'ma';
    else
        dobar = 0;
    end
elseif exist('smoothmethod','var') || exist('smoothparam','var')
    if dobar ~= 0
        warning('both dobar and dosmooth were indicated by inputs - defaulting to dobar');
        dobar = 1;
        smoothmethod = '';
        smoothparam = [];
    end
end;
if ~exist('smoothmethod','var'); smoothmethod = 0; end;
if ~exist('binsize','var'); binsize = 20; end;
if ~exist('linewidth','var'); linewidth = 2; end;
if ~exist('doerr','var'); doerr = 0; end;
if ~exist('zeroreference','var'); zeroreference = '<'; end;

%% do the PSTHing

if doerr == 1
    [psth xbins psthC] = SM_getpsth(desTrials,start,stop,binsize,zeroreference);
else
    [psth xbins] = SM_getpsth(desTrials,start,stop,binsize,zeroreference);
end

%% do the smoothing

for dtNum = 1:length(desTrials)
    
    if dobar == 1
        bar(xbins,psth{dtNum},'facecolor',psthcolors(dtNum,:),'edgecolor',psthcolors(dtNum,:));
        if doerr == 1
            hold on
            h = errorbar(xbins,psth{dtNum},psth{dtNum}-psth_sem{dtNum},psth{dtNum}+psth_sem{dtNum},'color',psthcolors(dtNum,:),'linestyle','none','marker','none');%,'facecolor',psthcolors(dtNum,:),'edgecolor',psthcolors(dtNum,:))
            errorbar_tick(h,0); %gets rid of the errorbar cross bars
        end
    else
        if ~isempty(psth{dtNum})
            psth{dtNum} = SM_smooth_psth(psth{dtNum},xbins,smoothmethod,smoothparam);
            hold on
            %plot(xbins,psth{dtNum},'color',psthcolors(dtNum,:),'linewidth',linewidth);
            if doerr == 1
                hold on
                for repnum = 1:size(psthC{dtNum},1)
                    psthC{dtNum}(repnum,:) = SM_smooth_psth(psthC{dtNum}(repnum,:),xbins,smoothmethod,smoothparam);
                end
                bps = 1000/binsize;
                psth_std{dtNum} = std(psthC{dtNum})*bps;
                psth_sem{dtNum} = stderr(psthC{dtNum})*bps;
                %jbfill(xbins,psth{dtNum}'+psth_sem{dtNum},psth{dtNum}'-psth_sem{dtNum},psthcolors(dtNum,:),'none',1,.2);
            end
        end
    end
end


for dtNum = 1:length(desTrials)
    if ~isempty(psth{dtNum})
        if doerr == 1
            hold on
            jbfill(xbins,psth{dtNum}'+psth_sem{dtNum},psth{dtNum}'-psth_sem{dtNum},pstherrcolors(dtNum,:),'none',1,1);
            
            ymax = 1.1*max(psth{dtNum}'+psth_sem{dtNum});
            ymax = max(ymax,inymax);
            if ymax == 0
                ymax=1;
            end
            axis([min(xbins) max(xbins) 0 ymax]);
        else
            
            ymax = 1.1*max(psth{dtNum});
            ymax = max(ymax,inymax);
            if ymax == 0
                ymax=1;
            end
            inymax=ymax;
            axis([min(xbins) max(xbins) 0 ymax]);
        end
    end
end
for dtNum = 1:length(desTrials)
    if ~isempty(psth{dtNum})
        hold on
        plot(xbins,psth{dtNum},'color',psthcolors(dtNum,:),'linewidth',linewidth);
    end
end

if ~nolabels
    ylabel('Spikes/Second');
    xlabel('Seconds');
    if exist('legendnames','var')
        legend(legendnames,'location','best')
        legend('boxoff')
    end
    %title(sprintf('Subject: %s || Pen: %s || Site: %s || Unit: %d',Unit.subject,Unit.pen,Unit.site,Unit.marker),'Interpreter','none');
end



hold off

end
