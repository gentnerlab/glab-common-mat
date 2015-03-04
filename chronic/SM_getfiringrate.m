function [meanFR FR stdFR] = SM_getfiringrate(desTrials,starttimecode,endtimecode)
%[meanFR FR] = SM_getfiringrate(desTrials,starttimecode,endtimecode)
%
%starttimecode defaults to '<'
%endtimecode defaults to '>'
%starttimecode and enddtimecode can take any value that windowspikes() can
%take
% meanFR gives the mean firing rate over all trials
%FR gives some metadata (value for each trial, stdev, timerange, etc);

if ischar(desTrials{1}); desTrials = {desTrials}; end   %if desTrials is itself just a cell array of trials, wrap it in a cell
if nargin < 3; endtimecode   = '>'; end;                %'>' default will be stim end
if nargin < 2; starttimecode = '<'; end;                %'<' default will be stim start


allFR = cell(length(desTrials),1);
meanFR = NaN(length(desTrials),1);
stdFR = NaN(length(desTrials),1);
stderrFR = NaN(length(desTrials),1);
timerange = cell(length(desTrials),1);

for dtNum = 1:length(desTrials)
    windowedspikes{dtNum} = SM_windowspikes4(desTrials{dtNum},starttimecode,endtimecode);

    spikecounts = cellfun(@(x) length(x),windowedspikes{dtNum}(:,1));
    timerange{dtNum} = [windowedspikes{dtNum}{:,2}]';
    
    allFR{dtNum} = spikecounts./timerange{dtNum};
    
    meanFR(dtNum) = mean(allFR{dtNum});
    stdFR(dtNum) = std(allFR{dtNum});
    stderrFR(dtNum) = std(allFR{dtNum})/(sqrt(length(allFR{dtNum})));
end

if length(desTrials) == 1
    allFR = cell2mat(allFR);
    timerange = cell2mat(timerange);
end

FR.mean = meanFR;
FR.std = stdFR;
FR.stderr = stderrFR;
FR.allFR = allFR;
FR.timerange = timerange;

end