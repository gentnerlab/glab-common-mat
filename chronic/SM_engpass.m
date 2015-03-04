function EP = SM_engpass(Unit,stimID,varargin)
%EP = SM_engpass(Unit,stimID,varargin)
%
%varargin accepts:
%dorast
%dopsth
%dobar


%% deal with inputs


ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'dorast'}
                dorast = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dobar' 'doplot'}
                dobar = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'start'}
                start = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'stop'}
                stop = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dopsth'}
                dopsth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

if ~exist('dorast','var');  dorast = 0;	end
if ~exist('dopsth','var');  dopsth = 0;	end
if ~exist('dobar','var');   dobar = 0;  end
if ~exist('start','var');   start = -2; end
if ~exist('stop','var');    stop = 12;  end

if ~iscell(stimID)
    if ~ischar(stimID)
        stimname = Unit.stims{stimID,1}(1:end-3);
    else
        stimname = stimID;
        stimID = {stimID};
    end
else
    if length(stimID) > 1
        error('actpass does not allow multiple stimulus inputs')
    end
    stimname = stimID{1};
end

%% get trials of interet
passiveTrials = SM_picktrials(Unit,'stim',stimID,'cond',{'passive'});
engagedTrials = SM_picktrials(Unit,'stim',stimID,'cond',{'engaged'});

%% get firing rates of interest

[meanZ EP.passivedriv] = SM_getfiringrate(passiveTrials);
[meanZ EP.passivespon] = SM_getfiringrate(SM_picktrials(Unit,'stim',{'silence'}));

[meanZ EP.engageddriv] = SM_getfiringrate(engagedTrials);
[meanZ EP.engagedsponbefore] = SM_getfiringrate(engagedTrials,'startrange','ss-1.0');
[meanZ EP.engagedsponafter] = SM_getfiringrate(engagedTrials,'se+3.0','endrange');

%% concat firing rates for plot
allmean = [EP.passivespon.mean EP.passivedriv.mean EP.engagedsponafter.mean EP.engageddriv.mean];
allerrbar = [EP.passivespon.std EP.passivedriv.std EP.engagedsponafter.std EP.engageddriv.std];

%% do the plot(s)
numaxes = dobar+dorast+dopsth;

if numaxes > 0
    figure
    hold on
end

if dobar == 1
    if dopsth == 1 && dorast == 1
        barplotnum  = 3;
    elseif dorast == 1
        barplotnum  = 2;
    elseif dopsth == 1
        barplotnum  = 2;
    else
        barplotnum = 1;
    end
    
    subplot(numaxes,1,barplotnum)
    xlabels = {stimname};
    colors = [0.5,.5,1;0,0,.5;1,.25,.25;.5,0,0];
    xcatlabels = {'pass-spon';'pass-driv';'eng-sponAfter';'eng-driv'};
    handles = barweb(allmean, allerrbar, [], xlabels, sprintf('subject: %s  site: %s  cellmarker: %d stim: %s',Unit.subject,Unit.site,Unit.marker,stimname), [], 'meanFR(std)', colors, 'none', xcatlabels);
    
    ymin = min(allmean-allerrbar);
    ymax = max(allmean+allerrbar);
    yrange = max(allmean+allerrbar) - min(allmean-allerrbar);
    ymin = ymin-0.1*(yrange);
    ymax = ymax+0.1*(yrange);
    axis([0.5 1.5 0 ymax]);
end

if dorast == 1
    if dopsth == 1 && dobar == 1
        rastplotnum  = 1;
    elseif dobar == 1
        rastplotnum  = 1;
    elseif dopsth == 1
        rastplotnum  = 1;
    else
        rastplotnum = 1;
    end
    rastax = subplot(numaxes,1,rastplotnum);
    
    SM_plot_rast({engagedTrials,passiveTrials},'dotimeaxis',2,'legendnames',{'engaged' 'passive'},'ax',rastax,'start',start,'stop',stop);
end

if dopsth == 1
    if dobar == 1 && dorast == 1
        psthplotnum  = 2;
    elseif dobar == 1
        psthplotnum  = 1;
    elseif dorast == 1
        psthplotnum  = 2;
    else
        psthplotnum = 1;
    end
    psthax = subplot(numaxes,1,psthplotnum);
    
    SM_plot_psth({engagedTrials,passiveTrials},'smoothmethod','ma','smoothparam',10,'legendnames',{'engaged' 'passive'},'ax',psthax,'start',start,'stop',stop);
end

if numaxes > 0
    hold off
end

end



