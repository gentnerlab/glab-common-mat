function ispassive = SM_trialispassive(trials)
% ISPASSIVE = SM_trialispassive(TRIALS)
% will return true for passive trials and false for engaged trials
% works on arrays of trials

for i = 1:size(trials,1)
ispassive(i,1) = strcmp(trials{i,12},'p');
end

end