function ax = SM_rasttrials(ax,toes,codes,yvals,codemapname)
%ax = SM_rasttrials(ax,toes,codes,yvals,codemapname)

if ~exist('codemapname','var');
    codemapname='default';
end;

if ~exist('yvals','var');
    yvals=1:size(toes,1);
elseif isempty(yvals);
    yvals=1:size(toes,1);
end;

if ~exist('codes','var');
   codes = {-1*ones(length(toes))};
end;

if ax <= 0;figure;ax=axes;else axes(ax);end;

if nargin >= 3
    for repnum = 1:size(toes,1)
        SM_rasttrial(toes{repnum,:},codes{repnum,:},yvals(repnum),codemapname);
    end
else
    for repnum = 1:size(toes,1)
        SM_rasttrial(toes{repnum,:},ones(size(toes{repnum,:})),yvals(repnum),codemapname);
    end
end

axrangeY(min(yvals)-0.5,max(yvals)+0.5);

end