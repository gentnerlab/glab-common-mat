function desTrials = SM_fillDT_FN_stim(unit,stimID)
%DESTRIALS = SM_fillDT_FT(UNIT)
%
%DESTRIALS{1} = Feed trials
%DESTRIALS{2} = Timeout Trials

desTrials{1} = SM_picktrials(unit,'stim',stimID,'consequence','Ff');
desTrials{2} = SM_picktrials(unit,'stim',stimID,'consequence','Nn');
end
