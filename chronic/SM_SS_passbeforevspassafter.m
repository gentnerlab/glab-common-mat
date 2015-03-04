%passive before vs passive after



%% %passive before vs passive after - straight up FR

for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    
    for stimnum = 1:size(stims,1)
        pepb = SM_picktrials(unit,'condition',peps{1,1},'stim',stims{stimnum});
        [bmeanFR(stimnum) bFR(stimnum) bstdFR(stimnum)] = SM_getfiringrate(pepb);
        
        pepa = SM_picktrials(unit,'condition',peps{end,1},'stim',stims{stimnum});
        [ameanFR(stimnum) aFR(stimnum) astdFR(stimnum)] = SM_getfiringrate(pepa);
    end
    
    [~,order] = sort(bmeanFR,'descend');
    bmeanFR = bmeanFR(order);
    bFR = bFR(order);
    bstdFR = bstdFR(order);
    
    ameanFR = ameanFR(order);
    aFR = aFR(order);
    astdFR = astdFR(order);
    
    stims = stims(order,:);
    
    
    figure
    barweb([bmeanFR',ameanFR'],[bstdFR',astdFR'],2,stims(:,1));
    axminY(0);
    rotateticklabel(gca,70);
    
    %plot silence line
    hold on
    
    sortedsilind = strmatch('silence',stims(:,1));
    line([0 length(bmeanFR)+0.5],[bmeanFR(sortedsilind) bmeanFR(sortedsilind)],'linewidth',2,'color','b')
    line([0 length(bmeanFR)+0.5],[bmeanFR(sortedsilind)+bstdFR(sortedsilind) bmeanFR(sortedsilind)+bstdFR(sortedsilind)],'linestyle',':','linewidth',1,'color','b')
    line([0 length(bmeanFR)+0.5],[bmeanFR(sortedsilind)-bstdFR(sortedsilind) bmeanFR(sortedsilind)-bstdFR(sortedsilind)],'linestyle',':','linewidth',1,'color','b')
    
    line([0 length(bmeanFR)+0.5],[ameanFR(sortedsilind) ameanFR(sortedsilind)],'linewidth',2,'color','r')
    line([0 length(bmeanFR)+0.5],[ameanFR(sortedsilind)+astdFR(sortedsilind) ameanFR(sortedsilind)+astdFR(sortedsilind)],'linestyle',':','linewidth',1,'color','r')
    line([0 length(bmeanFR)+0.5],[ameanFR(sortedsilind)-astdFR(sortedsilind) ameanFR(sortedsilind)-astdFR(sortedsilind)],'linestyle',':','linewidth',1,'color','r')
    
    
    title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
    
    engstims = SM_getstims(SM_picktrials(unit,'condition',{peps{2,1} peps{4,1}}));
    for m = 1:size(engstims,1)
        currind = strmatch(engstims{m,1},stims(:,1));
        plot(currind , max((bmeanFR(currind)+bstdFR(currind)),(ameanFR(currind)+astdFR(currind))),'marker','d','markerfacecolor','g','markeredgecolor','g')
        
    end
    
end

%% %passive before vs passive after - Fr-baselineFR
k = 0;
for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    sortedsilind = strmatch('silence',stims(:,1));
    keepers = true(1,size(stims,1));
    keepers(sortedsilind) = false;
    stims = stims(keepers,:);
    
    clear bmeanFR bFR bstdFR ameanFR aFR astdFR
    for stimnum = 1:size(stims,1)
        pepb = SM_picktrials(unit,'condition',peps{1,1},'stim',stims{stimnum});
        [bmeanFR(stimnum) bFR(stimnum) bstdFR(stimnum)] = SM_getfiringrate(pepb);
        
        pepa = SM_picktrials(unit,'condition',peps{end,1},'stim',stims{stimnum});
        [ameanFR(stimnum) aFR(stimnum) astdFR(stimnum)] = SM_getfiringrate(pepa);
    end
    
    
    bBL = SM_getfiringrate(SM_picktrials(unit,'condition',peps{1,1},'stim','silence'));
    aBL = SM_getfiringrate(SM_picktrials(unit,'condition',peps{end,1},'stim','silence'));
    
    bnormFR = bmeanFR - bBL;
    anormFR = ameanFR - aBL;
    
    [~,order] = sort(bmeanFR,'descend');
    bnormFR = bnormFR(order);
    bFR = bFR(order);
    bstdFR = bstdFR(order);
    
    anormFR = anormFR(order);
    aFR = aFR(order);
    astdFR = astdFR(order);
    
    stims = stims(order,:);
    
    
    figure
    barweb([bnormFR',anormFR'],[bstdFR',astdFR'],2,stims(:,1));
    %axminY(0);
    rotateticklabel(gca,70);
    
    %plot silence line
    hold on
    
    
    
    title(['Subject:' unit.subject ' Pen:' unit.pen ' Site:' unit.site ' Marker:' num2str(unit.marker)], 'interpreter','none')
    
    engstims = SM_getstims(SM_picktrials(unit,'condition',{peps{2,1} peps{4,1}}));
    if size(engstims,1) ~= 4
        i
        k = k+1;
        unitdd(k) = unit;
    end
    
    for m = 1:size(engstims,1)
        currind = strmatch(engstims{m,1},stims(:,1));
        plot(currind , max((bnormFR(currind)+bstdFR(currind)),(anormFR(currind)+astdFR(currind))),'marker','d','markerfacecolor','g','markeredgecolor','g')
        
    end
    
end

%% let's do some info stuff... ALL STIMS THAT WERE PRESENTED DURING ENG EPOCH

numinfobins = 10;

for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    sortedsilind = strmatch('silence',stims(:,1));
    keepers = true(1,size(stims,1));
    keepers(sortedsilind) = false;
    stims = stims(keepers,:);
    
    engstims{i} = SM_getstims(SM_picktrials(unit,'condition',{peps{2,1} peps{4,1}}));
    
    
    
    for m = 1:size(engstims{i},1)
        engind(m) = strmatch(engstims{i}{m,1},stims(:,1));
        [x FRpassive] = SM_getfiringrate(SM_picktrials(unit,'conditions',{peps{1,1},peps{end,1}},'stim',engstims{i}{m,1}));
        
        minmin = min(FRpassive.allFR);
        maxmax = max(FRpassive.allFR);
    end
    
    clear PDFB PDFA
    for m = 1:size(engstims{i},1)
        PDFB(m,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',engstims{i}{m,1}),numinfobins,[minmin maxmax]);
        PDFA(m,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',engstims{i}{m,1}),numinfobins,[minmin maxmax]);
    end
    
    [MIB(i), EntB(i), NoiseEntB(i)] = calcMIandEntandNoiseEnt(PDFB/4);
    [MIA(i), EntA(i), NoiseEntA(i)] = calcMIandEntandNoiseEnt(PDFA/4);
end

figure;bareb([mean(MIB),mean(MIA)],[std(MIB),std(MIA)])
[x,ord] = sort(MIB);
figure;hold on;plot(MIB(ord),'b');plot(MIA(ord),'r')
v=axis;
figure; plot(MIB(ord)-MIA(ord),'k*-'); hold on ; line([v(1) v(2)],[0 0])


%% let's do some info stuff... OTpassbefore vs OTpassafter

numinfobins = 10;

for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    sortedsilind = strmatch('silence',stims(:,1));
    keepers = true(1,size(stims,1));
    keepers(sortedsilind) = false;
    stims = stims(keepers,:);
    
    OTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 1 | [gengstims{i}{:,2}] == 2,1}};
   % UTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 5 | [gengstims{i}{:,2}] == 6,1}};
    
    
        [x FRpassive] = SM_getfiringrate(SM_picktrials(unit,'conditions',{peps{1,1},peps{end,1}},'stim',OTstims{i}));
        
        minmin = min(FRpassive.allFR);
        maxmax = max(FRpassive.allFR);
  
    
    clear PDFB PDFA
        PDFB(1,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',OTstims{i}{1}),numinfobins,[minmin maxmax]);
        PDFB(2,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',OTstims{i}{2}),numinfobins,[minmin maxmax]);
        
        PDFA(1,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',OTstims{i}{1}),numinfobins,[minmin maxmax]);
   PDFA(2,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',OTstims{i}{2}),numinfobins,[minmin maxmax]);
    
    [MIB(i), EntB(i), NoiseEntB(i)] = calcMIandEntandNoiseEnt(PDFB/2);
    [MIA(i), EntA(i), NoiseEntA(i)] = calcMIandEntandNoiseEnt(PDFA/2);
end

figure;bareb([mean(MIB),mean(MIA)],[std(MIB),std(MIA)])

[x,ord] = sort(MIB);
figure;hold on;plot(MIB(ord),'b');plot(MIA(ord),'r')
v=axis;
figure; plot(MIB(ord)-MIA(ord),'k*-'); hold on ; line([v(1) v(2)],[0 0])


%% let's do some info stuff... UTpassbefore vs UTpassafter

numinfobins = 10;

for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    sortedsilind = strmatch('silence',stims(:,1));
    keepers = true(1,size(stims,1));
    keepers(sortedsilind) = false;
    stims = stims(keepers,:);
    
    %OTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 1 |[gengstims{i}{:,2}] == 2,1}};
    %UTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 5 | [gengstims{i}{:,2}] == 6,1}};
    
 
        [x FRpassive] = SM_getfiringrate(SM_picktrials(unit,'conditions',{peps{1,1},peps{end,1}},'stim',UTstims{i}));
        
        minmin = min(FRpassive.allFR);
        maxmax = max(FRpassive.allFR);
    
        [mFRB(i,1) FRB{i,1} sFRB(i,1)] = SM_getfiringrate(SM_picktrials(unit,'conditions',peps{1,1},'stim',UTstims{i}{1}));
        [mFRB(i,2) FRB{i,2} sFRB(i,2)] = SM_getfiringrate(SM_picktrials(unit,'conditions',peps{1,1},'stim',UTstims{i}{2}));
        [mFRA(i,1) FRA{i,1} sFRA(i,1)] = SM_getfiringrate(SM_picktrials(unit,'conditions',peps{end,1},'stim',UTstims{i}{1}));
        [mFRA(i,2) FRA{i,2} sFRA(i,2)] = SM_getfiringrate(SM_picktrials(unit,'conditions',peps{end,1},'stim',UTstims{i}{2}));
        
        
    clear PDFB PDFA
        PDFB(1,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',UTstims{i}{1}),numinfobins,[minmin maxmax]);
        PDFB(2,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',UTstims{i}{2}),numinfobins,[minmin maxmax]);
        
        PDFA(1,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',UTstims{i}{1}),numinfobins,[minmin maxmax]);
   PDFA(2,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',UTstims{i}{2}),numinfobins,[minmin maxmax]);
    
    [MIB(i), EntB(i), NoiseEntB(i)] = calcMIandEntandNoiseEnt(PDFB/2);
    [MIA(i), EntA(i), NoiseEntA(i)] = calcMIandEntandNoiseEnt(PDFA/2);
end

figure;bareb([mean(MIB),mean(MIA)],[std(MIB),std(MIA)])
[x,ord] = sort(MIB);
figure;hold on;plot(MIB(ord),'b');plot(MIA(ord),'r')
v=axis;
figure; plot(MIB(ord)-MIA(ord),'k*-'); hold on ; line([v(1) v(2)],[0 0])




%% let's do some info stuff... ALLpassbefore vs ALLpassafter

numinfobins = 10;

for i = 1:length(G)
    currunit = G(i);
    
    unit = SM_SS_makePEPconditions(currunit);
    [peps pepnums] = SM_SS_getpep(unit);
    
    stims = SM_getstims(SM_picktrials(unit,'condition',peps{1,1}));
    sortedsilind = strmatch('silence',stims(:,1));
    keepers = true(1,size(stims,1));
    keepers(sortedsilind) = false;
    stims = stims(keepers,:);
    
    %OTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 1 |
    %[gengstims{i}{:,2}] == 2,1}};
    %UTstims{i} = {gengstims{i}{[gengstims{i}{:,2}] == 5 | [gengstims{i}{:,2}] == 6,1}};
    
        [x FRpassive] = SM_getfiringrate(SM_picktrials(unit,'conditions',{peps{1,1},peps{end,1}},'stim',{stims{:,1}}));
        minmin = min(FRpassive.allFR);
        maxmax = max(FRpassive.allFR);
    
    clear PDFB PDFA
    for m = 1:size(stims,1)
        PDFB(m,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{1,1},'stim',stims{m,1}),numinfobins,[minmin maxmax]);
        PDFA(m,:) = SM_PDFtrialsFR(SM_picktrials(unit,'conditions',peps{end,1},'stim',stims{m,1}),numinfobins,[minmin maxmax]);
    end
    
    [MIB(i), EntB(i), NoiseEntB(i)] = calcMIandEntandNoiseEnt(PDFB/size(stims,1));
    [MIA(i), EntA(i), NoiseEntA(i)] = calcMIandEntandNoiseEnt(PDFA/size(stims,1));
end

figure;bareb([mean(MIB),mean(MIA)],[std(MIB),std(MIA)])
[x,ord] = sort(MIB);
figure;hold on;plot(MIB(ord),'b');plot(MIA(ord),'r')
v=axis;
figure; plot(MIB(ord)-MIA(ord),'k*-'); hold on ; line([v(1) v(2)],[0 0])
