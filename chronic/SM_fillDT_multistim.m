function desTrials = SM_fillDT_multistim(unit,stimID)
%desTrials = SM_fillDT_multistim(unit,stimID)
%
%desTrials = cell(length(stimID),1)


desTrials = cell(length(stimID),1);
for i = 1 :length(stimID)
    desTrials{i,1} = picktrials(unit,'stim',stimID(i));
end