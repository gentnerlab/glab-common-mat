function SM_MC_plotmots(Unit,ax,sortmethod,passeng)
%SM_MC_plotmots(Unit,ax,sortmethod,passeng)

if nargin < 4;passeng='both';end

if nargin < 3;sortmethod='motifposition';end

if nargin < 2;figure;elseif ax==0;figure;else axes(ax);end

if ~isfield(Unit,'motif')
    Unit = SM_makemotifstruct(Unit);
end

totnummots = 0;
for motnum = 1:size(Unit.motif.exemplars,1)
    if isempty(strfind(Unit.motif.exemplars{motnum,1},'silence'))
        totnummots = totnummots + 1;
    end
end

desiredcolumns = 4;
ncols = desiredcolumns;
nrows = ceil(totnummots/desiredcolumns);

for plotnum = 1:totnummots
    inds{plotnum} = SM_MC_plotmot(Unit,plotnum,subplot(nrows,ncols,plotnum),sortmethod,passeng);
    numT(plotnum) = length(inds{plotnum});
    hands(plotnum) = gca;
    axpos(plotnum,:) = get(gca,'position');
end

[maxnumT,maxnumTind] = max(numT);
yymaxheight = axpos(maxnumTind,4);

for plotnum = 1:totnummots
    set(hands(plotnum),'position',[axpos(plotnum,1) axpos(plotnum,2) axpos(plotnum,3) yymaxheight*numT(plotnum)/maxnumT]);
end