% recover from spike2 crash that ruins masterstimfile
% gets the needed values to add to the latest intact masterstimfile from
% the alltrialsfile.
% TO USE: 
%1. locate the most recent intact masterstimfile and copy it to the animal's stim folder
%2. note the date/time of this file and convert this to 'usetrailsafterthisdate/time below
%3. update the subjectid below
%4. run the code
%5. add the values in X to the appropriate columns in the masterstimfile

usetrialsafterthisdate = 20111014;
usetrialsafterthistime = 1509;
subjectid = 'st639';


%
%
%
alltrialsfilename = SM_getAllTrialsFileName(subjectid);
[alltrials rdatstyle] = SM_readalltrialsfile(alltrialsfilename);


trials = ND_picktrials(rdatstyle,'datetime+',[usetrialsafterthisdate usetrialsafterthistime]);

stims = ND_getstims(trials)

X={};1
for i = 1:length(stims)
x = ND_picktrials(trials,'stimulus',stims{i});
numpresentations(i) = size(x,1);

x = ND_picktrials(trials,'stimulus',stims{i},'responseAccuracy',1);
numcorrect(i) = size(x,1);

x = ND_picktrials(trials,'stimulus',stims{i},'responseAccuracy',0);
numincorrect(i) = size(x,1);

x = ND_picktrials(trials,'stimulus',stims{i},'responseAccuracy',2);
numnoresponse(i) = size(x,1);

X{i,1} = stims{i};
X{i,2} = numpresentations(i);
X{i,3} = numcorrect(i);
X{i,4} = numincorrect(i);
X{i,5} = numnoresponse(i);
end
