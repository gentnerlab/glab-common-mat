function desTrials = SM_fillDT_EP_all(unit)
%DESTRIALS = SM_fillDT_EP(UNIT)

desTrials{1} = SM_picktrials(unit,'condition','engaged');
desTrials{2} = SM_picktrials(unit,'condition','passive');
end
