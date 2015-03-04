function [minutessincemidnight hour minute] = ND_getlasttrialtime(ND_trials)

%% if given a subject name, read in trial data
if ischar(ND_trials)
    subjectfileID = ND_trials;
    ND_trials = ND_gettrials(subjectfileID);
end

[minutessincemidnight hour minute] = ND_gettime(ND_trials(end,:));

end