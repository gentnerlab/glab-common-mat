function [peps pepnums] = SM_SS_getpep(unit)

pinds = strmatch('PEP',unit.conditions(:,1));

peps = unit.conditions(pinds,:);

for i = 1:size(peps,1)
   currpepstr = regexp(peps{i,1},'PEP\d+','match','once');
   pepnums(i) = str2num(currpepstr(4:end));
end

end