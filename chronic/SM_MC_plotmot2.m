function [trialindsout out toes rastcodes] = SM_MC_plotmot2(Unit,motifname,ax,sortmethod,passeng,doplot)

if nargin < 6;doplot=1;end
if nargin < 5;passeng='both';end
if nargin < 4;sortmethod='motifposition';end
if nargin < 3;ax=0;end

out = [];

if ~isfield(Unit,'motif')
    Unit = SM_makemotifstruct(Unit);
end

if ischar(motifname)
    motifindex = find(strcmp(Unit.motif.exemplars(:,1),motifname));
elseif isnumeric(motifname)
    motifindex = motifname;
    motifname = Unit.motif.exemplars{motifindex,1};
end

switch lower(passeng)
    case {'pass' 'passive'}
        keepinds = Unit.conditions{ismember(Unit.conditions(:,1),'passive'),2}';
    case {'eng' 'engaged'}
        keepinds = Unit.conditions{ismember(Unit.conditions(:,1),'engaged'),2}';
    case {'both'}
        keepinds = true(size(Unit.trials,1),1);
    otherwise
        keepinds = true(size(Unit.trials,1),1);
end

motiftrialindices = ~cellfun('isempty',Unit.motif.byexemp.time(motifindex,:));

desIndices = motiftrialindices(:) & keepinds(:);

k = 0;
for i = 1:length(desIndices)
    if desIndices(i)
        k = k+1;
        motifstarttimes(k) = Unit.motif.byexemp.time{motifindex,i}{1}(1);
        motifendtimes(k) = Unit.motif.byexemp.time{motifindex,i}{1}(2);
    end
end


desTrials = Unit.trials(desIndices,:);
passivetrials = SM_trialispassive(desTrials);
startTimeCode = 'beginrange';
endTimeCode = 'endrange';
zeroTimeReferenceCode = motifstarttimes;

trialinds = find(desIndices);


[windowedspikes codes] = SM_windowspikes4(desTrials,startTimeCode,endTimeCode,zeroTimeReferenceCode);
for i = 1:size(windowedspikes,1)
    stimstarttime(i,1) = SM_get_trial_stimstarttime(desTrials(i,:)) - codes.zeroTimes(i);
    stimendtime(i,1) = SM_get_trial_stimendtime(desTrials(i,:)) - codes.zeroTimes(i);
    motifstarttime(i,1) = motifstarttimes(i)-codes.zeroTimes(i);
    motifendtime(i,1) = motifendtimes(i)-codes.zeroTimes(i);
    
    [peckcodes{i} pecktimes{i}] = SM_get_trial_codes(desTrials(i,:));%,double(['C' 'c' 'R' 'r' 'L' 'l'])');
    pecktimes{i} = pecktimes{i} - codes.zeroTimes(i);
    
    toes{i,1} = [windowedspikes{i,1};stimstarttime(i);stimendtime(i);motifstarttime(i);motifendtime(i);pecktimes{i}];
    rastcodes{i,1} = [2*ones(size(windowedspikes{i,1},1),1)-passivetrials(i);double('<');double('>');double('M');double('m');peckcodes{i}];
end

switch lower(sortmethod)
    case {'motifposition' 'timeintrial'}
        [zz,theorder] = sortrows([passivetrials,stimstarttime,stimendtime]);
        theorder = flipud(theorder);
        yvals=[];
    case {'motifposition-pe' 'timeintrial-pe'}
        [zz,theorder] = sortrows([stimstarttime,stimendtime]);
        theorder = flipud(theorder);
        yvals=[];
    case {'outcome' 'result' 'behavior'}
        sortorder = ['FfTtNp'];
        [outcomes,theorder] = sortset([desTrials{:,12}],sortorder);
        toes = toes(theorder);
        rastcodes = rastcodes(theorder);
        for i = 1:length(outcomes)
            outcomecodes(i,1) = find(outcomes(i) == sortorder);
        end
        outcomecodes(outcomecodes == 2) = 1; %F = f
        outcomecodes(outcomecodes == 4) = 3; %T = t
        [zz,theorder] = sortrows([outcomecodes,stimstarttime(theorder),stimendtime(theorder)]);
        theorder = flipud(theorder);
        yvals = [];
    case {'likemotclass'}
        
        likeclasssinds = SM_MC_getmotifinds(Unit,motifindex,'respondlikemotifclass',desIndices);
        unlikeclasssinds = SM_MC_getmotifinds(Unit,motifindex,'-respondlikemotifclass',desIndices);
        likeclassinds = find(likeclasssinds&desIndices);
        unlikeclassinds = find(unlikeclasssinds&desIndices);
        norespinds = find(~(likeclasssinds&desIndices)&~(unlikeclasssinds&desIndices)&desIndices);
        R = [likeclassinds,ones(length(likeclassinds),1);unlikeclassinds,ones(length(unlikeclassinds),1).*2;norespinds,ones(length(norespinds),1).*3];
        for j = 1:size(R,1)
            currind = R(j,1);
            theorder(j,1) = find(trialinds==currind);
            theorder2(j,1) = R(j,2);
        end
        out.numlike = length(likeclassinds);
        out.numunlike = length(unlikeclassinds);
        out.numnoresp = length(norespinds);
        
        [zz,theorder3] = sortrows([theorder2,stimstarttime(theorder),stimendtime(theorder)]);
        theorder=theorder(theorder3);
        theorder = flipud(theorder);
        yvals = [];
    case {'relativetime' 'reltime' 'timeorder'}
        [zz,theorder] = sort([desTrials{:,3}]);
        yvals=[];
    case {'timeofday' 'tod' 'time'}
        error('TIMEOFDAY SORT: I''m not coded up yet - fix me!')
        yvals = [desTrials{:,3}];
        [yvals,theorder] = sort(yvals);
        
end

toes = toes(theorder);
rastcodes = rastcodes(theorder);
trialindsout = trialinds(theorder);

if doplot == 1
    SM_rasttrials(ax,toes,rastcodes,yvals,'defaultshading_noresult');
    
    axis([min(stimstarttime)-1 max(stimendtime)+3 0 size(windowedspikes,1)+1]);
    set(gcf,'color','w');
    
    v=axis;
    if strmatch(lower(sortmethod),'likemotclass')
        hold on
        y1 = out.numnoresp+0.5;
        y2 = y1 + out.numunlike;
        %y3
        line([v(1) v(2)],[y1 y1],'color','k');
        line([v(1) v(2)],[y2 y2],'color','k');
        %line([v(1) v(2)],[out.numlike out.numlike]);
    end
end

end