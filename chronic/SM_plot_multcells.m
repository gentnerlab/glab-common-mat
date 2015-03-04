function SM_plot_multcells(desTrials,varargin)
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

numCells = length(desTrials);
numPlots = doSpect + dorast*numCells + dopsth*numCells;

SV = 0.002; %vertical Spacing (between plots)
MR = 0.01; %right margin
ML = 0.05; %left Margin
MT = 0.01;  %top margin
MB = 0.01;  %bottom margin


AXspect = subaxis(numPlots,1,1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB); %spectrogram
if dorast == 1 && dopsth == 1
    for plotnum = 1:numCells
        AXrast(plotnum) = subaxis(numPlots,1,1+plotnum*2-1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
        AXpsth(plotnum) = subaxis(numPlots,1,1+plotnum*2,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB,'PB',0.005);
    end
elseif dorast + dopsth == 1 %either or, but not both
    for plotnum = 1:numCells
        AXrast(plotnum) = subaxis(numPlots,1,plotnum+1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
        AXpsth(plotnum) = subaxis(numPlots,1,plotnum+1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
    end
end

%% raster
if dorast == 1
    for cellNum = 1:numCells
        
        AX_curr = AXrast(cellNum);
        
        SM_plot_rast(desTrials{cellNum},'ax',AX_curr,'dotimeaxis',dotimeaxis,'start',start,'stop',stop,'linewidth',rastlinewidth)
        
%         ylabel(gca,{'trialnum'},'fontsize',18);
%         set(gca,'fontsize',18)
%         set(gca,'linewidth',2)
        
       
            xlabel('');
            ylabel('');
            set(AX_curr,'xtick',[]);
        
    end
end

%% psth
if dopsth == 1
    for cellNum = 1:numCells
        
        AX_curr = AXpsth(cellNum);
        
        smoothmeth = 'ma';
        smoothparam = 10;
        binsize = 20;
        dobar = 0;
        nolabels = 0;
        SM_plot_psth(desTrials{cellNum},'ax',AX_curr,'start',start,'stop',stop,'binsize',binsize,'smoothmethod',smoothmeth,'smoothparam',smoothparam,'dobar',dobar,'nolabels',nolabels,'linewidth',1);
                set(AX_curr,'xtick',[]);
                    xlabel('');
                    ylabel('');
%         xlabel({'seconds'},'fontsize',18);
%         ylabel(gca,{'sp/sec'},'fontsize',18)
%         set(gca,'fontsize',18)
%         set(gca,'linewidth',2)
    end
end



%% spectrogram
if ~isempty(stimtospect)
    AX_curr = AXspect;
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
        ylabel('');
        set(AX_curr,'xtick',[]);
    end
    
  %  set(gca,'yticklabel',{'0' '5' '10'})
%     ylabel(gca,{'freq(kHz)'},'fontsize',18)
%     set(gca,'fontsize',18)
%     set(gca,'linewidth',2)
end

end