function [Units] = SM_reads2mat(infile,readSpikeShapes,verbose)
%[Units] = reads2mat(infile{,readSpikeShapes{,verbose}})

infile = fixfilesep(infile); %fixes for some mac/pc conversions and for regexp when finding 'pen' below

if nargin < 3,  verbose = 0;            end
if nargin < 2,  readSpikeShapes = 0;    end

trials = cell(1,11);


%% open the S2matfile of interest
if isempty(ls(infile))
    error(['Cannot find file ' infile]);
end
S = load(infile);
if verbose;fprintf(1,'successfully loaded infile: %s\n',infile);end

%% figure out which variable is what kind of channel
foundTM = 0;
numWMs  = 0;
foundDM = 0;
foundKB = 0;

names = fieldnames(S);
for i = 1:length(names)
    channel{i} = S.(names{i});
    if isfield(channel{i},'text') %we've found our textmark channel
        if foundTM == 0
            TM = channel{i};
            foundTM = 1;
        else
            error('we have multiple textmark channels!');
        end
        continue
    end
    
    if isfield(channel{i},'traces') %we've found a wavemark channel
        numWMs=numWMs+1;
        WM{numWMs} = channel{i};
        continue
    end
    
    if isfield(channel{i},'codes') && isfield(channel{i},'times') %this selects out any marker channel - by now we're looking only for Keyboard and DigMark channels
        if strcmp(channel{i}.title,'DigMark') || strcmp(channel{i}.title,'DigMark*') %found our Digmark channel unless someone is playing a mean joke
            if foundDM == 0
                DM = channel{i};
                foundDM = 1;
            else
                error('we have multiple DigiMark channels!');
            end
            continue
        else
            if strcmp(channel{i}.title,'Keyboard') %found our Keyboard channel unless someone is playing a mean joke
                if foundKB == 0
                    KB = channel{i};
                    foundKB = 1;
                else
                    error('we have multiple Keyboard channels!');
                end
                continue
            end
        end
    end
end
if foundTM && foundDM && foundKB && numWMs>0
    if verbose;fprintf(1,'Found all required channels including %d wavemark channels.\n',numWMs);end
    clear('channel');
else
    error('did not find all required channel types:\tTM:%d\tDM:%d\tKB:%d\tWMs:%d',foundTM,foundDM,foundKB,numWMs);
end

%% Now delimit subfiles

%find subfile starts (can get more than one if a concat file has been made)
subfilestartTMinds = find(TM.codes(:,1)==243);                                           %find all subfile date/timestamp TMs
subfileTMtimes = TM.times(subfilestartTMinds);                                           %find all subfile date/timestamp TMs
subfiledate = cell(length(subfilestartTMinds),1);
subfiletimeofday = cell(length(subfilestartTMinds),1);
subfilesecondssincemidnight = zeros(length(subfilestartTMinds),1);

for subfilenum  = 1:length(subfilestartTMinds)                                          %get some basic data from each subfile textmark
    %subfiledate{subfilenum} = regexp(TM.text(subfilestartTMinds(subfilenum),:),'\d{2}[-]\d{2}[-]\d{2}','match','once');
    %subfiletimeofday{subfilenum} = regexp(TM.text(subfilestartTMinds(subfilenum),:),'\d{2}[:]\d{2}[:]\d{2}','match','once');
    subfileTD = regexp(TM.text(subfilestartTMinds(subfilenum),:),'\d{2}[-]\d{2}[-]\d{2}','match');
    subfiledate{subfilenum} = subfileTD{1};
    subfiletimeofday{subfilenum} = subfileTD{2};
    %HoursMinsSecs = textscan(char(subfiletimeofday{subfilenum}),'%2d %*[:] %2d %*[:] %2d');
    HoursMinsSecs = textscan(char(subfiletimeofday{subfilenum}),'%2d %*[-] %2d %*[-] %2d');
    subfilesecondssincemidnight(subfilenum) = HoursMinsSecs{1}*3600 + HoursMinsSecs{2}*60 + HoursMinsSecs{3}; %calculate #secondssincemidnight
end

%% Now delimit trials
trialTimeStampTMinds = find(TM.codes(:,1)==244);                                         %find all trial timestamp TMs
trialIDTMinds = find(TM.codes(:,1)~=244 & TM.codes(:,1)~=243 & TM.codes(:,1)~=242);                            %find all textmark ID TMs


%find trial ends
trialendinds = find(DM.codes(:,1) == 41); %Currently, using ')' (ascii = 41, signals end of ITI) as trial delimeter
%find the stimulus starts
stimstartinds = find(DM.codes(:,1) == 60); %Currently, using '<' (ascii = 60, signals start of stim output) as trial delimeter

%check to see if files are complete - Need more elaborate error handling here
if length(trialendinds) ~= length(stimstartinds) %this can happen if recording stops before the end of the ITI, but after a stimulus is started
    disp('we have an issue #1: number of stim starts does not equal number of trial ends. I dont know what to do, build better error fixing!');
    %if there is a start at end but no end at end then:
    %     striplasttrialinfo = 1;
    %     numtrials=numtrials-1; %decrement number of trials, since stripping last one
    %     stimstartinds=stimstartinds(1:end-1); %strip last trial
    %end
    return
end
%check to see if different measures of numtrials are equal - Need more elaborate error handling here
if length(stimstartinds) ~= length(trialTimeStampTMinds) %find different number of trial timestamp textmarks than trialstart digmarks
    disp('we have an issue #2: number of stim starts does not equal number of trialTimeStampTMinds. I dont know what to do, build better error fixing!');
    return
end
if length(stimstartinds) ~= length(trialIDTMinds) %find different number of trialID textmarks than trialstart digmarks
    disp('we have an issue #3: number of stim starts does not equal number of trial textmarks. I dont know what to do, build better error fixing!');
    return
end

%Todo: some fancy check here that makes sure all trial times are about the same length - no crazy outliers

if verbose;fprintf(1,'done delimiting trials\n');end

%% Loop through trials and store trial info for each

for trialnum = 1:size(stimstartinds,1)
    trials{trialnum,1} = infile;                                                                                                            %   TODO: get the raw datafile name - will need to pass the datafile into the subfile textmarks
    
    %get basic trial info - date,time,etc
    SubFileTMsBeforeTrial   = find(subfileTMtimes < DM.times(stimstartinds(trialnum)));                                                     %   find the subfile textmark index that is relevant to this trial
    currsubfile             = SubFileTMsBeforeTrial(end);                                                                                   %   find the subfile textmark index that is relevant to this trial
    trials{trialnum,2}      = subfiledate{currsubfile};                                                                                     %   date of subfile and thus the trial
    trials{trialnum,3}      = subfilesecondssincemidnight(currsubfile) + (DM.times(stimstartinds(trialnum)) - subfileTMtimes(currsubfile)); %   SECONDS SINCE MIDNIGHT for trial
    trials{trialnum,4}      = DM.times(stimstartinds(trialnum)) - subfileTMtimes(currsubfile);                                              %   time relative to subfile start
    
    %set trial start/stop times
    if trialnum == 1
        startOffset = -2;                                                                                                                   %	-2 given by trigger settings in the .smr file during recording itself
    else
    startOffset             = max(-2,DM.times(trialendinds(trialnum-1))-DM.times(stimstartinds(trialnum)));                                 %	avoids assigning two TM to same trial, as well as double counting spikes - this ensures each spike belongs to one trial
    end
    endOffset               = DM.times(trialendinds(trialnum))-DM.times(stimstartinds(trialnum));                                           %	this is an easy default
    trials{trialnum,5}      = [startOffset endOffset];                                                                                      %   range of available data all relative to stim start (0 seconds) - use these to limit wavemark search
    
    %save textmark data
    currTMind = trialIDTMinds(DM.times(stimstartinds(trialnum))+startOffset <= TM.times(trialIDTMinds) & TM.times(trialIDTMinds) <= DM.times(stimstartinds(trialnum))+endOffset); %add 0.5 second pad around start and end of trial to look for textmarks - sometimes they're out of place only slightly
    if isempty(currTMind);
        fprintf(1,'problem with trial %d. Can''t find a textmark!\n',trialnum);end;
    if length(currTMind)>1; 
        fprintf(1,'problem with trial %d. found multiple textmarks!!\n',trialnum);end;
    
    currTMtext          = TM.text(currTMind,:);
    currTMcodes         = TM.codes(currTMind,:);
    trials{trialnum,6}  = deblank(currTMtext);                                                                                              %   stimName
    trials{trialnum,7}  = currTMcodes;                                                                                                      %   stimCodes
    
    %save keyboard marker data
    keyinds = find(DM.times(stimstartinds(trialnum))+startOffset <= KB.times & KB.times <= DM.times(stimstartinds(trialnum))+endOffset);    %   keyboard markers that occur within trial range
    trials{trialnum,8}.times = KB.times(keyinds)-DM.times(stimstartinds(trialnum));                                                         %   keyboard marker times, codes
    trials{trialnum,8}.codes = KB.codes(keyinds,:);                                                                                         %   keyboard marker times, codes
    
    %save digmark data
    diginds = find(DM.times(stimstartinds(trialnum))+startOffset <= DM.times & DM.times <= DM.times(stimstartinds(trialnum))+endOffset);    %   digimarks that occur within trial range
    trials{trialnum,9}.times = DM.times(diginds)-DM.times(stimstartinds(trialnum));                                                         %   digimark times
    trials{trialnum,9}.codes = DM.codes(diginds,:);                                                                                         %   digimark codes
end
%GOOD TO HERE
%% Format for Output - Each Unit gets it's own struct
totNumUnits = 0;
for wmChannum = 1:numWMs
    if verbose;fprintf(1,'wmchannum = %d\n',wmChannum);end
    
    WM{wmChannum}.markers = unique(WM{wmChannum}.codes(:,1));
    
    for markerNum = 1:length(WM{wmChannum}.markers);
        if verbose;fprintf(1,'markernum = %d\n',markerNum);end
        if WM{wmChannum}.markers(markerNum) ~= 0 && WM{wmChannum}.markers(markerNum) ~= 255 %shouldn't be by the time they're exported, but can't hurt to double check
            totNumUnits = totNumUnits+1;
            Units(totNumUnits)                              = struct('subject',[],'site',[],'pen',[],'marker',[],'trials',[],'stims',[],'info',[]);
            
            Units(totNumUnits).marker                       = WM{wmChannum}.markers(markerNum);
            
            Units(totNumUnits).trials                       = trials;
            
            Units(totNumUnits).info.s2MATfile               = infile;
            Units(totNumUnits).info.trialinds               = ones(size(Units(totNumUnits).trials,1),1); %trial inds (for now all, but will be modified if this is ever concatenated with another session - see processs2MATlibStruct())
            %Units(totNumUnits).info.filecomment            = Information.filecomment;
            %Units(totNumUnits).info.WMchannelNum           = str2num(Channel(WM{wmChannum}.ChanNum_inS2chet).Chan_inSpike2);
            Units(totNumUnits).info.WMchantitle             = WM{wmChannum}.title;
            Units(totNumUnits).info.WMchancomment           = WM{wmChannum}.comment;
            Units(totNumUnits).info.WMchanresolution        = WM{wmChannum}.resolution;
            Units(totNumUnits).info.WMchaninterval          = WM{wmChannum}.interval;
            Units(totNumUnits).info.WMscale                 = WM{wmChannum}.scale;
            Units(totNumUnits).info.WMoffset                = WM{wmChannum}.offset;
            Units(totNumUnits).info.WMunits                 = WM{wmChannum}.units;
            Units(totNumUnits).info.WMnumPointsPerWavemark  = WM{wmChannum}.items;
            Units(totNumUnits).info.WMnumPreTriggerPoints   = WM{wmChannum}.trigger;
            Units(totNumUnits).info.WMtraces                = WM{wmChannum}.traces;
            Units(totNumUnits).info.sortquality             = [];
            
            
            %now for the fun part - make spike toes
            for trialnum = 1:size(Units(totNumUnits).trials,1)
                startOffset = Units(totNumUnits).trials{trialnum,5}(1);
                endOffset =  Units(totNumUnits).trials{trialnum,5}(2);
                wminds_logical = DM.times(stimstartinds(trialnum))+startOffset <= WM{wmChannum}.times & WM{wmChannum}.times <= DM.times(stimstartinds(trialnum))+endOffset & WM{wmChannum}.codes(:,1) == Units(totNumUnits).marker;
                Units(totNumUnits).trials{trialnum,10} = WM{wmChannum}.times(wminds_logical) - DM.times(stimstartinds(trialnum));
                if readSpikeShapes == 1
                    Units(totNumUnits).trials{trialnum,11} = WM{wmChannum}.values(wminds_logical,:,:);
                end
            end
            Units(totNumUnits).stims = SM_getstims(Units(totNumUnits)); %get stims and their row indexes in the 'trials' cellarray
            
        else
            if verbose;fprintf(1,'found undesired wavemark marker %d\n',WM{wmChannum}.markers(markerNum));end
        end
    end
end

%% Try to grab subject, penetration, site, and session info from filecomments and/or infile name
%if infile is the full path, these will almost always be supplied

subjectid   = regexp(strrep(infile,'\','/'),'st\d{3}','match','once');
pen         = regexp(strrep(infile,'\','/'),'Pen.+_Site.+/','match','once');
pen         = pen(1:end-14);
% if isempty(pen)
%     pen        = regexp(strrep(infile,'\','/'),'pen\d\d','match','once');   %try to grab just site number
%     pen        = pen(end-1:end);
% end
site        = regexp(strrep(infile,'\','/'),'Site\d+_Z\d+','match','once'); %try to grab full site info ('##Z###')
% if isempty(site)
%     site        = regexp(strrep(infile,'\','/'),'site\d\d','match','once');   %try to grab just site number
%     site        = site(end-1:end);
% end

for unitnum = 1:totNumUnits
    if ~isempty(subjectid)
        Units(unitnum).subject = subjectid;
    end
    if ~isempty(pen)
        Units(unitnum).pen = pen;
    end
    if ~isempty(site)
        Units(unitnum).site = site;
    end
end

if isempty(subjectid) || isempty(site) || isempty(pen)
    fprintf(1,'WARNING: one or more of subject, site, or pen was not set\n');
end

%% function end
if verbose;fprintf(1,'done!\n');end
end




