function [meanrates datarates] = SM_summaryFR(Unit)
%[meanrates datarates] = SM_summaryFR(Unit)

meanrates = struct('alldriv',[],'silence',[],'passivedriv',[],'engageddriv',[],'engagedsponbefore',[],'engagedsponafter',[]);
datarates = struct('alldriv',[],'silence',[],'passivedriv',[],'engageddriv',[],'engagedsponbefore',[],'engagedsponafter',[]);


[zz,silinds] = SM_picktrials(Unit,'stim',{'silence'});
if sum(silinds)>0
    [meanrates.alldriv datarates.alldriv] = SM_getfiringrate(Unit.trials(~silinds,:));
    [meanrates.silence datarates.silence] = SM_getfiringrate(Unit.trials(silinds,:));
else
  [meanrates.alldriv datarates.alldriv]= SM_getfiringrate(Unit.trials);
end

if isfield(Unit,'conditions')
passivetrials = SM_picktrials(Unit,'condition',{'passive'});
if ~isempty(passivetrials)
    [meanrates.passivedriv datarates.passivedriv] = SM_getfiringrate(passivetrials);
end

engagedtrials = SM_picktrials(Unit,'condition',{'engaged'});
if ~isempty(engagedtrials)
    [meanrates.engageddriv datarates.engageddriv] = SM_getfiringrate(engagedtrials);
    [meanrates.engagedsponbefore datarates.engagedsponbefore] = SM_getfiringrate(engagedtrials,'startrange','ss-1.0');
    [meanrates.engagedsponafter datarates.engagedsponafter] = SM_getfiringrate(engagedtrials,'se+3.0','endrange');
end
end

meanrates.stimnames = Unit.stims(:,1);
for stimnum = 1:length(meanrates.stimnames)
   [meanrates.stim(stimnum) datarates.stim(stimnum)] = SM_getfiringrate(SM_picktrials(Unit,'stimulus',meanrates.stimnames{stimnum}));
   %datarates.stim(stimnum).name = meanrates.stimnames{stimnum};
end

end