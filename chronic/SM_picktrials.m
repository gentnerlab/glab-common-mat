function [desiredTrials, desiredTrialsInds] = SM_picktrials(Unit,varargin)
%desiredTrials = pickTrials(Unit,varargin)
%
%use varargin in like so: pickTrials(Unit,'category',value,'category',value...)
%ex: pickedTrials = pickTrials(Unit,'stims',[1,2],'condition',{'engaged'})
%
%allowed values in varargin:
% 'stim'        can be either a stimulus index or a cell array of strings
%               will return trials of all given stim values
% 'condition'   can be either a condition index or a cell array of strings
%               will return trials of all given condition values
% 'consequence'   should be a string of desired column 12 values


%% deal with varargin
if isempty(varargin)
    %someone wants all the trials!
    desiredTrials = Unit.trials;
    desiredTrialsInds = ones(size(Unit.trials,1),1);
    return
else
    ind = 1;
    while ind <= length(varargin)
        if ischar(varargin{ind})
            switch lower(varargin{ind})
                case {'stim','stimulus','stimuli','stims'}
                    stim = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'consequence','result'}
                    trialconsequence = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'condition','conditions','cond','conds'}
                    condition = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                otherwise
                    error('don''t know what to do with input: %s',varargin{ind});
            end
        end
        ind=ind+1;
    end
end

%% do the logic

desiredTrialsInds = ones(size(Unit.trials,1),1);        %start with ones for 'and'


if exist('stim','var')
    if ischar(stim); stim = {stim}; end
    
    desiredStimInds = zeros(size(Unit.trials,1),1);                   %start with zeros for 'or'
    if iscellstr(stim) %works if you enter the name of the stim as a cell string
        for i = 1:length(stim)                 %loop through and 'or' all values
            %             currstimind = find(ismember({Unit.stims{:,1}},stim{i}));
            %             if currstimind
            %                 desiredStimInds = desiredStimInds | Unit.stims{currstimind,2};
            %             end
            currstimind = strmatch(stim{i},Unit.stims(:,1));
            for j = 1:length(currstimind)
                desiredStimInds = desiredStimInds | Unit.stims{currstimind(j),2};
            end
        end
        desiredTrialsInds = desiredTrialsInds & desiredStimInds;     %now 'and' the stim results with everything else
    else
        for i = 1:length(stim)
            if stim(i) <= size(Unit.stims,1)
                desiredStimInds = desiredStimInds | Unit.stims{stim(i),2}; %or (select any)
            else
                warning('one of the requested stim indices is out of range');
            end
        end
        desiredTrialsInds = desiredTrialsInds & desiredStimInds;     %now 'and' the subject results with everything else
    end
end


if exist('condition','var')
    if ischar(condition)
        tmp = {condition};
        clear condition;
        condition = tmp;
        clear tmp;
    end
    desiredCondInds = zeros(size(Unit.trials,1),1);                   %start with zeros for 'or'
    if iscellstr(condition) %works if you enter the name of the stim as a cell string
        for i = 1:length(condition)                 %loop through and 'or' all values
            currcondind = find(ismember(Unit.conditions(:,1),condition{i}));
            if currcondind
                desiredCondInds = desiredCondInds | Unit.conditions{currcondind,2};
            end
        end
        desiredTrialsInds = desiredTrialsInds & desiredCondInds;     %now 'and' the stim results with everything else
    else
        for i = 1:length(condition)
            if condition(i) <= size(Unit.conditions,1)
                try
                    desiredCondInds = desiredCondInds | Unit.conditions{condition(i),2}; %or (select any)
                catch
                    if condition(i) > 100
                        error('condition number is greater than 100 -- did you forget to put the string(s) in a cell?');
                    end
                end
            else
                warning('one of the requested condition indices is out of range');
            end
        end
        desiredTrialsInds = desiredTrialsInds & desiredCondInds;     %now 'and' the subject results with everything else
    end
end



if exist('trialconsequence','var')
    desiredconseqInds = zeros(size(Unit.trials,1),1);                   %start with zeros for 'or'
    for i = 1:length(trialconsequence)
        currinds = [Unit.trials{:,12}] == trialconsequence(i);
        desiredconseqInds = desiredconseqInds | currinds'; %or (select any)
    end
    desiredTrialsInds = desiredTrialsInds & desiredconseqInds;     %now 'and' the results with everything else
end


%% index out the trials of interest

desiredTrials = Unit.trials(desiredTrialsInds,:);

end