function desTrials = SM_fillDT_EP_stim(unit,stimID)
%desTrials = SM_fillDT_EP_stim(unit,stimID)
%
%desTrials{1} = engaged trials from stimID
%desTrials{2} = passive trials from stimID

desTrials = cell(2,1);
desTrials{1} = SM_picktrials(unit,'stim',stimID,'cond',{'engaged'});
desTrials{2} = SM_picktrials(unit,'stim',stimID,'cond',{'passive'});

end