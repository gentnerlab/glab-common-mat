function [digmarkcodes digmarktimes keyboardcodes keyboardtimes] = SM_get_trial_codes(trial,dmcode,kbcode)

dmcodes = trial{1,9}.codes;
dmtimes = trial{1,9}.times;

kbcodes = trial{1,8}.codes;
kbtimes = trial{1,8}.times;

if nargin >= 2
    %look for DMcode
    if size(dmcode,2) == 1
        
        dminds = [];
        for i = 1:length(dmcode)
            dminds = [dminds;find(dmcodes(:,1)==dmcode(i))];
        end
        dmcodes = dmcodes(dminds,1);
        dmtimes = dmtimes(dminds,1);
        
        [dmtimes,order] = sort(dmtimes);
        dmcodes = dmcodes(order,1);
    else
        if ~isempty(dmcode)
        error('Haven''t coded this up to use any more than the first digmark code')
        end
    end
end

if nargin >= 3
    %look for kbcode
    if size(kbcode,2) == 1
        kbinds = [];
        for i = 1:length(kbcode)
            kbinds = [kbinds;find(kbcodes(:,1)==kbcode(i))];
        end
        kbcodes = kbcodes(kbinds,1);
        kbtimes = kbtimes(kbinds,1);
        
        [kbtimes,order] = sort(kbtimes);
        kbcodes = kbcodes(order,1);
    else
        if ~isempty(kbcode)
        error('Haven''t coded this up to use any more than the first keyboard code')
        end
    end
end

digmarkcodes = dmcodes(:,1);
digmarktimes = dmtimes(:,1);

keyboardcodes = kbcodes(:,1);
keyboardtimes = kbtimes(:,1);

end