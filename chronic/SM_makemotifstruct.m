function [Unit] = SM_makemotifstruct(Unit)
%
% Unit.motif.exemplars = numexemplarsX 2 cell array {'exemplarname' [trialindex starttimeintrial endtimeintrial]}
% Unit.motif.exemplardurs 
% Unit.motif.bytrial = bytrial;
% Unit.motif.byexemp.place = placeoccur';
% Unit.motif.byexemp.time = timeoccur';


stimlibpath = 'D:\experiments\stimlib\';

%find indiv motifs
putmots = cell(1,1);
numputmot = 0;
for stimnum = 1:size(Unit.stims,1)
    plusinds = strfind(Unit.stims{stimnum,1},'+');
    if size(plusinds,1) == 0
        numputmot = numputmot + 1;
        putmots{numputmot,1} = Unit.stims{stimnum,1};
    else
        for numex = 1:size(plusinds,2)+1
            numputmot = numputmot + 1;
            if numex == 1
                putmots{numputmot,1} = Unit.stims{stimnum,1}(1:plusinds(numex)-1);
            elseif numex == size(plusinds,2)+1
                putmots{numputmot,1} = Unit.stims{stimnum,1}(plusinds(numex-1)+1:end);
            else
                putmots{numputmot,1} = Unit.stims{stimnum,1}(plusinds(numex-1)+1:plusinds(numex)-1);
            end
        end
    end
end
uex = unique(putmots);
%now get times of each exemplar
uextimes = zeros(length(uex),1);
for numex = 1:length(uex);
    uextimes(numex,1) = wavdur([stimlibpath uex{numex} '.wav']);
end


%search for each exemplar in each stim and assign times
exempstims = cell(size(uex,1),1);
placeoccur = cell(size(Unit.trials,1),size(uex,1));
timeoccur = cell(size(Unit.trials,1),size(uex,1));
totpres = zeros(size(uex,1),1);
for exnum = 1:size(uex,1)
    exempstims{exnum} = false(size(Unit.trials,1),1);
end
for trialnum = 1:size(Unit.trials,1)
    for exnum = 1:size(uex,1)
        instim = strfind(Unit.trials{trialnum,6},uex{exnum});
        if ~isempty(instim)
            exempstims{exnum}(trialnum) = true;
            plusinds = strfind(Unit.trials{trialnum,6},'+');
            numexemp = length(plusinds)+1;
            for occurnum = 1:length(instim)
                placeoccur{trialnum,exnum}(occurnum) = sum(instim(occurnum) > plusinds) + 1;
            end
        end
    end
    
    currexemps = ~cellfun('isempty',placeoccur(trialnum,:));
    
    clear ordering;
    numex = 0;
    for exnum = 1:length(currexemps)
        if currexemps(exnum)
            for occurnum = 1:length(placeoccur{trialnum,exnum})
                numex = numex +1;
                ordering(numex,1) = exnum;
                ordering(numex,2) = placeoccur{trialnum,exnum}(occurnum);
            end
        end
    end
    [zz,ord] = sort(ordering(:,2));
    bytrial{trialnum,1} = ordering(ord,1);
    currtimes = zeros(size(bytrial{trialnum,1},1),2);
    tottime = 0;
    for exnum = 1: size(bytrial{trialnum,1},1)
       currtimes(exnum,1) = tottime;
       tottime = tottime + uextimes(bytrial{trialnum,1}(exnum));
       currtimes(exnum,2) = tottime;
    end
    bytrial{trialnum,2} = currtimes;
    
    for exnum = 1:length(currexemps)
        if currexemps(exnum)
            for occurnum = 1:length(placeoccur{trialnum,exnum})
                totpres(exnum) = totpres(exnum)+1;
                timeoccur{trialnum,exnum}{occurnum} = bytrial{trialnum,2}(placeoccur{trialnum,exnum}(occurnum),:);
                uex{exnum,2}(totpres(exnum),:) = [trialnum bytrial{trialnum,2}(placeoccur{trialnum,exnum}(occurnum),:)];
            end
        end
    end
    
end


motif.exemplars = uex;
motif.exemplardurs = uextimes;
motif.bytrial = bytrial;
motif.byexemp.place = placeoccur';
motif.byexemp.time = timeoccur';

Unit.motif = motif;

end