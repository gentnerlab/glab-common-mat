function [PickedUnits PickedUnitsInds] = SM_pickunits(Units,varargin)
%PickedUnits = pickUnits(Units,varargin)
%
%use varargin in like so: pickUnits(Units,'category',value,'category',value...)
%ex: pickedUnits = pickUnits(Units,'subject',{'st515'},'site',[25,32],'hasallCondition',{'passive','engaged'})
%
%allowed values in varargin:
% 'subject'             should be a cell array of strings (will 'or' all members of the cell array)
% 'pen'                 should be a cell array of strings (will 'or' all members of the cell array)
% 'site'                should be a cell array of strings (will 'or' all members of the cell array)
% 'hasanyCondition'     should be a cell array of strings (will 'or' all members of the cell array)
% 'hasallCondition'     should be a cell array of strings (will 'and' all members of the cell array)
% 'hasanyStim'          should be a cell array of strings (will 'or' all members of the cell array)
% 'hasallStim'          should be a cell array of strings (will 'and' all members of the cell array)
% 'sortquality'         should be of the form [lowsortval,highsortval]
% 'sortstd'             should be of the form [lowsortstd,highsortstd]

%% deal with varargin
ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'subject','sub'}
                subject = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'pen','penetration'}
                pen = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'site','sites'}
                site = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'marker','markers'}
                marker = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'hasanycondition','hasanyconditions','anycondition','anyconditions','anycond','anyconds'}
                hasCondition = varargin{ind+1};
                hasallCondition = 0;
                ind=ind+1; %skip next value (we already assigned it!)
            case {'hasallcondition','hasallconditions','allcondition','allconditions','allcond','allconds','hasallcond','hasallconds'}
                hasCondition = varargin{ind+1};
                hasallCondition = 1;
                ind=ind+1; %skip next value (we already assigned it!)
            case {'hasanystim','hasanystims','anystim','anystims','anycond','anyconds'}
                hasStim = varargin{ind+1};
                hasallStim = 0;
                ind=ind+1; %skip next value (we already assigned it!)
            case {'hasallstim','hasallstims','allstim','allstims','allcond','allconds'}
                hasStim = varargin{ind+1};
                hasallStim = 1;
                ind=ind+1; %skip next value (we already assigned it!)
            case {'sortquality','sort quality','sortqual','sortval','sortvalue','sort'}
                sortquality = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'sort std','sortstd'}
                sortstd = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

%% do the logic

desiredUnitsInds = ones(length(Units),1); %start with ones for 'and'

if exist('subject','var')
    desiredSubjectInds = zeros(length(Units),1);                %start with zeros for 'or'
    if iscellstr(subject)
        for i = 1:length(subject)                                   %loop through and 'or' all values
            desiredSubjectInds = desiredSubjectInds | ismember({Units.subject},subject{i})';
        end
        desiredUnitsInds = desiredUnitsInds & desiredSubjectInds;   %now 'and' the subject results with everything else
    else
        for i = 1:length(subject)
            desiredSubjectInds = desiredSubjectInds | ~cellfun('isempty',regexp({Units.subject},sprintf('st%03d',subject(i))))';
        end
        desiredUnitsInds = desiredUnitsInds & desiredSubjectInds;     %now 'and' the subject results with everything else
    end
end

if exist('pen','var')
    desiredPenInds = zeros(length(Units),1);                    %start with zeros for 'or'
    if iscellstr(pen)
        for i = 1:length(pen)                                       %loop through and 'or' all values
            desiredPenInds = desiredPenInds | ismember({Units.pen},pen{i})';
        end
        desiredUnitsInds = desiredUnitsInds & desiredPenInds;      %now 'and' the pen results with everything else
    else
        for i = 1:length(pen)
            desiredPenInds = desiredPenInds | ~cellfun('isempty',regexp({Units.pen},sprintf('Pen%02d',pen(i))))';
        end
        desiredUnitsInds = desiredUnitsInds & desiredPenInds;     %now 'and' the subject results with everything else
    end
end

if exist('site','var')
    desiredSiteInds = zeros(length(Units),1);                   %start with zeros for 'or'
    if iscellstr(site) %works if you enter the name of the site as a cell string
        for i = 1:length(site)                                      %loop through and 'or' all values
            desiredSiteInds = desiredSiteInds | ismember({Units.site},site{i})';
        end
        desiredUnitsInds = desiredUnitsInds & desiredSiteInds;     %now 'and' the subject results with everything else
    else %works if you enter the site ID as the number of the site - but be careful of weird formatting...as long as the regexp below works, you're fine
        for i = 1:length(site)
            desiredSiteInds = desiredSiteInds | ~cellfun('isempty',regexp({Units.site},sprintf('Site%02d',site(i))))';
        end
        desiredUnitsInds = desiredUnitsInds & desiredSiteInds;     %now 'and' the subject results with everything else
    end
end

if exist('marker','var')
    desiredMarkerInds = zeros(length(Units),1);                   %start with zeros for 'or'
    for i = 1:length(marker)
        desiredMarkerInds = desiredMarkerInds | ismember([Units.marker],marker(1))';
    end
    desiredUnitsInds = desiredUnitsInds & desiredMarkerInds;     %now 'and' the subject results with everything else
end

if exist('hasCondition','var')
    if hasallCondition
        desiredconditionInds = ones(length(Units),1);                   %start with ones for 'and'
    else
        desiredconditionInds = zeros(length(Units),1);                   %start with zeros for 'or'
    end
    for i = 1:length(hasCondition)                                      %loop through and 'or' all values
        for unitNum = 1:length(Units)
            currcondind = find(ismember(Units(unitNum).conditions(:,1),hasCondition{i}));
            if currcondind %does the unit even have the condition?
                if hasallCondition == 1
                    desiredconditionInds(unitNum) = desiredconditionInds(unitNum) & sum(Units(unitNum).conditions{currcondind,2})~=0;
                else %has any condition
                    desiredconditionInds(unitNum) = desiredconditionInds(unitNum) | sum(Units(unitNum).conditions{currcondind,2})~=0;
                end
            end
        end
    end
    desiredUnitsInds = desiredUnitsInds & desiredconditionInds;     %now 'and' the subject results with everything else
end

if exist('hasStim','var')
    if hasallStim
        desiredstimInds = ones(length(Units),1);                   %start with ones for 'and'
    else
        desiredstimInds = zeros(length(Units),1);                   %start with zeros for 'or'
    end
    for i = 1:length(hasStim)                                      %loop through and 'or' all values
        for unitNum = 1:length(Units)
            currstimind = find(~cellfun('isempty',strfind(Units(unitNum).stims(:,1),hasStim{i})));
            if currstimind %does the unit even have the stim?
                if hasallStim == 1
                    desiredstimInds(unitNum) = desiredstimInds(unitNum) & sum(Units(unitNum).stims{currstimind,2})~=0;
                else %has any stim
                    desiredstimInds(unitNum) = desiredstimInds(unitNum) | sum(Units(unitNum).stims{currstimind,2})~=0;
                end
            else
                desiredstimInds(unitNum) = 0;
            end
        end
    end
    desiredUnitsInds = desiredUnitsInds & desiredstimInds;     %now 'and' the subject results with everything else
end

if exist('sortquality','var')
    sqmat = SM_getsortqualmat(Units);
    desiredUnitsInds = desiredUnitsInds & sqmat(:,1) >= sortquality(1) & sqmat(:,1) <= sortquality(2) ;
end

if exist('sortstd','var')
    sqmat = SM_getsortqualmat(Units);
    desiredUnitsInds = desiredUnitsInds & sqmat(:,2) >= sortstd(1) & sqmat(:,2) <= sortstd(2) ;
end

%% index out the Units of interest

PickedUnits = Units(desiredUnitsInds);
PickedUnitsInds = desiredUnitsInds;

end

function sqmat = SM_getsortqualmat(Units)
%this function creates a (Numunitsx3) matrix of all the sort qualities in the supplied unit struct
sqmat = reshape(cell2mat({Units.sortquality}),3,length(Units))';
end
