function motclasses = SM_MC_getmotclasses(subject)

fname = [getdanroot 'experiments' filesep 'analysis' filesep subject filesep 'motclasses.mat'];

X = load(fname);

motclasses = X.motclasses;

end