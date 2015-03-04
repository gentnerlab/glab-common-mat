function condind = SM_getind_condition(unit,condition)

if ischar(condition)
    condition = {condition};
end

for i = 1:length(condition)
    ind = find(ismember(unit.conditions(:,1),condition{i}));
    if ~isempty(ind)
        condind(i) = ind;
    else
        condind(i) = nan;
    end
end

end