function [alltrials rdatstyle] = SM_readalltrialsfile(infile)
% alltrials = SM_readalltrialsfile(infile)

fidIN = fopen(infile,'r');

trials = textscan(fidIN, '%4d :%2d :%2d %2d :%2d :%2d %d %d %d %d %d %d %d %d %d %d %s %s %s','delimiter',',','commentstyle',{'##','##'});

alltrials = [num2cell(trials{1}) num2cell(trials{2}) num2cell(trials{3}) num2cell(trials{4}) num2cell(trials{5})... 
    num2cell(trials{6}) num2cell(trials{7}) num2cell(trials{8}) num2cell(trials{9})  num2cell(trials{10}) num2cell(trials{11})... 
    num2cell(trials{12})  num2cell(trials{13}) num2cell(trials{14}) num2cell(trials{15}) num2cell(trials{16}) trials{17} trials{18} trials{19}];

tod = num2cell([trials{4}*100+trials{5}]);
dnum = num2cell([trials{1}*10000+trials{2}*100+trials{3}]);
rdatstyle = [num2cell(-1*ones(size(alltrials,1),1)) num2cell(-1*ones(size(alltrials,1),1)) num2cell(~trials{13}) trials{17}...
    num2cell(trials{12}) num2cell(trials{14}) num2cell(trials{15}) num2cell(-1*ones(size(alltrials,1),1)) num2cell(trials{16}) tod dnum];

fclose(fidIN);
end