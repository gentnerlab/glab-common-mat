function engagedset = SM_SS_pickengagedset(unit,setstims,params)
%engagedset = SM_SS_pickengagedset(unit,setstims)

if nargin < 3 %default parameters are to have one OT pair and one UT pair
    OTparams.classes = [1,2];
    OTparams.pairsdesired = 1;
    OTparams.selectiontype = 'random';
    
    Tparams.classes = [3,4];
    Tparams.pairsdesired = 0;
    Tparams.selectiontype = 'random';
    
    UTparams.classes = [5,6];
    UTparams.pairsdesired = 0;
    UTparams.selectiontype = 'random';
    
    NOVparams.classes = -1;
    NOVparams.pairsdesired = 1;
    NOVparams.selectiontype = 'nov_random';
else
    OTparams = params.OT;
    Tparams = params.T;
    UTparams = params.UT;
    NOVparams = params.NOV;
end


OTstims = selectengagedstims(unit,setstims,OTparams);
Tstims = selectengagedstims(unit,setstims,Tparams);
UTstims = selectengagedstims(unit,setstims,UTparams);
NOVstims = selectengagedstims(unit,setstims,NOVparams);

if isequal(OTstims,-1) ||  isequal(Tstims,-1) || isequal(UTstims,-1) || isequal(NOVstims,-1)
    error('selectengagedstims returned -1');
end

engagedset = [OTstims;Tstims;UTstims;NOVstims];

end


function outstims = selectengagedstims(unit,setstims,params)
if params.pairsdesired <= 0
    outstims = [];
    return;
else
    classes = cell2mat(setstims(:,2));
    
    numin = 0;
    allinds = [];
    for i = 1:length(params.classes)
        currclass = params.classes(i);
        classinds{i} = find(classes==currclass);
        numin = numin + length(classinds{i});
        allinds = [allinds;classinds{i}];
    end
    
    if params.pairsdesired*2 > numin
        outstims = -1;
        fprintf(1,'Not enough stimuli to satisfy parameters\n');
        return;
    elseif params.pairsdesired*2 == numin
        outstims = setstims(allinds,:);
    else %pick based on responses
        switch lower(params.selectiontype)
            case 'random'
                inds = [];
                for i = 1:length(classinds)
                    tinds = classinds{i};
                    tinds = tinds(randperm(length(tinds)));
                    inds = [inds;tinds(1:params.pairsdesired)];
                end
                outstims = setstims(inds,:);
            case 'highestfr'
                outstims = [];
                for i = 1:length(params.classes)
                    currclass = params.classes(i);
                    [FRnames{i} ssinds{i} FRrates{i}] = getClassFRnamesrates(unit,setstims,currclass);
                    
                    if length(FRnames{i}) <= params.pairsdesired
                        outstims = -1;
                        fprintf(1,'in case: ''highestfr'' - Not enough stimuli in class %d with observed firing rates to satisfy parameters\n',currclass);
                        return;
                    end
                    
                    outstims = [outstims;setstims(ssinds{i}(end-(params.pairsdesired-1):end),:)];
                    
                end
            case 'lowestfr'
                outstims = [];
                for i = 1:length(params.classes)
                    currclass = params.classes(i);
                    [FRnames{i} ssinds{i} FRrates{i}] = getClassFRnamesrates(unit,setstims,currclass);
                    
                    if length(FRnames{i}) <= params.pairsdesired
                        outstims = -1;
                        fprintf(1,'in case: ''lowestfr'' - Not enough stimuli in class %d with observed firing rates to satisfy parameters\n',currclass);
                        return;
                    end
                    
                    outstims = [outstims;setstims(ssinds{i}(1:params.pairsdesired),:)];
                    
                end
            case 'nov_random'
                outstims = [];
                tinds = classinds{1}; %class should ALWAYS be -1 for novel
                tinds = tinds(randperm(length(tinds)));
                inds = tinds(1:params.pairsdesired*2);
                outstims = setstims(inds,:);
                %now recode equal numbers of the novel stims as 5,6
                outstims{1:params.pairsdesired,2} = 5;
                outstims{params.pairsdesired+1:end,2} = 6;
            case 'nov_highestfr'
                currclass = -1;
                [FRnames ssinds FRrates] = getClassFRnamesrates(unit,setstims,currclass);
                
                if length(FRnames) <= params.pairsdesired*2
                    outstims = -1;
                    fprintf(1,'in case: ''nov_highestfr'' - Not enough stimuli in class with observed firing rates to satisfy parameters\n');
                    return;
                end
                
                outstims = setstims(ssinds(end-(params.pairsdesired*2-1):end),:);
                %now recode equal numbers of the novel stims as 5,6
                outstims{1:params.pairsdesired,2} = 5;
                outstims{params.pairsdesired+1:end,2} = 6;
            case 'nov_lowestfr'
                currclass = -1;
                [FRnames ssinds FRrates] = getClassFRnamesrates(unit,setstims,currclass);
                
                if length(FRnames) <= params.pairsdesired*2
                    outstims = -1;
                    fprintf(1,'in case: ''nov_lowestfr'' - Not enough stimuli in class with observed firing rates to satisfy parameters\n');
                    return;
                end
                
                outstims = setstims(ssinds(1:params.pairsdesired*2),:);
                %now recode equal numbers of the novel stims as 5,6
                outstims{1:params.pairsdesired,2} = 5;
                outstims{params.pairsdesired+1:end,2} = 6;
            otherwise
                inds = -1;
                disp('params.selectiontype: %s not recognized',params.selectiontype);
                return;
        end
    end
end
end

function [FRnames setstimsinds FRrates FRdatarates] = getClassFRnamesrates(unit,setstims,currclass)
[meanrates datarates] = SM_summaryFR(unit);

ssinds = find(cell2mat(setstims(:,2))==currclass);
currclassnames = setstims(ssinds,1);
[InClassHaveFR FRindex] = ismember(currclassnames,meanrates.stimnames);

ssinds = ssinds(InClassHaveFR);
FRnames = currclassnames(InClassHaveFR);
FRrates = meanrates.stim(FRindex(InClassHaveFR));
FRdatarates = datarates.stim(FRindex(InClassHaveFR));

[FRrates order] = sort(FRrates);
FRnames = FRnames(order);
FRdatarates = FRdatarates(order);
setstimsinds = ssinds(order);

[zz o2] = ismember(setstims(:,1),FRnames);

ssinds= find(zz);
setstimsinds= ssinds(o2(zz));

end

function [FRnames setstimsinds FRrates FRdatarates] = getClassFRnamesratesBACK(unit,setstims,currclass)
[meanrates datarates] = SM_summaryFR(unit);

ssinds = cell2mat(setstims(:,2))==currclass;
currclassnames = setstims(ssinds,1);
[InClassHaveFR FRindex] = ismember(currclassnames,meanrates.stimnames);

ssinds = find(ssinds(InClassHaveFR));
FRnames = currclassnames(InClassHaveFR);
FRrates = meanrates.stim(FRindex(InClassHaveFR));
FRdatarates = datarates.stim(FRindex(InClassHaveFR));

[FRrates order] = sort(FRrates);
FRnames = FRnames(order);
FRdatarates = FRdatarates(order);
setstimsinds = ssinds(order);

[zz o2] = ismember(setstims(:,1),FRnames);

ssinds= find(zz);
setstimsinds= ssinds(o2(zz));

end


