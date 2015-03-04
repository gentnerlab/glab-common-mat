function [behTrials BDind blocksize]= SM_getBD(Unit,varargin)
%[behTrials blocksize] = appendBD(desTrials,varargin)
%appendBD returns desTrials with a new column for each trial
%the new column is a struct of bahavioral data returned by getBehavData()


%% deal with varargin

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'blocksize'}
                blocksize = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            case {'operanttype','optype','type'}
                operantType = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

%% deal with potential inputs

if ~exist('operantType','var')
    fprintf(1,'WARNING: no operantType given.  Defaulting to ''gng''\n');
    operantType = 'gng'; %default
end

if ~exist('blocksize','var'); blocksize = 50; end

%% get the behavioral data and append
behTrials = SM_picktrials(Unit,'cond',{'engaged'});
BDind = size(behTrials,2)+1;

for currTrial = 1:size(behTrials,1)
    startInd = max(currTrial-(blocksize/2),1);
    endInd = min(currTrial+(blocksize/2),size(behTrials,1));
    bd = SM_getBehavData(behTrials(startInd:endInd,:),'operanttype',operantType);
    bd.append.numpre = currTrial - startInd; 
    bd.append.numpost = endInd - currTrial;
    bd.append.n = endInd-startInd;
    behTrials{currTrial,BDind}= bd;
end

