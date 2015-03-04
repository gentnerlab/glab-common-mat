function stimind = SM_getind_stimulus(unit,stimulus)

if ischar(stimulus)
    stimulus = {stimulus};
end

for i = 1:length(stimulus)
    ind = find(ismember(unit.stims(:,1),stimulus{i}));
    if ~isempty(ind)
        stimind(i) = ind;
    else
        stimind(i) = nan;
    end
end

end