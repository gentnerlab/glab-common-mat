function [psth xbins psthC psth_std psth_sem] = SM_getpsth(desTrials,start,stop,binsize,zeroreference)
%[psth xbins psthC psth_std psth_sem] = SM_getpsth(desTrials,start,stop,binsize,zeroreference)

if nargin < 4, binsize = 20; end
ranges = cell2mat(desTrials(:,5));
if nargin < 3, stop = min(ranges(:,2)); end
if nargin < 2, start = max(ranges(:,1)); end


if ~isempty(desTrials)
    topsthTimeLimits = cell2mat(desTrials(:,5));
    mintime = max(max(topsthTimeLimits(:,1)),start);
    maxtime = min(min(topsthTimeLimits(:,2)),stop);
else
    psth = [];
    xbins = [];
    psthC = [];
    psth_std = [];
    psth_sem = [];
    return
end


mmin = max(mintime);
mmax = min(maxtime);

bps = 1000/binsize;

if nargin < 5 %if getting 'normal' psth of response to auditory stimulus
    nbins = (mmax-mmin) * bps;
    xbins = linspace(mmin, mmax, nbins);
    topsthwindowed = SM_windowspikes4(desTrials,mmin,mmax);
else %if requesting a PSTH from some other time period - ie referenced to stim offset or something
    nbins = (stop-start) * bps;
    xbins = linspace(start, stop, nbins);
    topsthwindowed = SM_windowspikes4(desTrials,start,stop,zeroreference,0);
end


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