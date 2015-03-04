function trialstarttime = SM_get_trial_stimstarttime(trial)

trialstarttime = trial{1,9}.times(trial{1,9}.codes(:,1) == double('<'));

end