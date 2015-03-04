function subjectinfofile = SM_getsubjectinfofile(subject)

if iscellstr(subject)
    subject = cell2mat(subject);
end
if isnumeric(subject)
    subject = ['st' num2str(subject)];
end

subjectinfofile = fixfilesep(['D:\experiments\raw\' subject filesep() subject '.SubjectInfo']);

if isempty(dir(subjectinfofile))
    subjectinfofile = fixfilesep([getdanroot() 'behavior/fromibon/' subject filesep subject '.SubjectInfo']);
    
    if isempty(dir(subjectinfofile))
        subjectinfofile = [];
        fprintf(1,'subjectinfofile: FileNotFound');
    end
end



end