function [subjectinfodata,subjectname] = SM_readsubjectinfofile(subjectinfofile)
% returns penetration, site, epoch info from subjectinfo file

if isempty(strfind(fixfilesep(subjectinfofile),filesep()))
    subjectinfofile = fixfilesep(['D:\experiments\raw\' subjectinfofile filesep() subjectinfofile '.SubjectInfo']); %this only works on Ibon
end

fid = fopen(subjectinfofile,'r');

subjectinfodata = {};
subjectname = '';

cline = 0;

pennum = 0;
sitenum = 0;
epochnum = 0;
setstimfilenum = 0;
electrodenum = 0;

while 1
cline = fgetl(fid);
if cline == -1
    break
end


if ~isempty(strfind(cline,'Created Subject Info File for'))
stmpind = strfind(cline,'Created Subject Info File for');
subjectname = cline(stmpind+30:end);
continue
end


if ~isempty(strfind(cline,'"Penetration"'))
pennum = pennum +1;

dat = textscan(cline,'%s%s%s%d%s',1,'Delimiter',',');
dat{5} = {cline(strfind(cline,dat{5}{1}):end)};

subjectinfodata = [subjectinfodata; {pennum, sitenum, epochnum, setstimfilenum, dat{1}{1}(2:end-1) , dat{2}{1}(2:end-1) , dat{3}{1}(2:end-1) , dat{4} , dat{5}{1}(2:end-1)}];
continue
end

if ~isempty(strfind(cline,'"Site"'))
sitenum = sitenum +1;

dat = textscan(cline,'%s%s%s%d%s',1,'Delimiter',',');
dat{5} = {cline(strfind(cline,dat{5}{1}):end)};

subjectinfodata = [subjectinfodata; {pennum, sitenum, epochnum, setstimfilenum, dat{1}{1}(2:end-1) , dat{2}{1}(2:end-1) , dat{3}{1}(2:end-1) , dat{4} , dat{5}{1}(2:end-1)}];
continue
end

if ~isempty(strfind(cline,'"Epoch"')) || ~isempty(strfind(cline,'"Session"'))
epochnum = epochnum +1;

dat = textscan(cline,'%s%s%s%d%s',1,'Delimiter',',');
dat{5} = {cline(strfind(cline,dat{5}{1}):end)};

subjectinfodata = [subjectinfodata; {pennum, sitenum, epochnum, setstimfilenum, dat{1}{1}(2:end-1) , dat{2}{1}(2:end-1) , dat{3}{1}(2:end-1) , dat{4} , dat{5}{1}(2:end-1)}];
continue
end

if ~isempty(strfind(cline,'"NewSetStimFile"'))
setstimfilenum = setstimfilenum +1;

dat = textscan(cline,'%s%s%s%d',1,'Delimiter',',');

subjectinfodata = [subjectinfodata; {pennum, sitenum, epochnum, setstimfilenum, dat{1}{1}(2:end-1) , dat{2}{1}(2:end-1) , dat{3}{1}(2:end-1) , dat{4} , {}}];
continue
end

if ~isempty(strfind(cline,'"Electrode"'))
electrodenum = electrodenum +1;

dat = textscan(cline,'%s%s%s%d%s',1,'Delimiter',',');
dat{5} = {cline(strfind(cline,dat{5}{1}):end)};

subjectinfodata = [subjectinfodata; {pennum, sitenum, epochnum, setstimfilenum, dat{1}{1}(2:end-1) , dat{2}{1}(2:end-1) , dat{3}{1}(2:end-1) , dat{4} , dat{5}{1}(2:end-1)}];
continue
end



end
fclose(fid);

end

