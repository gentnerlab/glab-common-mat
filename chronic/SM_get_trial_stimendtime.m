function trialendtime = SM_get_trial_stimendtime(trial)

trialendtime = trial{1,9}.times(trial{1,9}.codes(:,1) == double('>'));

end