function SM_key
% Units = (1 x NumberofUnits) struct array with fields:
%     subject
%     pen
%     site
%     marker
%     trials = (NumberofTrials x 12) cell array
%           column 1:   sortfilename
%           column 2:   date
%           column 3:   seconds since midnight at start of trial
%           column 4:   time relative to subfile start in seconds
%           column 5:   [startrange of data , endrange of data]
%           column 6:   stimname
%           column 7:   (1x4) array of stimcodes
%           column 8:   (1x1) struct of keyboard channel data
%                   .times = (NumberofKeyboardmarkers x 1) array of keyboard marker times
%                   .codes = (NumberofKeyboardmarkers x 4) array of keyboard marker codes
%           column 9:     (1x1) struct of digimark channel data
%                   .times = (NumberofDigimarks x 1) array of digimark marker times
%                   .codes = (NumberofDigimarks x 4) array of digimark marker codes
%           column 10:  (numspikes x 1) array of spike times relative to stim start
%           column 11:  (numspikes x numberpointsperwavemark) array of spike times relative to stim start
%           column 12:  trial consequence:
%                    'p' = passive trial
%                    'f' = correct, no feed
%                    'F' = correct, feed
%                    't' = incorrect, no timeout
%                    'T' = incorrect, timeout
%     info = (1 x NumberofSortFiles) struct array with fields:
%           s2MATfile
%           trialinds
%       	WMchantitle
%           WMchancomment
%         	WMchanresolution
%           WMchaninterval
%           WMscale
%           WMoffset
%           WMunits
%           WMnumPointsPerWavemark
%           WMnumPreTriggerPoints
%           WMtraces
%           sortquality
%     stims = (number of stims x 2) cellarray
%           {[stimname] [logical index into U.trials]}
%     conditions = (number of conditions x 2) cellarray
%           {[conditionname] [logical index into U.trials]}
%     sortquality  = [meansortquality stdsortquality numsorts]
disp('to use SM_key, type ''help SM_key''');
end