%scripting examples for s2mat structs

%% get all cells from st515
U = reads2MATlib('st515',1,0,0,0,0);

%% get cells with good sort quality and which have both engaged and passive conditions
G = SM_pickunits(U,'sortqual',[2.5 5],'sortstd',[0 1],'allconds',{'passive' 'engaged'});

%% plot all the spikes from a given unit under a given condition
% plotSpikes(SM_picktrials(SM_pickunits(U,'site',25,'marker',2),'condition',{'engaged'}));
% plotSpikes(SM_picktrials(SM_pickunits(U,'site',30,'marker',2),'condition',{'passive'}));

%% grab all engaged trials from some cell

desTrials = SM_picktrials(G(11),'cond',{'engaged'});

 %% get trialdata with behavioral data appended
% 
% [Btrials BDind]= appendBD(desTrials);
% 
% % get just the behavioral structs from each trial
% W = [Btrials{:,BDind}];

%% plot all passive and engaged trials with different y axes

cellID=14;
stimID=[3];

desTrials = {
    SM_picktrials(U(cellID),'stim',stimID,'cond',{'engaged'})
    SM_picktrials(U(cellID),'stim',stimID,'cond',{'passive'})
    };

SM_rast(desTrials,'dotimeaxis',0)
SM_rast(desTrials,'dotimeaxis',1)
SM_rast(desTrials,'dotimeaxis',2)

%% plot multiple songs on the same rasterplot

cellID=14;

desTrials = {
    SM_picktrials(U(cellID),'stim',11,'cond',{'passive'})
    SM_picktrials(U(cellID),'stim',4,'cond',{'passive'})
    SM_picktrials(U(cellID),'stim',5,'cond',{'passive'})
    SM_picktrials(U(cellID),'stim',6,'cond',{'passive'})
    };

SM_rast(desTrials,'dotimeaxis',0,'nolines',0)

%% include an analysis of behavior next to a raster plot

cellID=9;
stimID=[1];

desTrials = {
    SM_picktrials(G(cellID),'cond',{'engaged'})
     SM_picktrials(G(cellID),'cond',{'passive'})
%     SM_picktrials(G(cellID),'cond',{'engaged'},'stim',stimID)
%     SM_picktrials(G(cellID),'cond',{'passive'},'stim',stimID)
    };

s2rast10(desTrials,'dotimeaxis',0,'behavior','gng','blocksize',50,'legendnames',{'engaged' 'passive'},'unit',G(cellID))
SM_rast(desTrials,'dotimeaxis',0,'behavior','gng','blocksize',50,'legendnames',{'engaged' 'passive'},'unit',G(cellID))
