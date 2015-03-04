function [windowedspikes codes] = SM_windowspikes4(desTrials,startTimeCode,endTimeCode,zeroTimeReferenceCode,StartEndRelativetoNewZero)
%[windowedspikes codes] = windowSpikes4(DESTRIALS,STARTIMECODE,ENDIMECODE,ZEROTIMEREFERENCECODE,STARTENDRELATIVETONEWZERO)
%
% windowspikes returns the spikes
%
%DESTRIALS should be a cell array of trials
%
%STARTIMECODE can be:
%   a 1 character string   	corresponding to a digimark code
%   a scalar                this will be used as the start window time for all trials (relative to the default time reference, stimulus start, given by the code '<')
%   a vector                you must supply a different start time for each of desTrials (relative to the default time reference, stimulus start, given by the code '<')
%                           spike times will be referenced to the 'start' value given for each trial
%                           if used, 'endTimeCode' must be a vector of the same size
%   'beginrange'          	this will use the value of trials{trialnum,5}(1)  -- the time after which spikes were included from the datafile
%   'ss###'                 this will use the start time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss-1.23' would use 1.23 seconds before the stimulus onset as the start value
%   'se###'                 this will use the end time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss+0.8' would use 0.8 seconds after the
%                           stimulus offset as the start value
%
%ENDIMECODE can be:
%   a 1 character string   	corresponding to a digimark code
%   a numerical value      	this will be used as the end window time for all trials (relative to the default time reference, stimulus start, given by the code '<')
%   a vector                you must supply a different stop time for each of desTrials (relative to the default time reference, stimulus start, given by the code '<')
%                           if used, 'startTimeCode' must be a vector of the same size and spike times will be referenced to the 'startTimeCode' value given for each trial
%   'endrange'            	this will use the value of trials{trialnum,5}(2)  -- the time before which spikes were included from the datafile
%   'ss###'                 this will use the start time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss-1.23' would use 1.23 seconds before the stimulus onset as the end value
%   'se###'                 this will use the end time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss+0.8' would use 0.8 seconds after the stimulus offset as the end value
%
%ZEROTIMEREFERENCECODE can be:
%   blank (default)         the default value is '<' and the spike times will not be rereferenced, unless start and stop are both vectors
%   a 1 character string   	corresponding to a digimark code
%   a scalar                the zero reference time for all trials (relative to the zero time reference given by STARTENDRELATIVETONEWZERO)
%   a vector                the zero reference time for each trial (relative to the default time reference (stimulus start, given by the code '<')
%   'beginrange'           	this will use the value of trials{trialnum,5}(1)  -- the time after which spikes were included from the datafile
%   'endrange'              this will use the value of trials{trialnum,5}(2)  -- the time before which spikes were included from the datafile
%   'ss###'                 this will use the start time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss-1.23' would use 1.23 seconds before the stimulus onset as the zero reference value
%   'se###'                 this will use the end time of the stimulus + ### seconds, where ### is a string value that can be converted to a double
%                           eg. 'ss+0.8' would use 0.8 seconds after the stimulus offset as the zero reference value
%
%STARTENDRELATIVETONEWZERO can be:
%   blank, 0 (default)      The start time and end time given by STARTIMECODE and ENDTIMECODE are relative to the native time as stored in DESTRIALS (ie times relative
%                           to stimulus onset). This allows for setting windows whose times correspond to event times that are zeroed to something besides
%                           the ZEROTIMEREFERENCECODE (eg motif onsets, offsets).
%   1                       The start time and end time given by STARTIMECODE and ENDTIMECODE are applied after the spike times are recalculated according
%                           to ZEROTIMEREFERENCECODE. This allows for setting windows that are a certain absolute time before and after a certain event.

if nargin < 5;              StartEndRelativetoNewZero   = 0;	end     %The start time and end time given by STARTIMECODE and ENDTIMECODE are relative to the native time as stored in DESTRIALS
if nargin < 4;              zeroTimeReferenceCode       = '<';	end     %'<' stimstart - this is the default used by reads2mat() to reference spike times to

if size(desTrials,1) == 1 && size(desTrials,2)==1
    desTrials=desTrials{1};
end

%% Check for possible Errors
if StartEndRelativetoNewZero == 1
    if ischar(startTimeCode) || ischar(endTimeCode) || (ischar(zeroTimeReferenceCode) && ~strcmp(zeroTimeReferenceCode,'<'))
        beep()
        disp('******')
        disp('******')
        warning('STARTENDRELATIVETONEWZERO == 1 and one of: STARTTIMECODE, ENDTIMECODE, ZEROTIMEREFERENCECODE is of class ''char''\nIt is very likely that this will produce undesired behavior, please check');
        disp('******')
        disp('******')
    end
end

%% setup variables
windowedspikes = cell(size(desTrials,1),2);
starttime = NaN(size(desTrials,1),1);
endtime = NaN(size(desTrials,1),1);
zeroTimes = NaN(size(desTrials,1),1);

%% decode startTimeCode
if ischar(startTimeCode)
    if length(startTimeCode) == 1                   %user has entered a single character string which is interpreted as a digimark code
        starttimetype = 'digmarkcode';
    else                                            %user has entered one of the special strings described in the help section
        starttimetype = 'specialstring';
    end
elseif isnumeric(startTimeCode)
    if length(startTimeCode) == 1                   %user has entered a scalar value which will be used for all trials
        starttimetype = 'scalar';
    else                                            %user has entered a vector value which will be used for all trials
        starttimetype = 'vector';
    end
end
%
%% decode endTimeCode
if ischar(endTimeCode)
    if length(endTimeCode) == 1                     %user has entered a single character string which is interpreted as a digimark code
        endtimetype = 'digmarkcode';
    else                                            %user has entered one of the special strings described in the help section
        endtimetype = 'specialstring';
    end
elseif isnumeric(endTimeCode)
    if length(endTimeCode) == 1                     %user has entered a scalar value which will be used for all trials
        endtimetype = 'scalar';
    else                                            %user has entered a vector value which will be used for all trials
        endtimetype = 'vector';
    end
end
%
%% decode zeroTimeReferenceCode
if ischar(zeroTimeReferenceCode)
    if length(zeroTimeReferenceCode) == 1           %user has entered a single character string which is interpreted as a digimark code
        zerotimetype = 'digmarkcode';
    else                                            %user has entered one of the special strings described in the help section
        zerotimetype = 'specialstring';
    end
elseif isnumeric(zeroTimeReferenceCode)
    if length(zeroTimeReferenceCode) == 1           %user has entered a scalar value which will be used for all trials
        zerotimetype = 'scalar';
    else                                            %user has entered a vector value which will be used for all trials
        zerotimetype = 'vector';
    end
end
%

%% loop through trials, get proper start, end, zero values then window spikes
for trialNum  = 1:size(desTrials,1)
    
    %% get start time for windowing current trial
    switch starttimetype
        case 'digmarkcode'
            starttime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == double(startTimeCode));
        case 'specialstring'
            switch lower(startTimeCode)
                case {'beginrange','startrange'}
                    starttime(trialNum) = desTrials{trialNum,5}(1);
                otherwise
                    if strcmp(startTimeCode(1:2),'ss')
                        stimstartplus = str2double(startTimeCode(3:end));
                        starttime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 60);
                        starttime(trialNum) = starttime(trialNum)+stimstartplus;
                    else
                        if strcmp(startTimeCode(1:2),'se')
                            stimendplus = str2double(startTimeCode(3:end));
                            starttime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 62);
                            starttime(trialNum) = starttime(trialNum)+stimendplus;
                        else
                            error('I don''t know what to do with a startTimeCode of %s',startTimeCode)
                        end
                    end
            end
        case 'scalar'
            starttime(trialNum) = startTimeCode;
        case 'vector'
            starttime(trialNum) = startTimeCode(trialNum);
    end
    %
    %% get end time for windowing current trial
    switch endtimetype
        case 'digmarkcode'
            endtime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == double(endTimeCode));
        case 'specialstring'
            switch lower(endTimeCode)
                case {'endrange'}
                    endtime(trialNum) = desTrials{trialNum,5}(2);
                otherwise
                    if strcmp(endTimeCode(1:2),'ss')
                        stimstartplus = str2double(endTimeCode(3:end));
                        endtime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 60);
                        endtime(trialNum) = endtime(trialNum)+stimstartplus;
                    else
                        if strcmp(endTimeCode(1:2),'se')
                            stimendplus = str2double(endTimeCode(3:end));
                            endtime(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 62);
                            endtime(trialNum) = endtime(trialNum)+stimendplus;
                        else
                            error('I don''t know what to do with a endTimeCode of %s',endTimeCode)
                        end
                    end
            end
        case 'scalar'
            endtime(trialNum) = endTimeCode;
        case 'vector'
            endtime(trialNum) = endTimeCode(trialNum);
    end
    %
    %% get zero time for referencing current trial
    switch zerotimetype
        case 'digmarkcode'
            zeroTimes(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == double(zeroTimeReferenceCode));
        case 'specialstring'
            switch lower(zeroTimeReferenceCode)
                case {'beginrange'}
                    zeroTimes(trialNum) = desTrials{trialNum,5}(1);
                case {'endrange'}
                    zeroTimes(trialNum) = desTrials{trialNum,5}(2);
                otherwise
                    if strcmp(zeroTimeReferenceCode(1:2),'ss')
                        stimstartplus = str2double(zeroTimeReferenceCode(3:end));
                        zeroTimes(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 60);
                        zeroTimes(trialNum) = zeroTimes(trialNum)+stimstartplus;
                    else
                        if strcmp(zeroTimeReferenceCode(1:2),'se')
                            stimendplus = str2double(zeroTimeReferenceCode(3:end));
                            zeroTimes(trialNum) = desTrials{trialNum,9}.times(desTrials{trialNum,9}.codes(:,1) == 62);
                            zeroTimes(trialNum) = zeroTimes(trialNum)+stimendplus;
                        else
                            error('I don''t know what to do with a zeroTimeReferenceCode of %s',zeroTimeReferenceCode)
                        end
                    end
            end
        case 'scalar'
            zeroTimes(trialNum) = zeroTimeReferenceCode;
        case 'vector'
            zeroTimes(trialNum) = zeroTimeReferenceCode(trialNum);
    end
    %
    %% Window and Reference
    if StartEndRelativetoNewZero == 0
        
        % watch out for a couple of things
        if desTrials{trialNum,5}(1) > starttime(trialNum)
            warning('You have selected a start time before the beginning of recording for the current trial\ttrialNum=%d\nDO NOT USE THIS DATA TO CALCULATE SPIKE RATES',trialNum);
            beep
        end
        if desTrials{trialNum,5}(2) < endtime(trialNum)
            warning('You have selected an end time after the end of recording for the current trial.\ttrialNum=%d\nDO NOT USE THIS DATA TO CALCULATE SPIKE RATES',trialNum);
            beep
        end
        
        spikes = desTrials{trialNum,10};
        spikes = spikes(spikes > starttime(trialNum) & spikes < endtime(trialNum)); %window the spikes to be between starttime(trialNum) and endtime(trialNum), relative to the time of '<'
        spikes = spikes - zeroTimes(trialNum); %adjust the spiketimes to reflect the desired zeroTime
        
        windowedspikes{trialNum,1} = spikes;
        
        timeinterval = endtime(trialNum)-starttime(trialNum);  %get the time over which spikes are returned
        windowedspikes{trialNum,2} = timeinterval;
        
    elseif StartEndRelativetoNewZero == 1
        
        % watch out for a couple of things
        if desTrials{trialNum,5}(1) > starttime(trialNum) - zeroTimes(trialNum);
            warning('You have selected a start time before the beginning of recording for the current trial\ttrialNum=%d\nDO NOT USE THIS DATA TO CALCULATE SPIKE RATES',trialNum);
            beep
        end
        if desTrials{trialNum,5}(2) < endtime(trialNum) - zeroTimes(trialNum);
            warning('You have selected an end time after the end of recording for the current trial.\ttrialNum=%d\nDO NOT USE THIS DATA TO CALCULATE SPIKE RATES',trialNum);
            beep
        end
        
        spikes = desTrials{trialNum,10};
        spikes = spikes - zeroTimes(trialNum); %adjust the spiketimes to reflect the desired zeroTime
        spikes = spikes(spikes > starttime(trialNum) & spikes < endtime(trialNum)); %window the spikes to be between starttime(trialNum) and endtime(trialNum), relative to the desired zero time
        
        windowedspikes{trialNum,1} = spikes;
        
        timeinterval = endtime(trialNum)-starttime(trialNum);  %get the time over which spikes are returned
        windowedspikes{trialNum,2} = timeinterval;
        
    else
        error('huh??');
    end
end

%% format output
codes.startTimeCode = startTimeCode;
codes.endTimeCode = endTimeCode;
codes.zeroTimeReferenceCode = zeroTimeReferenceCode;
codes.starttimes = starttime;   %relative to '<' in each trial
codes.endtimes = endtime;       %relative to '<' in each trial
codes.zeroTimes = zeroTimes;    %relative to '<' in each trial

end
