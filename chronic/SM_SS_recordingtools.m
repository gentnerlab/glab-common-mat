% recording from setstims birds tools

error('try ''edit SM_SS_recordingtools''')
%% swapbirds
edit SM_SS_swapbirds
%% paddepths
probetype = '16_50';
tipdepth = 2265;
PD = paddepths(probetype,tipdepth)
%% pick passive set
birdid = 'st822';
cd(['D:\experiments\raw\' birdid '\stims\'])
setstims = SM_SS_readsetstimfile(SM_SS_getmasterstimfile(birdid));
searchset = SM_SS_picksearchset(setstims)
outfilename = ['D:\experiments\raw\' birdid '\stims\' 'searchset-' datestr(now,'yyyymmdd+HHMMSS') '.stim'];
success = SM_SS_writeS2setstimsstimfile(searchset,outfilename)
%% pick engaged set from passive set

rng('shuffle','twister')
c1e = randi(3,1,1);
c2e = randi(3,1,1);
c56e = randi(6,2,1);

fprintf(1,'class 1 index:\t%d\nclass 2 index:\t%d\nclass 5 index:\t%d\nclass 6 index:\t%d\n',c1e,c2e,c56e(1),c56e(2))
%% plotstimfile
stimfile = 'engagedset-20121110+110554.stim'
plotstimfile(['D:\experiments\raw\' birdid '\stims\' stimfile])

%% watch behavior during engaged epoch
MAwin =20;
subject = 'st822';
usetrialsafterthistime = 1020;

ATFname = SM_getAllTrialsFileName(subject);
[alltrials rdatstyle] = SM_readalltrialsfile(ATFname);
trials = ND_picktrials(rdatstyle,'datetime+',[str2num(datestr(now(),'yyyymmdd')) usetrialsafterthistime]);
%trials = rdatstyle;
SM_SS_plotS2alltrials(trials,MAwin,-1)
    title([subject ' ' datestr(now())])

ND_SS_summary(trials);

%% Load ML swap
getspikeshapes = 1;
units = SM_reads2mat('D:\SpikeMatlabSwap\swap.mat',getspikeshapes);
% units = SM_reads2mat_20110317_notworkyet('D:\SpikeMatlabSwap\swap.mat');
%% plot things
SM_rastpsthallstims(units)
SM_barmeanfr(units)
