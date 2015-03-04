function [psth xbins psthC psth_std psth_sem] = SM_getpsth2(desTrials,start,stop,binsize,zeroreference)
%[psth xbins psthC psth_std psth_sem] = SM_getpsth(desTrials,start,stop,binsize,zeroreference)

if nargin < 4, binsize = 20; end
if nargin < 3, stop = 99; end
if nargin < 2, start = -99; end


emptyDT = false(size(desTrials));
    if ~isempty(desTrials)
        topsthTimeLimits = cell2mat(desTrials(:,5));
        mintime = max(max(topsthTimeLimits(:,1)),start);
        maxtime = min(min(topsthTimeLimits(:,2)),stop);
    else
        emptyDT = true;
    end

mmin = max(mintime);
mmax = min(maxtime);

bps = 1000/binsize;

if nargin < 5
    nbins = (mmax-mmin) * bps;
    xbins = linspace(mmin, mmax, nbins);
    topsthwindowed = SM_windowspikes4(desTrials,mmin,mmax);
else
    nbins = (stop-start) * bps;
    xbins = linspace(start, stop, nbins);
    topsthwindowed = SM_windowspikes4(desTrials,start,stop,zeroreference);
end

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

if any(emptyDT)
    psth{emptyDT} = [];
    psthC{emptyDT} = [];
    psth_std{emptyDT} = [];
    psth_sem{emptyDT} = [];
end

end