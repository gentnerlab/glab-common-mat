function [meanFR FR] = SM_getfiringrate_motif(Unit,motifname,trialinds)

if nargin < 3;trialinds = true(size(Unit.trials,1),1);end

if isempty(trialinds) || sum(trialinds) == 0
    meanFR = NaN;
    FR.mean = NaN;
    FR.std = NaN;
    FR.stderr = NaN;
    FR.allFR = NaN;
    FR.timerange = NaN;
    return
end

if length(trialinds) < size(Unit.trials,1) %assume we were passed trial ind numbers, not logical array, now make it a logical array
    tmp = false(size(Unit.trials,1),1);
    tmp(trialinds) = true;
    trialinds = tmp;
end

if ~isfield(Unit,'motif')
    Unit = SM_makemotifstruct(Unit);
end

if ischar(motifname)
    motifindex = find(strcmp(Unit.motif.exemplars(:,1),motifname));
elseif isnumeric(motifname)
    motifindex = motifname;
    motifname = Unit.motif.exemplars{motifindex,1};
end

motiftrialindices = ~cellfun('isempty',Unit.motif.byexemp.time(motifindex,:));

desIndices = motiftrialindices(:) & trialinds(:);

k = 0;
for i = 1:length(desIndices)
    if desIndices(i)
        k = k+1;
        motifstarttimes(k) = Unit.motif.byexemp.time{motifindex,i}{1}(1);
        motifendtimes(k) = Unit.motif.byexemp.time{motifindex,i}{1}(2);
    end
end

[meanFR FR] = SM_getfiringrate(Unit.trials(desIndices,:),motifstarttimes,motifendtimes);



end