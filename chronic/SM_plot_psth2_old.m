function [psth,xbins,ymax] = SM_plot_psth2_old(desTrials,varargin)
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
if ~exist('stop','var'); stop = 99; elseif isempty(stop); stop = 99; end;
if ~exist('start','var'); start = -99; elseif isempty(start); start = -99; end;
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
    [psth xbins psthC] = SM_getpsth2(desTrials{1},start,stop,binsize,zeroreference);
else
    [psth xbins] = SM_getpsth2(desTrials{1},start,stop,binsize,zeroreference);
end

%% do the smoothing

    
    if dobar == 1
        bar(xbins,psth,'facecolor',psthcolors(1,:),'edgecolor',psthcolors(1,:));
        if doerr == 1
            hold on
            h = errorbar(xbins,psth,psth-psth_sem,psth+psth_sem,'color',psthcolors(1,:),'linestyle','none','marker','none');%,'facecolor',psthcolors(1,:),'edgecolor',psthcolors(1,:))
            errorbar_tick(h,0); %gets rid of the errorbar cross bars
        end
    else
        if ~isempty(psth)
            psth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam);
            hold on
            %plot(xbins,psth,'color',psthcolors(1,:),'linewidth',linewidth);
            if doerr == 1
                hold on
                for repnum = 1:size(psthC,1)
                    psthC(repnum,:) = SM_smooth_psth(psthC(repnum,:),xbins,smoothmethod,smoothparam);
                end
                bps = 1000/binsize;
                psth_std = std(psthC)*bps;
                psth_sem = stderr(psthC)*bps;
                %jbfill(xbins,psth'+psth_sem,psth'-psth_sem,psthcolors(1,:),'none',1,.2);
            end
        end
    end



    if ~isempty(psth)
        if doerr == 1
            hold on
            jbfill(xbins,psth'+psth_sem,psth'-psth_sem,pstherrcolors(1,:),'none',1,1);
            
            ymax = 1.1*max(psth'+psth_sem);
            ymax = max(ymax,inymax);
            if ymax == 0
                ymax=1;
            end
            axis([min(xbins) max(xbins) 0 ymax]);
        else
            
            ymax = 1.1*max(psth);
            ymax = max(ymax,inymax);
            if ymax == 0
                ymax=1;
            end
            inymax=ymax;
            axis([min(xbins) max(xbins) 0 ymax]);
        end
    end

    if ~isempty(psth)
        hold on
        plot(xbins,psth,'color',psthcolors(1,:),'linewidth',linewidth);
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
