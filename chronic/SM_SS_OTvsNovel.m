%SM_SS OT vs UT vs N

%% no spike shapes
load(fixfilesep([getdanroot(),'\experiments\analysis\st531\u53120100906nowf.mat']))
load(fixfilesep([getdanroot(),'\experiments\analysis\st575\u57520100909nowf.mat']))
load(fixfilesep([getdanroot(),'\experiments\analysis\st531\OT531.mat']))
load(fixfilesep([getdanroot(),'\experiments\analysis\st575\OT575.mat']))

clear U
k = 0;
for i = 1:length(u531)
    k = k+1;
    D(k) = SM_SS_makePEPconditions(u531(i));
end
for i = 1:length(u575)
    k = k+1;
    D(k) = SM_SS_makePEPconditions(u575(i));
end
DD=D;



%% all passiveonly

k=0;
for cellid = 1:length(D)
    if ~isempty(SM_picktrials(D(cellid),'condition','passive'))
        k = k+1;
        E(k) = D(cellid);
    end
end

for cellid = 1:length(E)
    unit = E(cellid);
    if strmatch(E(cellid).subject,'st531')
        currOT = OT531;
    else
        if strmatch(unit.subject,'st575')
            currOT = OT575;
        else
            error('huh?!');
        end
    end
    
    %get all non OT, passively presented stims
    stims = SM_getstims(SM_picktrials(unit,'condition','passive'));
    
    goodstimsind = ~ismember(stims(:,1),currOT);
    silind = strmatch('silence',stims(:,1));
    if ~isempty(silind)
        goodstimsind(silind) = false;
    end
    notOTstims = stims(goodstimsind,1);
    
    for otnum = 1:length(currOT)
        [meanFROT(otnum),FROT(otnum),stdFROT(otnum)] = SM_getfiringrate(SM_picktrials(unit,'condition','passive','stim',currOT{otnum}));
        allFROT{otnum} = FROT(otnum).allFR;
    end
    
    for nototnum = 1:length(notOTstims)
        [meanFRnotOT(nototnum),FRnotOT(nototnum),stdFRnotOT(nototnum)] = SM_getfiringrate(SM_picktrials(unit,'condition','passive','stim',notOTstims{nototnum}));
        allFRnotOT{nototnum} = FRnotOT(nototnum).allFR;
    end
    
    [meanFRsil,FRsil,stdFRsil] = SM_getfiringrate(SM_picktrials(unit,'condition','passive','stim',stims{silind}));
        allFRsil = FRsil.allFR;
    
%     figure;bareb(meanFROT,stdFROT);
%     set(gca,'xtick',[1:1:length(meanFROT)]);
%     set(gca,'xticklabel',currOT);
%     rotateticklabel(gca,70);
%     title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
%     
%     figure;bareb(meanFRnotOT,stdFRnotOT);
%     set(gca,'xtick',[1:1:length(meanFRnotOT)]);
%     set(gca,'xticklabel',notOTstims);
%     rotateticklabel(gca,70);
%     title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
%     
%     
%     
    doplot=0;
    [otz{cellid} nototz{cellid}] = compareZscoregroups(meanFROT-meanFRsil,meanFRnotOT-meanFRsil,doplot);
    
    motz(cellid) = mean(otz{cellid});
    mnototz(cellid) = mean(nototz{cellid});
end

figure;
bareb([mean(motz) mean(mnototz)],[std(motz) std(mnototz)]);
set(gca,'xticklabel',{'OT' 'notOT'});
title('all Passive Trials')

%% all first pep passive only

k=0;
for cellid = 1:length(D)
    if ~isempty(SM_picktrials(D(cellid),'condition','PEP1'))
        k = k+1;
        E(k) = D(cellid);
    end
end

for cellid = 1:length(E)
    unit = E(cellid);
    if strmatch(E(cellid).subject,'st531')
        currOT = OT531;
    else
        if strmatch(unit.subject,'st575')
            currOT = OT575;
        else
            error('huh?!');
        end
    end
    
    %get all non OT, passively presented stims
    stims = SM_getstims(SM_picktrials(unit,'condition','PEP1'));
    
    goodstimsind = ~ismember(stims(:,1),currOT);
    silind = strmatch('silence',stims(:,1));
    if ~isempty(silind)
        goodstimsind(silind) = false;
    end
    notOTstims = stims(goodstimsind,1);
    
    for otnum = 1:length(currOT)
        [meanFROT(otnum),FROT(otnum),stdFROT(otnum)] = SM_getfiringrate(SM_picktrials(unit,'condition','PEP1','stim',currOT{otnum}));
        allFROT{otnum} = FROT(otnum).allFR;
    end
    
    for nototnum = 1:length(notOTstims)
        [meanFRnotOT(nototnum),FRnotOT(nototnum),stdFRnotOT(nototnum)] = SM_getfiringrate(SM_picktrials(unit,'condition','PEP1','stim',notOTstims{nototnum}));
        allFRnotOT{nototnum} = FRnotOT(nototnum).allFR;
    end
    
    [meanFRsil,FRsil,stdFRsil] = SM_getfiringrate(SM_picktrials(unit,'condition','PEP1','stim',stims{silind}));
        allFRsil = FRsil.allFR;
    
%     figure;bareb(meanFROT,stdFROT);
%     set(gca,'xtick',[1:1:length(meanFROT)]);
%     set(gca,'xticklabel',currOT);
%     rotateticklabel(gca,70);
%     title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
%     
%     figure;bareb(meanFRnotOT,stdFRnotOT);
%     set(gca,'xtick',[1:1:length(meanFRnotOT)]);
%     set(gca,'xticklabel',notOTstims);
%     rotateticklabel(gca,70);
%     title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
%     
%     
%     
    doplot=0;
    [otz{cellid} nototz{cellid}] = compareZscoregroups(meanFROT-meanFRsil,meanFRnotOT-meanFRsil,doplot);
    
    motz(cellid) = mean(otz{cellid});
    mnototz(cellid) = mean(nototz{cellid});
end

figure;
bareb([mean(motz) mean(mnototz)],[std(motz) std(mnototz)]);
set(gca,'xticklabel',{'OT' 'notOT'});
title('PEP1 Only')


