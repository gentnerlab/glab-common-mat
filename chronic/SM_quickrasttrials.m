function ax = SM_quickrasttrials(desTrials,ax)
%ax = SM_quickrasttrials(trials,ax)
%
%ax = SM_rasttrials(ax,toes,codes,yvals,codemapname)

codemapname='defaultshading';

startTimeCode = 'beginrange';
endTimeCode = 'endrange';
zeroTimeReferenceCode = '<';

passivetrials = SM_trialispassive(desTrials);

[windowedspikes codes] = SM_windowspikes4(desTrials,startTimeCode,endTimeCode,zeroTimeReferenceCode);

for i = 1:size(windowedspikes,1)
    stimstarttime(i,1) = SM_get_trial_stimstarttime(desTrials(i,:)) - codes.zeroTimes(i);
    stimendtime(i,1) = SM_get_trial_stimendtime(desTrials(i,:)) - codes.zeroTimes(i);
    
    [peckcodes{i} pecktimes{i}] = SM_get_trial_codes(desTrials(i,:));%,double(['C' 'c' 'R' 'r' 'L' 'l'])');
    pecktimes{i} = pecktimes{i} - codes.zeroTimes(i);
    
    toes{i,1} = [windowedspikes{i,1};stimstarttime(i);stimendtime(i);pecktimes{i}];
    rastcodes{i,1} = [2*ones(size(windowedspikes{i,1},1),1)-passivetrials(i);double('<');double('>');peckcodes{i}];
end

yvals=1:size(toes,1);

if nargin <2;figure;ax=axes;else if ax<=0;figure;ax=axes;else axes(ax);end;end

for repnum = 1:size(toes,1)
    SM_rasttrial(toes{repnum,:},rastcodes{repnum,:},yvals(repnum),codemapname);
end

end