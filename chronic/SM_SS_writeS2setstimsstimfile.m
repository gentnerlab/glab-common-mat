function success = SM_SS_writeS2setstimsstimfile(setstims,outfile)
%success = SM_SS_writesetstimsfile(setstims,outfile)

fid = fopen(outfile,'w'); %check to see if theres anything there first?

for i = 1:size(setstims,1)
    fprintf(fid,'"%s",%d,%d,100,100,\n',setstims{i,1},setstims{i,2},setstims{i,3});
end

fclose(fid);

success = 1;

end