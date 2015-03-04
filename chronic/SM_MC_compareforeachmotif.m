function [ps] = SM_MC_compareforeachmotif(Unit,class1trialmask,class2trialmask,class1label,class2label,class1sponallFR,class2sponallFR,nofigure)

if nargin<8
    nofigure = 0;
end

motclasses = SM_MC_getmotclasses(Unit.subject);

for motID = 1:length(motclasses)
    [meanFRC1(motID),datFRC1{motID}] = SM_MC_getfiringrate_motif(Unit,motID,class1trialmask);
    C1{motID} = datFRC1{motID}.allFR;
    [meanFRC2(motID),datFRC2{motID}] = SM_MC_getfiringrate_motif(Unit,motID,class2trialmask);
    C2{motID} = datFRC2{motID}.allFR;
end

C1{length(motclasses)+1} = class1sponallFR;
C2{length(motclasses)+1} = class2sponallFR;

[x1,g1] = makeXGrpfromcellarray(C1);
[x2,g2] = makeXGrpfromcellarray(C2);


for i = 1:size(motclasses,1)
    labels{i,1} = ['C' num2str(motclasses{i,2}) '_'  motclasses{i,1}];
end
labels = [labels;'spon'];


alpha = 0.05;
bcorr = alpha/(length(labels)-1);
for i =1:length(labels)-1
    ps(i) = ranksum(C1{i},C2{i});
end


if ~nofigure
    figure;
    boxplot(x1,g1,'plotstyle','compact','notch','on','color','b')
    set(gca,'XTickLabel',{' '})
    hold on
    boxplot(x2,g2,'plotstyle','compact','notch','on','color','r','labels',labels)
    
    title(['Pen:' Unit.pen ' Site:' Unit.site ' Marker:' num2str(Unit.marker)],'interpreter','none')
    
    v=axis;
    text(13.5,(v(4)-v(3))/2,class1label,'color','b')
    text(13.5,(v(4)-v(3))/3,class2label,'color','r')
    
    for i =1:length(ps)
        if ps(i) <= bcorr
            text(i,0.9*v(4),'*');
        end
    end
end



end