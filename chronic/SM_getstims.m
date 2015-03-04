function stims = SM_getstims(Unit)
%stims = SM_getstims(Unit/Trials)

if isstruct(Unit)
    stims = unique(Unit.trials(:,6));
    for i = 1:length(stims)
        stims{i,2} = ismember(Unit.trials(:,6),deblank(stims{i,1}));
        stims{i,1} = deblank(strrep(stims{i,1},'smr','wav'));
    end
    
else
    if iscell(Unit)
        stims = unique(Unit(:,6));
        for i = 1:length(stims)
            stims{i,2} = ismember(Unit(:,6),deblank(stims{i,1}));
            stims{i,1} = deblank(strrep(stims{i,1},'smr','wav'));
        end
    end
end




end



