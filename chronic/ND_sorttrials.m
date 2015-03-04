function [trials trialindsout trialtimes] = ND_sorttrials(trials,sortmethod)
%[trials trialindsout] = ND_sorttrials(trials,sortmethod)
%SORTMETHOD         {'outcome' 'result' 'behavior' 'engpass'} sorts like: 'FfTtNp'
%                   (DEFAULT) {'relativetime' 'reltime' 'timeorder'}


%below is broken because ndege only has 1 minute reolution.... need to
%take order of trials into account
if nargin < 2;sortmethod='timeorder';end


switch lower(sortmethod)
    case {'relativetime' 'reltime' 'timeorder'}
        ttime = num2str(cell2mat(trials(:,10)));
        tdate = num2str(cell2mat(trials(:,11)));
        
        
        for tn = 1:size(trials,1)
            H(tn) = str2double(ttime(tn,1:2));
            MI(tn) = str2double(ttime(tn,3:4));
            
            Y(tn) = str2double(tdate(tn,1:4));
            MO(tn) = str2double(tdate(tn,5:6));
            D(tn) = str2double(tdate(tn,7:8));
        end
        
        S(1) = 0;
        tdn(1) = DATENUM(Y(1),MO(1),D(1),H(1),MI(1),S(1));
        k = 0;
        for tn = 2:size(trials,1) %use this loop to figure out S - THINK works, but need to check that get unique time values for each trial
            
            if (H(tn)==H(tn-1))&&(MI(tn)==MI(tn-1))&&(Y(tn)==Y(tn-1))&&(MO(tn)==MO(tn-1))&&(D(tn)==D(tn-1))
                k = k+1;
            else
                k = 0;
            end
            S(tn) = k;
            
            tdn(tn) = DATENUM(Y(tn),MO(tn),D(tn),H(tn),MI(tn),S(tn));
        end
        
        [trialtimes, theorder] = sort(tdn);
        
    case {'timeofday' 'tod'}
        error('TIMEOFDAY SORT: I''m not coded up yet - fix me!')
        
end

trialindsout = theorder;
trials = trials(trialindsout,:);

end