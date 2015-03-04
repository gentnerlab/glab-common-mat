function success = SM_SS_writesetstimsfile(setstims,outfile,format)
%success = SM_SS_writesetstimsfile(setstims,outfile,format)

%format = 0 : spike2style (with "" and ,)
%format = 1 : ndegestyle (no "" nor ,)

if nargin < 3
    format = 0;
end

fid = fopen(outfile,'w'); %check to see if theres anything there first?

if format == 0
    for i = 1:size(setstims,1)
        fprintf(fid,'"%s",\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d\n',setstims{i,1},setstims{i,2},setstims{i,3},setstims{i,4},setstims{i,5},setstims{i,6},setstims{i,7},setstims{i,8});
    end
else
    for i = 1:size(setstims,1)
        fprintf(fid,'%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',setstims{i,1},setstims{i,2},setstims{i,3},setstims{i,4},setstims{i,5},setstims{i,6},setstims{i,7},setstims{i,8});
    end
end

fclose(fid);

success = 1;

end