function [psth xbins psthC psth_std psth_sem] = SM_getpsth_motif(desTrials,start,stop,binsize,zeroreference)
%[psth xbins psthC psth_std psth_sem] = SM_getpsth(desTrials,start,stop,binsize,zeroreference)

if nargin < 4, binsize = 20; end
if nargin < 3, stop = 99; end
if nargin < 2, start = -99; end

if ischar(desTrials{1}) %if desTrials is itself just a cell array of trials, wrap it in a cell
    tmp = {desTrials};
    clear desTrials;
    desTrials = tmp;
end

emptyDT = false(size(desTrials));
for dtNum = 1:length(desTrials)
    if ~isempty(desTrials{dtNum})
        topsthTimeLimits{dtNum} = cell2mat(desTrials{dtNum}(:,5));
        mintime(dtNum) = max(max(topsthTimeLimits{dtNum}(:,1)),start);
        maxtime(dtNum) = min(min(topsthTimeLimits{dtNum}(:,2)),stop);
    else
        emptyDT(dtNum) = true;
    end
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

psth = cell(size(desTrials));
psthC = cell(size(desTrials));
psth_std = cell(size(desTrials));
psth_sem = cell(size(desTrials));
for dtNum = 1:length(desTrials)
    if nargout < 3
        psth{dtNum} = histc(cell2mat(topsthwindowed{dtNum}(:,1)),xbins);    %do the histogram on all the spikes
        psth{dtNum} = psth{dtNum}/size(topsthwindowed{dtNum},1);            %normalize for number of reps
        psth{dtNum} = psth{dtNum}*bps;                                      %normalize to spikes/second
    else
        numreps = length(topsthwindowed{dtNum}(:,1));
        for repnum = 1 : numreps
            if ~isempty(topsthwindowed{dtNum}{repnum,1})
                psthC{dtNum}(repnum,:) = histc(topsthwindowed{dtNum}{repnum,1},xbins); %do histogram on each rep
            else
                psthC{dtNum}(repnum,:) = zeros(1,length(xbins));
            end
        end
        if numreps ~= 1
            psth{dtNum} = mean(psthC{dtNum})*bps;
            psth_std{dtNum} = std(psthC{dtNum})*bps;
            psth_sem{dtNum} = stderr(psthC{dtNum})*bps;
        else
            psth{dtNum} = psthC{dtNum}*bps;
            psth_std{dtNum} = zeros(size(psthC{dtNum}));
            psth_sem{dtNum} = zeros(size(psthC{dtNum}));
        end
    end
end

if any(emptyDT)
    psth{emptyDT} = [];
    psthC{emptyDT} = [];
    psth_std{emptyDT} = [];
    psth_sem{emptyDT} = [];
end

end