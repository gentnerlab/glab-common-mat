function [template waveforms info] = SM_extractwaveforms(s2matfilename,markercode,doplot)

if ~exist('doplot','var')
    doplot = 0;
end

%export as matlab file from spike2

% s2matfilename = 'D:\SpikeMatlabSwap\tmp.mat';
%
% s2matfilename = 'Z:\experiments\analysis\loadedintoDB\st529\catfiles\Pen05_Lft_AP2450_ML600__Site28_Z2593\st529_cat_P05_S28_NOB_Marker001_s2MAT.mat';

if exist(s2matfilename,'file')==2
    S=load(s2matfilename);
elseif exist(strrep(s2matfilename,'Z:\','D:\'),'file')==2 %if can't find on newlintu (getdanroot()) server look for it on ibon D drive
    S=load(strrep(s2matfilename,'Z:\','D:\'));
else
    error(sprintf('no file: %s\nDo you need to rename it in the database?',s2matfilename))
end

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

%find wavemark channel
thisone = [];
for wn = 1:length(WM)
    currcodes = unique(WM{wn}.codes(:,1));
    wmmarkercodes{wn} = currcodes;
    if any(currcodes == markercode)
        thisone = [thisone, wn];
    end
end

if isempty(thisone)
    fprintf(1,'ERROR: markercode: %d not found in this file',markercode);
    waveforms = [];
    return
end

if length(thisone) ~= 1
    fprintf(1,'ERROR: found multiple markercode: %d in this file',markercode);
    waveforms = [];
    return
end

waveforms = WM{thisone}.values(WM{thisone}.codes(:,1)==markercode,:,:);
%info =


WS = size(waveforms);
if length(WS) == 3
    catwf = reshape(waveforms,WS(1),WS(2)*WS(3));
else
    catwf = waveforms;
end

template = mean(catwf);

if doplot
    stdtemplate = std(catwf);
    
    figure
    hold on
    
    %plot all spikes
    plot(catwf','color',[.8 .8 .8]);
    
    %plot std
    jbfill(1:length(stdtemplate),template+stdtemplate,template-stdtemplate,[.5 .5 .5],[.5 .5 .5],1,1);
    
    %plot average spike
    plot(template,'color','k','linewidth',3);
    
end

end