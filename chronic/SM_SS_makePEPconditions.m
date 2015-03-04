function unit = SM_SS_makePEPconditions(unit)
%warning - it's currently possible to make many peps! write  acheck before
%creating duplicate conditions - SM_picktrials REALLY doesn't like that

% this gives the trials that start and stop both passive and engaged periods
clear pp pe ss

%unit.trials = SM_sorttrials(unit.trials); careful, this screws up indexing for conditions, stims, etc etc

ip = SM_trialispassive(unit.trials);

pe(ip == 0) = 'e';
pe(ip == 1) = 'p';


pp(1) = 1;
pp(length(pe)) = 1;
for i = 2:length(pe)-1
    if (pe(i-1) == 'p' && pe(i+1) == 'p') || (pe(i-1) == 'e' && pe(i+1) == 'e')
        pp(i) = 0;
    else
        pp(i) = 1;
    end
    
end

ss = find(pp);
ss = reshape(ss,2,length(ss)/2)';


for pepnum = 1:size(ss,1)
    if pepnum == 1 & ~SM_trialispassive(unit.trials(1,:)) %always start PEP with passive. if first trial is engaged, then make first PEP empty
        unit.conditions = [unit.conditions; {'PEP1'  false(size(unit.trials,1),1)}];
        continue
    end
    
    currinds =  false(size(unit.trials,1),1);
    currinds(ss(pepnum,1):ss(pepnum,2)) = true;
    
    unit.conditions = [unit.conditions; {['PEP' num2str(pepnum)] currinds}];
    
end

end