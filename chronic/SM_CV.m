function CV = SM_CV(desTrials)
%get coefficient of variation on a set of spike trains

starttimecode = '<';
endtimecode = '>';
[meanFR FR] = SM_getfiringrate(desTrials,starttimecode,endtimecode);

CV = std(FR.allFR)/meanFR;

end