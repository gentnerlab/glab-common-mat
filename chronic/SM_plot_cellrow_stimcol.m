function SM_plot_cellrow_stimcol(cells,stims,varargin)
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
            case {'linewidth'}
                rastlinewidth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dorast'}
                if length(varargin) == ind || ischar(varargin{ind+1})
                    dorast = 1;
                else
                    dorast = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                end
            case {'dopsth'}
                if length(varargin) == ind || ischar(varargin{ind+1})
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
            case {'comparison' 'compare'}
                comparison = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'unit'}
                Unit = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'doerr'}
                if length(varargin) == ind || ischar(varargin{ind+1})
                    doerr = 1;
                else
                    doerr = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                end
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

if ~exist('dorast','var') && ~exist('dopsth','var'); dorast = 1; dopsth = 1; end
if ~exist('dorast','var');      dorast = 0;             end
if ~exist('dopsth','var');      dopsth = 0;             end
if ~exist('dotimeaxis','var');	dotimeaxis = 2;         end
if ~exist('legendnames','var');	legendnames = {};       end
if exist('Unit','var');        	subject = Unit.subject;	end
if ~exist('start','var');       start = -2;             end
if ~exist('stop','var');        stop = 15;              end
if ~exist('rastlinewidth','var');   rastlinewidth = 1;  end
if ~exist('doerr','var');       doerr = 0;              end
if ~exist('comparison','var');  comparison = 'ep';      end

dataDir = fullfile(getdanroot(),'ChronRig',filesep());

%% set up figure with correct number/location of axes
fighand = figure();
%set(fighand,'visible','off');

doSpect = 1;

numCells = length(cells);
numStims = length(stims);
numPlots = numStims*(doSpect + dorast*numCells + dopsth*numCells);

SV = 0.001; %vertical Spacing (between plots)
SH = 0.002; %horizontal Spacing (between plots)
MR = 0.01; %right margin
ML = 0.05; %left Margin
MT = 0.01;  %top margin
MB = 0.01;  %bottom margin

colors = [1 0 0; 0 0 1; 0 1 0; 1 0 1; 0 1 1; 1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5];
errcolors = [1 0.7 0.7; 0.7 0.7 1; 0.7 1 0.7; 1 0.7 1; 0.7 1 1; 1 0.9 0.9; 0.9 0.9 1; 0.9 1 0.9];

nodatrast = ones(numStims,numCells);
nodatpsth = ones(numStims,numCells);

for stimNum = 1:numStims
    clear desTrials
    switch lower(comparison)
        case 'ep'
            for cellNum = 1:numCells
                desTrials{cellNum}{1} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'cond',{'engaged'});
                desTrials{cellNum}{2} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'cond',{'passive'});
            end
        case 'ft'
            for cellNum = 1:numCells
                desTrials{cellNum}{1} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'consequence','F');
                desTrials{cellNum}{2} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'consequence','T');
            end
            case 'epft'
            for cellNum = 1:numCells
                desTrials{cellNum}{1} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'cond',{'engaged'},'result','fF');
                desTrials{cellNum}{2} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'cond',{'engaged'},'result','tT');
                desTrials{cellNum}{3} = SM_picktrials(cells(cellNum),'stim',stims{stimNum},'cond',{'passive'});
                colors = [1 0 0; 1 .2 1; 0 0 1];
                errcolors = [1 0.7 0.7; 1 0.8 1; 0.7 0.7 1];
            end
    end
    
    
    AXspect(stimNum) = subaxis(numCells*2+1,numStims,stimNum,1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB); %spectrogram
    if dorast == 1 && dopsth == 1
        for cellNum = 1:numCells
            AXrast(stimNum,cellNum) = subaxis(numCells*2+1,numStims,stimNum,1+cellNum*2-1,'SV',0,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
            AXpsth(stimNum,cellNum) = subaxis(numCells*2+1,numStims,stimNum,1+cellNum*2,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB,'PB',0.005);
        end
    elseif dorast + dopsth == 1 %either or, but not both
        for cellNum = 1:numCells
            AXrast(stimNum,cellNum) = subaxis(numCells*2+1,numStims,stimNum,cellNum+1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
            AXpsth(stimNum,cellNum) = subaxis(numCells*2+1,numStims,stimNum,cellNum+1,'SV',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
        end
    end
    
    %% raster
    if dorast == 1
        for cellNum = 1:numCells
            
            
            AX_curr = AXrast(stimNum,cellNum);
            
            goodinds = ~cellfun('isempty' , desTrials{cellNum});
            if sum(goodinds) > 0
                nodatrast(stimNum,cellNum) = 0;
                SM_plot_rast(desTrials{cellNum}(goodinds),'ax',AX_curr,'dotimeaxis',dotimeaxis,'start',start,'stop',stop,'linewidth',rastlinewidth,'noendlines',1,'colors',colors(goodinds,:))
                %set(fighand,'visible','off');
                v = axis();
                rastxmin(stimNum,cellNum) = v(1);
                rastxmax(stimNum,cellNum) = v(2);
                rastymin(stimNum,cellNum) = v(3);
                rastymax(stimNum,cellNum) = v(4);
            else
                set(AXrast(stimNum,cellNum),'ytick',[]);
                set(AXrast(stimNum,cellNum),'ycolor','w')
            end
            
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
            
            AX_curr = AXpsth(stimNum,cellNum);
            
            smoothmeth = 'ma';
            smoothparam = 20;
            binsize = 20;
            dobar = 0;
            nolabels = 0;
            
            goodinds = ~cellfun('isempty' , desTrials{cellNum});
            if sum(goodinds) > 0
                nodatpsth(stimNum,cellNum) = 0;
                SM_plot_psth(desTrials{cellNum}(goodinds),'ax',AX_curr,'start',start,'stop',stop,'binsize',binsize,'smoothmethod',smoothmeth,'doerr',doerr,'smoothparam',smoothparam,'dobar',dobar,'nolabels',nolabels,'linewidth',1,'colors',colors(goodinds,:),'errcolors',errcolors(goodinds,:));
                %set(fighand,'visible','off');
                axis tight
                v = axis();
                psthxmin(stimNum,cellNum) = v(1);
                psthxmax(stimNum,cellNum) = v(2);
                psthymin(stimNum,cellNum) = v(3);
                psthymax(stimNum,cellNum) = v(4);
            else
                set(AXpsth(stimNum,cellNum),'ytick',[]);
                set(AXpsth(stimNum,cellNum),'ycolor','w')
            end
            if cellNum ~= numCells
            set(AX_curr,'xtick',[]);
            xlabel('');
            end
            ylabel('');
            %         xlabel({'seconds'},'fontsize',18);
            %         ylabel(gca,{'sp/sec'},'fontsize',18)
            %         set(gca,'fontsize',18)
            %         set(gca,'linewidth',2)
        end
    end
    
    
    
    %% spectrogram
    
    AX_curr = AXspect(stimNum);
    if numPlots == 1
        set(gcf, 'Position', [360 635 883 286]);
    end
    
    if exist('Unit','var')
        inwav = fixfilesep(fullfile(dataDir,subject,'stims',stims{stimNum},'_ramp.wav'));
    else
        inwav = fixfilesep(fullfile(dataDir,'stimlib',filesep(),sprintf('%s_ramp.wav',stims{stimNum})));
    end
    [Y,fs] = wavread(inwav);
    simplespect(Y,start,stop,fs,AX_curr);
    %set(fighand,'visible','off');
    nolabels = 0;
    if nolabels == 0
        if exist('Unit','var')
            title(sprintf('Subject: %s || Pen: %s || Site: %s || Unit: %d || Stim: %s',subject,Unit.pen,Unit.site,Unit.marker,stim(stimNum)),'Interpreter','none');
        end
    end
    
    %xlabel('');
    ylabel('');
    %set(AX_curr,'xtick',[]);
    set(AX_curr,'yticklabel','');
    
    %  set(gca,'yticklabel',{'0' '5' '10'})
    %     ylabel(gca,{'freq(kHz)'},'fontsize',18)
    %     set(gca,'fontsize',18)
    %     set(gca,'linewidth',2)
    
    
end

for stimNum = 1:numStims
    for cellNum = 1:numCells
        %deal with raster axes
        set(AXrast(stimNum,cellNum),'box','off');
        set(AXrast(stimNum,cellNum),'Xcolor','w')
        
        if ~nodatrast(stimNum,cellNum)
            if dotimeaxis ~= 1
            v = get(AXrast(stimNum,cellNum),'position');
            set(AXrast(stimNum,cellNum),'position',[v(1) v(2) v(3) v(4)*(rastymax(stimNum,cellNum)/max(max(rastymax)))]);
            set(AXrast(stimNum,cellNum),'ytick',floor(rastymax(stimNum,cellNum)));
        
            else
                v = get(AXrast(stimNum,cellNum),'position');
            set(AXrast(stimNum,cellNum),'position',[v(1) v(2) v(3)*(rastymin(stimNum,cellNum)/min(min(rastymin))) v(4)*(rastymax(stimNum,cellNum)/max(max(rastymax)))]);
            %set(AXrast(stimNum,cellNum),'ytick',[floor(rastymin(stimNum,cellNum)) floor(rastymax(stimNum,cellNum))]);
            end
        else
            % set(AXrast(stimNum,cellNum),'ytick',[]);
        end
        
        %deal with psth axes
        set(AXpsth(stimNum,cellNum),'box','off');
        set(AXpsth(stimNum,cellNum),'Xcolor','w')
        if ~nodatpsth(stimNum,cellNum)
            v = axis(AXpsth(stimNum,cellNum));
            axis(AXpsth(stimNum,cellNum),[v(1) v(2) 0 ceil(max(psthymax(:,cellNum)))]);
            set(AXpsth(stimNum,cellNum),'ytick',ceil(max(psthymax(:,cellNum))));
                
        else
            %set(AXpsth(stimNum,cellNum),'ytick',[]);
        end
    end
end

%set(fighand,'visible','on');

end