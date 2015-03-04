function ss = SM_SS_masterstimsummary(subjectid)

ss = SM_SS_readsetstimfile(SM_SS_getmasterstimfile(subjectid));
fprintf(1,'\n\n');
fprintf(1,'Masterstim summary for %s\n',subjectid)
fprintf(1,'total # \tstimuli in masterstim file:\t%d\n',size(ss,1));
classes = cell2mat(ss(:,2));
uclasses = unique(classes);
for i = 1:size(uclasses,1)
    currclass = uclasses(i);
fprintf(1,'class %d \tstimuli in masterstim file:\t%d\n',currclass,sum(classes == currclass));
end
fprintf(1,'\n')
end
