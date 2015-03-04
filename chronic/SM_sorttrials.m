function [trials trialindsout] = SM_sorttrials(trials,sortmethod)
%[trials trialindsout] = SM_sorttrials(trials,sortmethod)
%SORTMETHOD         {'outcome' 'result' 'behavior' 'engpass'} sorts like: 'FfTtNp'
%                   (DEFAULT) {'relativetime' 'reltime' 'timeorder'}

if nargin < 2;sortmethod='timeorder';end


switch lower(sortmethod)

    case {'outcome' 'result' 'behavior' 'engpass'}
        sortorder = ['FfTtNp'];
        [outcomes,theorder] = sortset([trials{:,12}],sortorder);
        for i = 1:length(outcomes)
            outcomecodes(i,1) = find(outcomes(i) == sortorder);
        end
        outcomecodes(outcomecodes == 2) = 1; %F = f
        outcomecodes(outcomecodes == 4) = 3; %T = t
        [zz,theorder] = sortrows([outcomecodes,stimstarttime(theorder),stimendtime(theorder)]);
        theorder = flipud(theorder);

    case {'relativetime' 'reltime' 'timeorder'}
        [zz,theorder] = sort([trials{:,3}]);
    case {'timeofday' 'tod' 'time'}
        error('TIMEOFDAY SORT: I''m not coded up yet - fix me!')
        
end

trialindsout = theorder;
trials = trials(trialindsout,:);

end