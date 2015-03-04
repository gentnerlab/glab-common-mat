function SM_SS_plotS2alltrials(trials,MAwin,noindiv)
%ND_SS_plotset(trials,setstruct,MAwin,noindiv)

%% deal with inputs

if ~exist('noindiv','var')
    noindiv=0;
elseif noindiv == -1
    noindiv=0;
end

if ~exist('MAwin','var')
    MAwin=20;
elseif MAwin == -1
    MAwin=20;
end

%% set things up

figure;
h = axes;

classcolors = {'r' 'b' 'y' 'g' 'm' 'c'};

uclasses = unique([trials{:,5}]);
classlegends = cell(length(uclasses),1);

%[criterionchecks critinds] = ND_SS_checksetcriterion(trials,setstruct);



%% plot class lines
for currclass = 1:length(uclasses)
    T_ofinterest = ND_picktrials(trials,'class',uclasses(currclass),'correction',0);
    if ~isempty(T_ofinterest)
        classlegends{currclass} = ['C' num2str(uclasses(currclass)) 'numCrit: ' ];%num2str(criterionchecks(uclasses(currclass)))];
        linehandle_C(currclass) = ND_plotbehavior(T_ofinterest,MAwin,h);
        set(linehandle_C(currclass),'color',classcolors{uclasses(currclass)},'linewidth',3,'markersize',2,'marker','+','markeredgecolor','k')
    end
end
%% plot no responses

linehandle_noresp = ND_plotbehavior_noresponly(trials,MAwin,h);
 set(linehandle_noresp,'color',[.6 .6 .6],'linewidth',2,'markersize',1,'marker','+','markeredgecolor','k')
classlegends{currclass+1} = 'noresponse';


%% plot 0.5 line
v=axis;
xes=v(1):0.2:v(2);
plot(xes,ones(length(xes),1)*0.5,'k:','linewidth',3);
drawnow

%% plot CI

[e,CI] = binofit(MAwin/2,MAwin);
plot(xes,ones(length(xes),1)*CI(2),'k:');
plot(xes,ones(length(xes),1)*CI(1),'k:');

%% plot individual stimulus lines

if noindiv ~= 1
    %setstims = [setstruct.data{:,3}]';
    allstims = unique(trials(:,4));
    for stimnum = 1:length(allstims)
        T_ofinterest = ND_picktrials(trials,'stimulus',allstims{stimnum},'correction',0);
        if ~isempty(T_ofinterest)
            linehandle_S(stimnum) = ND_plotbehavior(T_ofinterest,MAwin,h);
            currclass = T_ofinterest{1,5};
            set(linehandle_S(stimnum),'color',classcolors{currclass},'linewidth',1,'markersize',1,'marker','+','markeredgecolor','k')
        end
    end
end


 
%%
if iscellstr(classlegends)
    legend(classlegends,'location','southwest');
    legend('boxoff');
end

set(gcf,'color','w');

drawnow


end