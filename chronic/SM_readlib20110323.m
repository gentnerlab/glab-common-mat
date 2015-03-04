function Units = SM_readlib20110323(subject,keepspikeshapes,dataonIbon,verbose,noProcess,noGetSortQual)
% Units = reads2lib(subject,keepspikeshapes,dataonFugl2,verbose,noProcess,noGetSortQual)
% keepspikeshapes default is 0
% dataonFugl2 default is 0
% verbose default is 0
% noProcess default is 0
% noGetSortQual default is 0

if nargin < 6,  noGetSortQual = 0;      end
if nargin < 5,  noProcess = 0;          end
if nargin < 4,  verbose = 0;            end
if nargin < 3,  dataonIbon = 0;        end
if nargin < 2,  keepspikeshapes = 0;	end



% subject             = 'st515';
% keepspikeshapes     = 0;
% dataonIbon             = 0;
% verbose             = 1;

%% Check filesystem and create path variables
if dataonIbon == 0
    subjectDir = fixfilesep(fullfile(getdanroot(),'experiments','analysis',subject,filesep()));
    sortfile = fixfilesep(fullfile(subjectDir,'sortData.csv'));
    libraryfile = fixfilesep(fullfile(subjectDir,'catfiles',strtrim(ls(fixfilesep([subjectDir '/catfiles\st*s2MATLibraryZ.txt'])))));
else
    subjectDir = fixfilesep(sprintf('D:/experiments/analysis/%s/',subject));
    sortfile = fixfilesep(fullfile(subjectDir,'sortData.csv'));
    libraryfile = fixfilesep(strtrim(ls([subjectDir '/catfiles/st*s2MATLibraryD.txt'])));
    libraryfile = fixfilesep([subjectDir '/catfiles/' libraryfile]);
end

%% Open library File and Get s2mat file names

if verbose;fprintf(1,'opening library file: %s\n',libraryfile);end
fid = fopen(libraryfile);

nums2mats = 0;

clear S2MatNames
while ~feof(fid)
    nums2mats = nums2mats+1;
    currS2MatName = fixfilesep(fullfile(subjectDir, strtrim(fgetl(fid))));
    S2MatNames{nums2mats} = currS2MatName;
end

fclose(fid); %close library file

%% load data from each s2mat file

Units=[];
for currS2Mat=1:nums2mats
    currS2MatName = S2MatNames{currS2Mat};
    if verbose;fprintf(1,'in reads2MATlib - current s2MAT file: %s\n',currS2MatName);end
    %fprintf(1,[currS2MatName '\n']);Units=[]; %this is for debugging
    if isempty(strfind(currS2MatName,'compressed'))
        iscompressed = 0;
    else
        iscompressed = 1;
    end
        Units = [Units SM_reads2mat_20110317(currS2MatName,keepspikeshapes,verbose,iscompressed)];
end

%% do concat and units cleanup
if ~noProcess
    Units = SM_processSMreadlibstruct(Units);
end

%% get sort quality
if ~noGetSortQual
    Units = SM_getSortQuality(Units,sortfile);
end

end


%% functions


function Units = SM_processSMreadlibstruct(U)
% U should be a struct array - created by reads2mat

%% concat cells with same site and marker info - return into new cell array of structs with each cell = one unique unit
%there's probably a cleaner way to execute the code below - but this works!

behtype = '2ac';

numUnits=0;
sites = cell(length(U),1);
for i=1:length(U)
    sites{i} = U(i).site;
end
usitemarkers=cell(1,2);
[usites,inds,moreinds] = unique(sites);
siteinds = cell(length(usites),1);
sitemarkers = cell(length(usites),1);
for i = 1:length(usites)
    currsite = usites{i};
    siteinds{i} = ismember(sites,currsite);
    sitemarkers{i} = [U(siteinds{i}).marker];
    usitemarkers{i,1} = unique(sitemarkers{i});
    for j = 1:length(usitemarkers{i})
        numUnits=numUnits+1;
        usitemarkers{i,2} = [usitemarkers{i,2} numUnits];
    end
end

for cellID = 1:length(moreinds)
    siteID = moreinds(cellID);
    for markNum = 1:length(usitemarkers{siteID,2})
        markID = usitemarkers{siteID,1}(markNum);
        if U(cellID).marker == markID
            subnum = regexp(U(cellID).subject,'\d+','match','once');
            U(cellID).cellID = str2double(sprintf('%s%03d',subnum,usitemarkers{siteID,2}(markNum)));
        end
    end
end

cellUID = cell(length(U),1);
for i=1:length(U)
    cellUID{i} = U(i).cellID;
end
[ucellUID,inds,moreinds] = unique(cell2mat(cellUID));

for numUID = 1:length(ucellUID)
    
    currinds = find(moreinds == numUID);
    trialinds = [];
    for n = 1:length(currinds)
        N = currinds(n);
        if n == 1 %transfer all the things unique to all
            C(numUID).subject = U(N).subject;
            C(numUID).pen = U(N).pen;
            C(numUID).site = U(N).site;
            C(numUID).marker = U(N).marker;
            %C(numUID).UID = ucellUID(numUID); %without some external library or
            %static database, these UIDs will be different everytime the
            %raw data is loaded - best to avoid them for now since once the
            %cells get concatenated, each cell of the cell array will
            %distinguish unique cells
            C(numUID).trials = [];
        end
        %transfer all indiv things
        %C(numUID).info{n} = U(N).info;
        C(numUID).info(n) = U(N).info;
        
        temptrials = U(N).trials;
        C(numUID).trials = [C(numUID).trials;temptrials];
        
        C(numUID).trials = SM_sorttrials(C(numUID).trials,'timeorder');
        C(numUID).stims = SM_getstims(C(numUID));
        %C(numUID).info{n}.trialinds = [];
        C(numUID).info(n).trialinds = [];
        trialinds = [trialinds;n*ones(size(temptrials,1),1)];
    end
    
    for n = 1:length(currinds)
        %C(numUID).info{n}.trialinds = trialinds == n;
        C(numUID).info(n).trialinds = trialinds == n;
    end
end

%% figure out which trials are passive and which engaged, and process engaged trials

for unitID = 1 : length(C)
    C(unitID).trials = C(unitID).trials;
    
    numTrials       = size(C(unitID).trials,1);
    %     reinfCorrect    = zeros(numTrials,1);
    %     unreinfCorrect  = zeros(numTrials,1);
    %     reinfWrong      = zeros(numTrials,1);
    %     unreinfWrong    = zeros(numTrials,1);
    %     noResp          = zeros(numTrials,1);
    
    %ascii conversions: | F = 70 | f = 102 | T = 84 | t = 116 | N = 78 |
    
    for i = 1:numTrials %this is just about the slowest way I can think to do this.... hopefully it's not too bad?
        if sum(C(unitID).trials{i,9}.codes(:,1) == 70)==1
            %reinfCorrect(i) = 1;
            C(unitID).trials{i,12} = 'F';
            continue
        end
        if sum(C(unitID).trials{i,9}.codes(:,1) == 102)==1
            %unreinfCorrect(i) = 1;
            C(unitID).trials{i,12} = 'f';
            continue
        end
        if sum(C(unitID).trials{i,9}.codes(:,1) == 84)==1
            %reinfWrong(i) = 1;
            C(unitID).trials{i,12} = 'T';
            continue
        end
        if sum(C(unitID).trials{i,9}.codes(:,1) == 116)==1
            %unreinfWrong(i) = 1;
            C(unitID).trials{i,12} = 't';
            continue
        end
        if sum(C(unitID).trials{i,9}.codes(:,1) == 78)==1
            %noResp(i) = 1;
            C(unitID).trials{i,12} = 'N';
            continue
        end
        %if got here then this is not an active trial
        C(unitID).trials{i,12} = 'p'; %'p' for passive want to keep column 12 of trials a single character so I can cell2mat() it
    end
    if strcmp(behtype,'2ac')
        for i = 1:numTrials
            if C(unitID).trials{i,12} == 'p' || C(unitID).trials{i,12} == 'N'
                C(unitID).trials{i,13} = 'N';
            else %find first L or R after stimoff ('>')
                j = find(C(unitID).trials{i,9}.codes(:,1) == 62);
                keepgoing = 1;
                while keepgoing == 1
                    j = j+1;
                    if j > size(C(unitID).trials{i,9}.codes,1)
                        keepgoing = 0;
                    else
                        if C(unitID).trials{i,9}.codes(j,1) == 82
                            C(unitID).trials{i,13} = 'R';
                            keepgoing = 0;
                        elseif C(unitID).trials{i,9}.codes(j,1) == 76
                            C(unitID).trials{i,13} = 'L';
                            keepgoing = 0;
                        end
                    end
                end
            end
        end
    else
        error('FIXME, I haven''t coded this bit up for gng yet')
    end
    
    
    C(unitID).conditions{1,1} = 'passive';
    C(unitID).conditions{1,2} = cell2mat(C(unitID).trials(:,12)) == 'p';
    C(unitID).conditions{2,1} = 'engaged';
    C(unitID).conditions{2,2} = ~C(unitID).conditions{1,2};
    %     numreinfCorrect     = sum(reinfCorrect);
    %     numunreinfCorrect   = sum(unreinfCorrect);
    %     numreinfWrong       = sum(reinfWrong);
    %     numunreinfWrong     = sum(unreinfWrong);
    %     numnoResp           = sum(noResp);
end

Units = C;
end

%% get sort quality
function [Units] = SM_getSortQuality(Units,infile)
%reads in sort quality from external file

if nargin < 2, infile ='';end

Sort = [];
for unitNum = 1:length(Units)
    currsorts = -ones(length(Units(unitNum).info),1);
    for sortNum = 1:length(Units(unitNum).info)
        if isempty(Units(unitNum).info(sortNum).sortquality) || Units(unitNum).info(sortNum).sortquality < 0 || Units(unitNum).info(sortNum).sortquality > 5
            if ~isempty(infile)%can get info from external file
                Sort = SM_getSortDataFromCSV(infile);
                for sortfileNum = 1:size(Sort.sortfiles,1)
                    if ~isempty(findstr(Sort.sortfiles{sortfileNum}(1:end-4), Units(unitNum).info(sortNum).s2MATfile))
                        if Sort.markers(sortfileNum) == Units(unitNum).marker %after here should have correct index - but keep looking for completeness
                            if ~isempty(findstr(Sort.sites{sortfileNum},Units(unitNum).site))
                                if ~isempty(findstr(Sort.pens{sortfileNum},Units(unitNum).pen))
                                    if strcmp(Sort.subjects{sortfileNum},Units(unitNum).subject)
                                        Units(unitNum).info(sortNum).sortquality = Sort.sorts(sortfileNum);
                                        Units(unitNum).info(sortNum).smrchan1 = Sort.chan1(sortfileNum);
                                        Units(unitNum).info(sortNum).smrchan2 = Sort.chan2(sortfileNum);
                                        Units(unitNum).info(sortNum).smrchan3 = Sort.chan3(sortfileNum);
                                        Units(unitNum).info(sortNum).smrchan4 = Sort.chan4(sortfileNum);
                                    end
                                else
                                    fprintf(1,'weird error: pen doesn''t match\n');
                                end
                            else
                                fprintf(1,'weird error: site doesn''t match\n');
                            end
                        end
                    end
                end
                if isempty(Units(unitNum).info(sortNum).sortquality) || Units(unitNum).info(sortNum).sortquality < 0 || Units(unitNum).info(sortNum).sortquality > 5
                    %if still don't have a reasonable sort - have user input it
                    [zz,sortfilename,zz,zz] = fileparts(Units(unitNum).info(sortNum).s2MATfile);
                    dispString = {'Pick the sort quality of:',sprintf('pen:   %s',Units(unitNum).pen),sprintf('site:   %s',Units(unitNum).site),sprintf('marker:   %02d',Units(unitNum).marker),sprintf('sort:   %s',sortfilename)};
                    Units(unitNum).info(sortNum).sortquality = SM_asksortqual(dispString);
                end
                currsorts(sortNum) = Units(unitNum).info(sortNum).sortquality;
            else
                %could put code here to ask user to input sort for each
            end
        end
    end
    Units(unitNum).sortquality = [mean(currsorts) std(currsorts) length(currsorts)]; %avg sort for cell, std of sort for cell, number of separate sorts for cell
end

end

%% read in sort data from external file

function Sort = SM_getSortDataFromCSV(infile)
%to be used with .csv files created from google docs or other spreadsheet where sort data is stored
%careful...sometimes loadcell is weird and will miss the bottommost right cell

A = readtext(infile);

Sort.headers = A(1,:);
Sort.subjects = A(2:end,strcmp('subject',Sort.headers));
Sort.pens = A(2:end,strcmp('pen',Sort.headers));
Sort.sites = A(2:end,strcmp('site',Sort.headers));
Sort.markers = cell2mat(A(2:end,strcmp('marker',Sort.headers)));
Sort.sortfiles = A(2:end,strcmp('sortfile',Sort.headers));
Sort.sorts = cell2mat(A(2:end,ismember(Sort.headers,'sort rating 0-5')));

if any(strcmp('sortchannel1',Sort.headers))
    
chan1 = A(2:end,strcmp('sortchannel1',Sort.headers));
ix = cellfun('isempty',chan1);
c = zeros(length(chan1),1);
c(~ix) = cell2mat(chan1);
Sort.chan1 = c;

chan2 = A(2:end,strcmp('sortchannel2',Sort.headers));
ix = cellfun('isempty',chan2);
c = zeros(length(chan2),1);
c(~ix) = cell2mat(chan2);
Sort.chan2 = c;

chan3 = A(2:end,strcmp('sortchannel3',Sort.headers));
ix = cellfun('isempty',chan3);
c = zeros(length(chan3),1);
c(~ix) = cell2mat(chan3);
Sort.chan3 = c;

chan4 = A(2:end,strcmp('sortchannel4',Sort.headers));
ix = cellfun('isempty',chan4);
c = zeros(length(chan4),1);
c(~ix) = cell2mat(chan4);
Sort.chan4 = c;

end

end