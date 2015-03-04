function SM_SS_convertsetstimfilefromndege(infile,outfile)
%convert ndege setstim file to one for spike2 on ibon

fidIN = fopen(infile,'r');
fidOUT = fopen(outfile,'w'); %check to see if theres anything there first?

tline = fgetl(fidIN);
while ischar(tline)
    dat = textscan(tline, '%s %d %d %d %d %d %d %d');
    fprintf(fidOUT,'"%s",\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d\n',dat{1}{1},dat{2},dat{3},dat{4},dat{5},dat{6},dat{7},dat{8});
    tline = fgetl(fidIN);
end

fclose(fidIN);
fclose(fidOUT);

end