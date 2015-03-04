function trials = SM_readS2opdat_2ac_folder(pathtofolder)

%'D:\experiments\raw\st517\data\prePenetrationBehaviorOnly\Ses35_112509-1700_BO_R'

if ~(pathtofolder(end) == '\' || pathtofolder(end) == '/')
    pathtofolder = [pathtofolder filesep()];
end


trials = [];

folderlist = dir([pathtofolder 'Ses*_*']);

if isempty(folderlist)
    folderlist(1).name = '';
end

for foldernum = 1:length(folderlist)
    currfoldname = fixfilesep(fullfile(pathtofolder,folderlist(foldernum).name,filesep()));
    filelist = dir([currfoldname '*opdat.txt']);
    
    for filenum = 1:length(filelist)
        trials = [trials ; SM_readS2opdat_2ac(fixfilesep(fullfile(currfoldname,filelist(filenum).name)))];
    end
    
end