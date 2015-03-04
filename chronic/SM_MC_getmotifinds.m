function inds = SM_MC_getmotifinds(Unit,motifname,varargin)
%inds = SM_MC_getmotifinds(Unit,motifname,varargin)
%varargin can be:
%place,first,notfirst,last,notlast,respondlikemotifclass,-respondlikemotifc
%lass,condition
%% get motif indices

if ~isfield(Unit,'motif')
    Unit = SM_makemotifstruct(Unit);
end

if ischar(motifname)
    motifindex = find(strcmp(Unit.motif.exemplars(:,1),motifname));
elseif isnumeric(motifname)
    motifindex = motifname;
    motifname = Unit.motif.exemplars{motifindex,1};
end

motinds = ~cellfun('isempty',Unit.motif.byexemp.time(motifindex,:));



%% deal with varargin
if isempty(varargin)
    %someone wants all the trials!
    desInds = true(length(motinds),1);
else
    ind = 1;
    while ind <= length(varargin)
        if ischar(varargin{ind})
            switch lower(varargin{ind})
                case {'place'}
                    desplace = varargin{ind+1};
                    ind=ind+1; %skip next value (we already assigned it!)
                case {'first'}
                    firstselected = 1;
                    firstplace = 1;
                case {'notfirst'}
                    firstselected = 1;
                    firstplace = -1;
                case {'last'}
                    lastselected = 1;
                    lastplace = 1;
                case {'notlast'}
                    lastselected = 1;
                    lastplace = -1;
                case {'middle'}
                    middleselected = 1;
                    firstplace = -1;
                    lastplace = -1;
                case {'respondlikemotifclass'}
                    respondlikemotifclass = 1;
                case {'-respondlikemotifclass'}
                    respondlikemotifclass = 0;
                case {'condition'}
                    condition = varargin{ind+1};
                    if ~iscell(condition)
                        condition = {condition};
                    end
                    ind=ind+1; %skip next value (we already assigned it!)
                otherwise
                    error('don''t know what to do with input: %s',varargin{ind});
            end
        end
        ind=ind+1;
    end
end

if (exist('middleplace','var') && exist('firstselected','var')) || (exist('middleplace','var') && exist('lastselected','var'))
    error(sprintf('selecting ''middle'' with either ''last'' or ''first'' is likely to have weird effects - restructure your query\n''middle'' is really meant as a shorthand for ''notfirst'' and ''notlast'''));
end

desInds = true(length(motinds),1);

if exist('firstplace','var')
    firstplaceinds = false(length(motinds),1);
    for j = 1:length(motinds)
        firstplaceinds(j) = any(1 == Unit.motif.byexemp.place{motifindex,j});
    end
    if firstplace == 1
        desInds = desInds(:) & firstplaceinds(:);
    elseif firstplace == -1
        desInds = desInds(:) & ~firstplaceinds(:);
    end
end

if exist('lastplace','var')
    lastplaceinds = false(length(motinds),1);
    for j = 1:length(motinds)
        lastmotposition = length(Unit.motif.bytrial{j,1});
        lastplaceinds(j) = any(lastmotposition == Unit.motif.byexemp.place{motifindex,j});
    end
    if lastplace == 1
        desInds = desInds(:) & lastplaceinds(:);
    else
        desInds = desInds(:) & ~lastplaceinds(:);
    end
end

if exist('desplace','var')
    desplaceinds = false(length(motinds),1);
    for i = 1:length(desplace)
        for j = 1:length(motinds)
            desplaceinds(j) = any(desplace(i) == Unit.motif.byexemp.place{motifindex,j});
        end
        desInds = desInds(:) & desplaceinds(:);
    end
end

if exist('respondlikemotifclass','var')
    %fix the below for something not 2AC
    classresp{1} = 'L';
    classresp{2} = 'R';
    
    %Here's how I'm gonna hack this together
    %A. Get class of current motif - hard without list...
    %B. loop through trials
    %a. if trial is no result - then skip it
    %1. get class of current trial
    %2. if class of stim == class of motif then keep result of trial C or I
    %3. if class of stim ~= class of motif then flip result of trial
    
    %This is gonna be a bit of a hack and fail when the motif does not appear alone
    currmotaloneinds = SM_MC_getmotifinds(Unit,motifname,'first','last'); %calling function inside itself! AHH!!!!
%     if sum(currmotaloneinds)==0
%         currmotfirstinds = SM_MC_getmotifinds(Unit,motifname,'first'); %calling function inside itself! AHH!!!!
%         error('fixme - this motif does not ever appear alone')
%     else
%         aloneind = find(currmotaloneinds,1);
%         currmotclass = Unit.trials{aloneind,7}(2);
%     end
%     

    motclasses = SM_MC_getmotclasses(Unit.subject);
    currmotclassind = strmatch(motifname,motclasses(:,1),'exact');
    currmotclass = motclasses{currmotclassind,2};
    
    %
    respondlikemotifclassinds = false(length(motinds),1);
    for j = 1:length(motinds)
        if motinds(j)
            %         stimclass = Unit.trials{j,7}(2);
            %         flipresult = ~((stimclass == currmotclass) & respondlikemotifclass); %if true, then will toggle feed to timeout; if false, then will keep feed as feed and TO like TO
            %
            %         if (Unit.trials{j,12} == 'f') || (Unit.trials{j,12} == 'F') %FEED
            %             respondlikemotifclassinds(j) = ~flipresult;
            %         elseif (Unit.trials{j,12} == 't') || (Unit.trials{j,12} == 'T') %TIMEOUT
            %             respondlikemotifclassinds(j) = flipresult;
            %         end
            if Unit.trials{j,13} ~= 'p' && Unit.trials{j,13} ~= 'N'
                if respondlikemotifclass == 1
                    respondlikemotifclassinds(j) = Unit.trials{j,13} == classresp{currmotclass};
                elseif respondlikemotifclass == 0
                    respondlikemotifclassinds(j) = Unit.trials{j,13} ~= classresp{currmotclass};
                else
                    error('huh???')
                end
            end
            
        end
    end
    desInds = desInds(:) & respondlikemotifclassinds(:);
end

if exist('condition','var')
    for i = 1:length(condition)
        if ischar(condition{i})
            conditioninds = Unit.conditions{ismember(Unit.conditions(:,1),condition{i}),2};
        else
            conditioninds = Unit.conditions{condition{i},2};
        end
        desInds = desInds(:) & conditioninds(:);
    end
end


inds = motinds(:) & desInds(:);
end

