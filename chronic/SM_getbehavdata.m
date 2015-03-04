function behavioraldata = SM_getbehavdata(desTrials,varargin)
%behavioraldata = SM_getbehavdata(desTrials,varargin)

%% deal with varargin

ind = 1;
while ind <= length(varargin)
    if ischar(varargin{ind})
        switch lower(varargin{ind})
            case {'operanttype','optype','type'}
                operantType = varargin{ind+1};
                ind=ind+1; %skip next value (we already assigned it!)
            otherwise
                error('don''t know what to do with input: %s',varargin{ind});
        end
    end
    ind=ind+1;
end

%% deal with potential variables

if ~exist('operantType','var')
    fprintf(1,'WARNING: no operantType given.  Defaulting to ''gng''\n');
    operantType = 'gng'; %default
end

%% do the calculations

bdat    = cell2mat(desTrials(:,12));

switch operantType
    case {'gng'}
        behavioraldata.ntrials                         	= length(bdat);
        behavioraldata.trials                           = bdat;
        
        behavioraldata.passive.ind                      = find(bdat=='p');
        behavioraldata.passive.n                      	= sum(bdat=='p');
        behavioraldata.engaged.ind                    	= find(bdat~='p');
        behavioraldata.engaged.n                    	= sum(bdat~='p');
        
        behavioraldata.hit.reinforced.ind               = find(bdat=='F');
        behavioraldata.hit.reinforced.n               	= sum(bdat=='F');
        behavioraldata.hit.notreinforced.ind          	= find(bdat=='f');
        behavioraldata.hit.notreinforced.n             	= sum(bdat=='f');
        behavioraldata.hit.n                          	= behavioraldata.hit.reinforced.n + behavioraldata.hit.notreinforced.n;
        
        behavioraldata.falsealarm.reinforced.ind       	= find(bdat=='T');
        behavioraldata.falsealarm.reinforced.n        	= sum(bdat=='T');
        behavioraldata.falsealarm.notreinforced.ind   	= find(bdat=='t');
        behavioraldata.falsealarm.notreinforced.n     	= sum(bdat=='t');
        behavioraldata.falsealarm.n                  	= behavioraldata.falsealarm.reinforced.n + behavioraldata.falsealarm.notreinforced.n;
        
        behavioraldata.correctreject.reinforced.ind    	= []; %leaving it here for later?
        behavioraldata.correctreject.reinforced.n    	= 0;  %leaving it here for later?
        behavioraldata.correctreject.notreinforced.ind  = find(bdat=='W');
        behavioraldata.correctreject.notreinforced.n   	= sum(bdat=='W');
        behavioraldata.correctreject.n                  = behavioraldata.correctreject.reinforced.n + behavioraldata.correctreject.notreinforced.n;
        
        behavioraldata.miss.reinforced.ind             	= []; %leaving it here for later?
        behavioraldata.miss.reinforced.n             	= 0;  %leaving it here for later?
        behavioraldata.miss.notreinforced.ind          	= find(bdat=='N');
        behavioraldata.miss.notreinforced.n           	= sum(bdat=='N');
        behavioraldata.miss.n                           = behavioraldata.miss.reinforced.n + behavioraldata.miss.notreinforced.n;
        
        if behavioraldata.correctreject.reinforced.n == 0 && behavioraldata.correctreject.notreinforced.n == 0  %then maybe the s2 code hasn't been updated yet, so find another way of checking for correct no responses
            bcodes    = cell2mat(desTrials(:,7));
            
            behavioraldata.correctreject.reinforced.ind    	= []; %leaving it here for later?
            behavioraldata.correctreject.reinforced.n     	= 0;  %leaving it here for later?
            behavioraldata.correctreject.notreinforced.ind  = find(bcodes(:,2) == 2 &  bdat=='N');
            behavioraldata.correctreject.notreinforced.n	= sum(bcodes(:,2) == 2 &  bdat=='N');
            behavioraldata.correctreject.n                  = behavioraldata.correctreject.reinforced.n + behavioraldata.correctreject.notreinforced.n;
            
            behavioraldata.miss.reinforced.ind           	= []; %leaving it here for later?
            behavioraldata.miss.reinforced.n             	= 0;  %leaving it here for later?
            behavioraldata.miss.notreinforced.ind        	= find(bcodes(:,2) == 1 &  bdat=='N');
            behavioraldata.miss.notreinforced.n            	= sum(bcodes(:,2) == 1 &  bdat=='N');
            behavioraldata.miss.n                           = behavioraldata.miss.reinforced.n + behavioraldata.miss.notreinforced.n;
        end
        
        behavioraldata.hmfc             = [behavioraldata.hit.n,behavioraldata.miss.n,behavioraldata.falsealarm.n,behavioraldata.correctreject.n];
        behavioraldata.correct.n        = (behavioraldata.hit.n + behavioraldata.correctreject.n);
        behavioraldata.incorrect.n      = (behavioraldata.falsealarm.n+behavioraldata.miss.n);
        if behavioraldata.engaged.n == 0
            
            behavioraldata.ratiocorrect = NaN;
            behavioraldata.dprime = NaN;
            behavioraldata.gnginfo = NaN;
            behavioraldata.ngninfo = NaN;
        else
            behavioraldata.ratiocorrect     = behavioraldata.correct.n / (behavioraldata.correct.n + behavioraldata.incorrect.n);
            behavioraldata.dprime           = dprime_gng(behavioraldata.hmfc);
            [normMI MI maxMI]               = info_gng(behavioraldata.hmfc);
            infodat                         = [normMI MI maxMI];
            behavioraldata.gnginfo          = infodat;
            %behavioraldata.ngninfo          = infodat(1).*2.*(behavioraldata.ratiocorrect-0.5);
            behavioraldata.ngninfo          = infodat(1).*(behavioraldata.ratiocorrect<0.5);
        end
    case {'2ac'}    %need to code up 2AC stuff!
        error('haven''t coded up 2ac stuff yet - do this!');
end

end

%ascii conversions: | F = 70 'Fed'| f = 102 'correct, not fed'| T = 84 'Timeout'| t = 116 'incorrect - no timeout'| N = 78 'No Response'|