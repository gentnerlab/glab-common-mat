function [psth xbins psthC psth_std psth_sem] = SM_getpsth_from_toesnrastcodes(toes,rastcodes,start,stop,binsize,desiredcodes)
%[psth xbins psthC psth_std psth_sem] = SM_getpsth(desTrials,start,stop,binsize,zeroreference)

if nargin < 6, desiredcodes = [1:10]; end
if nargin < 5, binsize = 20; end
if nargin < 4, stop = 99; end
if nargin < 3, start = -99; end



%first find desired toes
topsthwindowed = cell(length(toes),1);
for toenum = 1:length(toes)
    goodinds = false(length(toes{toenum}),1);
   for codenum = 1:length(desiredcodes) 
       goodinds = goodinds | (rastcodes{toenum} == desiredcodes(codenum));
   end
   topsthwindowed{toenum} = toes{toenum}(goodinds);
   %maxt(toenum) = max(toes{toenum}(goodinds));
   %mint(toenum) = min(toes{toenum}(goodinds));
end
% mmin = max(max(mint),start);
% mmax = min(min(maxt),stop);
mmin = start;
mmax = stop;


bps = 1000/binsize;

    nbins = (mmax-mmin) * bps;
    xbins = linspace(mmin, mmax, nbins);


% psth = cell(size(desTrials));
% psthC = cell(size(desTrials));
% psth_std = cell(size(desTrials));
% psth_sem = cell(size(desTrials));
    if nargout < 3
        psth = histc(cell2mat(topsthwindowed(:,1)),xbins);    %do the histogram on all the spikes
        psth = psth/size(topsthwindowed,1);            %normalize for number of reps
        psth = psth*bps;                                      %normalize to spikes/second
    else
        numreps = length(topsthwindowed(:,1));
        for repnum = 1 : numreps
            if ~isempty(topsthwindowed{repnum,1})
                psthC(repnum,:) = histc(topsthwindowed{repnum,1},xbins); %do histogram on each rep
            else
                psthC(repnum,:) = zeros(1,length(xbins));
            end
        end
        if numreps ~= 1
            psth = mean(psthC)*bps;
            psth_std = std(psthC)*bps;
            psth_sem = stderr(psthC)*bps;
        else
            psth = psthC*bps;
            psth_std = zeros(size(psthC));
            psth_sem = zeros(size(psthC));
        end
    end


end