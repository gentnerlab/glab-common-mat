function [toes rastcodes yvals] = SM_get_toescodesyvals(desTrials,varargin)
%[toes codes yvals] = SM_get_toescodesyvals(desTrials)
%

%% deal with varargin
if isempty(varargin)
    startTimeCode = 'beginrange';
    endTimeCode = 'endrange';
    zeroTimeReferenceCode = '<';
else
    ind = 1;
    while ind <= length(varargin)
        if ischar(varargin{ind})
            switch lower(varargin{ind})
                case {'startTimeCode'}
                    startTimeCode = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'endTimeCode'}
                    endTimeCode = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'zeroTimeReferenceCode'}
                    zeroTimeReferenceCode = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'ymode'}
                    ymode = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                otherwise
                    error('don''t know what to do with input: %s',varargin{ind});
            end
        end
        ind=ind+1;
    end
end

if ~exist('startTimeCode','var')
    startTimeCode = 'beginrange';
end

if ~exist('endTimeCode','var')
    endTimeCode = 'endrange';
end

if ~exist('zeroTimeReferenceCode','var')
    zeroTimeReferenceCode = '<';
end

if ~exist('ymode','var')
    ymode = 'repnum';
end

%%

passivetrials = SM_trialispassive(desTrials);

[windowedspikes codes] = SM_windowspikes4(desTrials,startTimeCode,endTimeCode,zeroTimeReferenceCode);

for i = 1:size(windowedspikes,1)
    stimstarttime(i,1) = SM_get_trial_stimstarttime(desTrials(i,:)) - codes.zeroTimes(i);
    stimendtime(i,1) = SM_get_trial_stimendtime(desTrials(i,:)) - codes.zeroTimes(i);
    
    [peckcodes{i} pecktimes{i}] = SM_get_trial_codes(desTrials(i,:));%,double(['C' 'c' 'R' 'r' 'L' 'l'])');
    pecktimes{i} = pecktimes{i} - codes.zeroTimes(i);
    
    toes{i,1} = [windowedspikes{i,1};stimstarttime(i);stimendtime(i);pecktimes{i}];
    rastcodes{i,1} = [2*ones(size(windowedspikes{i,1},1),1)-passivetrials(i);double('<');double('>');peckcodes{i}];
end

switch ymode
    case 'repnum'
        yvals=1:size(toes,1);
    case {'minutessincemidnight'}
        for j = 1:size(desTrials,1)
            yvals(j) = desTrials{j,3};
        end
    case {'reltime' 'time'}
        for j = 1:size(desTrials,1)
            yvals(j) = desTrials{j,3};
        end
        yvals = yvals-yvals(1)+1;
    otherwise
end


end