function AT = NDSM_SS_getalltrials(subjectid)

NDTrials = ND_gettrials(['st' num2str(subjectid) 'set']);

ATFname = SM_getAllTrialsFileName(['st' subjectid]);
[SMTrials_SMformat SMTrials_NDformat] = SM_readalltrialsfile(ATFname);

AT = [NDTrials ; SMTrials_NDformat];

[AT trialindsout] = ND_sorttrials(AT,'timeorder');

end