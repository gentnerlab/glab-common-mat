function desTrials = SM_fillDT_FT(unit)
%DESTRIALS = SM_fillDT_FT(UNIT)
%
%DESTRIALS{1} = Feed trials
%DESTRIALS{2} = Timeout Trials

desTrials{1} = SM_picktrials(unit,'consequence','F');
desTrials{2} = SM_picktrials(unit,'consequence','T');
end
