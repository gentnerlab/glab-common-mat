function ATfname = SM_getAllTrialsFileName(subject)

if iscellstr(subject)
    subject = cell2mat(subject);
end

if isnumeric(subject)
    subject = ['st' num2str(subject)];
end

ATfname = fixfilesep(['D:/experiments/raw/' subject filesep() subject '.AllTrials']);

if isempty(dir(ATfname))
    ATfname = fixfilesep([getdanroot() 'behavior/fromibon/' subject filesep subject '.AllTrials']);
    
    if isempty(dir(ATfname))
        ATfname = [];
        fprintf(1,'AllTrials: FileNotFound');
    end
end

end