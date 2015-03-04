function SM_triplot(desTrials,varargin)
%SM_triplot(desTrials,varargin)
%
%Possible inputs:
%
%'DORAST'
%'DOPSTH'
%'START'
%'STOP'
%'STIMTOSPECT'
%'LINEWIDTH'
%'DOTIMEAXIS'
%'UNIT'

%% do varargin and potential variables

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'legend','legendnames','labels'}
                legendnames = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dotimeaxis','timeaxis'}
                dotimeaxis = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'stimtospect'}
                stimtospect = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'linewidth'}
                rastlinewidth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dorast'}
                if ischar(varargin{ind+1})
                    dorast = 1;
                else
                    dorast = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                end
            case {'dopsth'}
                if ischar(varargin{ind+1})
                    dopsth = 1;
                else
                    dorast = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                end
            case {'start'}
                start = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'stop'}
                stop = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'unit'}
                Unit = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

if ~exist('dorast','var') && ~exist('dopsth','var'); dorast = 1; dopsth = 1; end
if ~exist('dorast','var');      dorast = 0;             end
if ~exist('dopsth','var');      dopsth = 0;             end
if ~exist('stimtospect','var');	stimtospect = '';       end
if ~exist('dotimeaxis','var');	dotimeaxis = 2;         end
if ~exist('legendnames','var');	legendnames = {};       end
if exist('Unit','var');        	subject = Unit.subject;	end
if ~exist('start','var');       start = -2;             end
if ~exist('stop','var');        stop = 12;              end
if ~exist('rastlinewidth','var');   rastlinewidth = 1;  end

dataDir = fullfile(getdanroot(),'ChronRig',filesep());

%% set up figure with correct number/location of axes
figure
if ~isempty(stimtospect)
    doSpect = 1;
else
    doSpect = 0;
end

numPlots = doSpect + dorast + dopsth;
if numPlots == 3
    AX(1) = subplot(3,1,1);
    AX(2) = subplot(3,1,2);
    AX(3) = subplot(3,1,3);
elseif numPlots == 2
    AX(1) = subplot(2,1,1);
    AX(2) = subplot(2,1,2);
else
    AX(1) = subplot(1,1,1);
end

%% raster
if dorast == 1
    if numPlots == 1
        AX_curr = AX(1);
        nolabels = 0;
    elseif numPlots == 2
        if doSpect == 1
            AX_curr = AX(2);
            nolabels = 1;
        else
            AX_curr = AX(1);
            nolabels = 0;
        end
    elseif numPlots == 3
        AX_curr = AX(2);
        nolabels = 1;
    end
    
    SM_plot_rast(desTrials,'ax',AX_curr,'dotimeaxis',dotimeaxis,'start',start,'stop',stop,'linewidth',rastlinewidth)
    
    ylabel(gca,{'trialnum'},'fontsize',18);
    set(gca,'fontsize',18)
    set(gca,'linewidth',2)
    
    if dopsth == 1
        xlabel('');
        set(AX_curr,'xtick',[]);
    end
end

%% psth
if dopsth == 1
    if numPlots == 1
        AX_curr = AX(1);
        nolabels = 0;
    elseif numPlots == 2
        AX_curr = AX(2);
        nolabels = 1;
    else
        AX_curr = AX(3);
        nolabels = 1;
    end
    
    smoothmeth = 'ma';
    smoothparam = 10;
    binsize = 20;
    dobar = 0;
    nolabels = 0;
    SM_plot_psth(desTrials,'ax',AX_curr,'start',start,'stop',stop,'binsize',binsize,'smoothmethod',smoothmeth,'smoothparam',smoothparam,'dobar',dobar,'nolabels',nolabels);
    
    xlabel({'seconds'},'fontsize',18);
    ylabel(gca,{'sp/sec'},'fontsize',18)
    set(gca,'fontsize',18)
    set(gca,'linewidth',2)
end



%% spectrogram
if ~isempty(stimtospect)
    AX_curr = AX(1);
    if numPlots == 1
        set(gcf, 'Position', [360 635 883 286]);
    end
    
    if exist('Unit','var')
        inwav = fixfilesep(fullfile(dataDir,subject,'stims',stimtospect));
    else
        inwav = fixfilesep(fullfile(dataDir,'stimlib',filesep(),stimtospect));
    end
    [Y,fs] = wavread(inwav);
    simplespect(Y,start,stop,fs,AX_curr);
    nolabels = 0;
    if nolabels == 0
        if exist('Unit','var')
            title(sprintf('Subject: %s || Pen: %s || Site: %s || Unit: %d || Stim: %s',subject,Unit.pen,Unit.site,Unit.marker,stimtospect),'Interpreter','none');
        end
    end
    if numPlots > 1
        xlabel('');
        set(AX_curr,'xtick',[]);
    end
    
    set(gca,'yticklabel',{'0' '5' '10'})
    ylabel(gca,{'freq(kHz)'},'fontsize',18)
    set(gca,'fontsize',18)
    set(gca,'linewidth',2)
end

end