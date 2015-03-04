function masterstimfile = SM_SS_getmasterstimfile(subjectid)

files = dir(['D:\experiments\raw\' subjectid '\stims\*.MASTERstim']);

if length(files) == 1
    masterstimfile = files(1).name;
    masterstimfile = fixfilesep(['D:\experiments\raw\' subjectid '\stims\' masterstimfile]);
elseif length(files) > 1
    warning('more than one .MASTERstim file found - FIXME, How can you have more than one MASTER?!?');
elseif isempty(files) %probably an ndege bird, look elsewhere
    fprintf(1,'Looking for an Ndege bird');
    files = dir(['Z:\behavior\fromndege\' subjectid filesep() 'setstims' subjectid(2:end) '.stim']);
    if length(files) == 1
        masterstimfile = files(1).name;
        masterstimfile = fixfilesep(['Z:\behavior\fromndege\' subjectid filesep() masterstimfile]);
    elseif length(files) > 1
        warning('more than one setstims .stim file found - FIXME, How can you have more than one MASTER?!?');
    elseif isempty(files)
        warning('no .MASTERstim file found');
        masterstimfile = '';
    end
end


end
