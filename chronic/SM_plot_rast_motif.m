function SM_plot_rast_motif(Unit,motif,ax,pre,post)

if ischar(motif)
    motif = {motif};
end

if ~exist('pre','var')
    pre = 0;
end
if ~exist('post','var')
    post = 0;
end


%find motif by name here

for motnum = 1:length(motif)
    desmotif = motif(motnum);
dt = Unit.trials(Unit.motif.exemplars{desmotif,2}(:,1),:);
dtstart = Unit.motif.exemplars{desmotif,2}(:,2)-pre;
dtstop = Unit.motif.exemplars{desmotif,2}(:,3)+post;
if exist('ax','var')
    SM_plot_rast(dt,'start',dtstart,'stop',dtstop,'ax',ax);
else
SM_plot_rast(dt,'start',dtstart,'stop',dtstop);
end
end

end