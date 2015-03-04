function [summarydata bystimdata handles] = SM_engvspass_all(unit,varargin)
%
%
%% deal with varargin, potential variable values

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'stims'}
                stims = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dosummaryplot' 'doplot' 'summaryfig' 'dosummaryfig'}
                dosummaryplot = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dorast'}
                dorast = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dopsth'}
                dopsth = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dobar'}
                dobar = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'dostd'}
                dostd = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error(sprintf('don''t know what to do with input: %s',varargin{ind}));
        end
    end
    ind=ind+1;
end

if ~exist('dorast','var'); dorast = 0;                  end
if ~exist('dopsth','var'); dopsth = 0;                  end
if ~exist('dobar','var'); dobar = 0;                    end
if ~exist('dosummaryplot','var'); dosummaryplot = 0;    end
if ~exist('dostd','var'); dostd = 1;                    end

if ~exist('stims','var') %we have to decide which stims were presented in both the engaged and passive cases
    engagedind = ismember(unit.conditions(:,1),'engaged');
    passiveind = ismember(unit.conditions(:,1),'passive');
    
    numsharedstims= 0;
    for stimID = 1:size(unit.stims,1)
        if any(unit.conditions{engagedind,2} & unit.stims{stimID,2}) && any((unit.conditions{passiveind,2} & unit.stims{stimID,2}))
            numsharedstims = numsharedstims+1;
            sharedStims(numsharedstims) = stimID;
            bystimdata(numsharedstims) = SM_engpass(unit,stimID,'dorast',dorast,'dopsth',dopsth,'dobar',dobar);
        end
    end
else %was given a list of shared stims
    for stimID = 1:length(stims)
        sharedStims(stimID) = stims(stimID);
        bystimdata(stimID) = SM_engpass(unit,stims(stimID),'dorast',dorast,'dopsth',dopsth,'dobar',dobar);
    end
end

%% concat across stims

summarydata.PS  = bystimdata(1).passivespon; %since passive spon is the same for each and every stim

for stimNum = 1:length(sharedStims)
    currStim = sharedStims(stimNum);
    bystimdata(stimNum).stimname = unit.stims{currStim,1};
    summarydata.stimname{stimNum,1} = unit.stims{currStim,1};
    
    summarydata.PD.all(stimNum) = bystimdata(stimNum).passivedriv.mean;
    
    summarydata.ED.all(stimNum) = bystimdata(stimNum).engageddriv.mean;
    summarydata.ESB.all(stimNum) = bystimdata(stimNum).engagedsponbefore.mean;
    summarydata.ESA.all(stimNum) = bystimdata(stimNum).engagedsponafter.mean;
end

%% concat across stims - get mean
summarydata.PD.mean = mean(summarydata.PD.all);

summarydata.ED.mean = mean(summarydata.ED.all);
summarydata.ESB.mean = mean(summarydata.ESB.all);
summarydata.ESA.mean = mean(summarydata.ESA.all);

%% concat across stims - get std
summarydata.PD.std = std(summarydata.PD.all);

summarydata.ED.std = std(summarydata.ED.all);
summarydata.ESB.std = std(summarydata.ESB.all);
summarydata.ESA.std = std(summarydata.ESA.all);

%% concat across stims - get stderr
summarydata.PD.stderr = stderr(summarydata.PD.all);

summarydata.ED.stderr = stderr(summarydata.ED.all);
summarydata.ESB.stderr = stderr(summarydata.ESB.all);
summarydata.ESA.stderr = stderr(summarydata.ESA.all);

if dosummaryplot == 1
    allmean = [summarydata.PS.mean summarydata.PD.mean summarydata.ESA.mean summarydata.ED.mean];
    
    if dostd
        allerrbar = [summarydata.PS.std summarydata.PD.std summarydata.ESA.std summarydata.ED.std];
        ylabelname = 'meanFR(std)';
    else
        allerrbar = [summarydata.PS.stderr summarydata.PD.stderr summarydata.ESA.stderr summarydata.ED.stderr];
        ylabelname = 'meanFR(stderr)';
    end
    
    figure
    xlabels = {};
    xcatlabels = {'passSpon' 'passDriv' 'engSpon' 'engDriv'};
    stimname = 'allStims';
    colors = [0.5,.5,1;0,0,.5;1,.25,.25;.5,0,0];
    handles = barweb(allmean, allerrbar, [], xlabels, sprintf('subject: %s  site: %s  cellmarker: %d stim: %s',unit.subject,unit.site,unit.marker,stimname), [], ylabelname, colors, 'none', {});
    
    set(handles.errors,'linewidth',2)
    
    legend(xcatlabels,'location','southoutside','orientation','horizontal')
    legend('boxoff')
end

end