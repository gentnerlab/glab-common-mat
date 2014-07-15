
function scalewav(infile, newdb,type, resamp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will take a wav file, subtract the DC offset,
% compute the mean RMS value, then scale it to a new mean RMS
%type = 1 scales to the peak RMS
%type = 2 scales to the mean RMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    resamp = 0;
end

infile_root = strtok(infile, '.');

%read in the wave format soundfile
[Y,FS,NBITS]=wavread(infile);

bw=6.0206*NBITS;

%strip the DC offset
dcoff = (mean(Y));
nodc = Y-dcoff;
maxold = max(nodc);

meanrms = sqrt(mean(nodc.^2));
meandb = bw + (20*log10(meanrms));
peakrms = sqrt(max(nodc.^2));
minrms = sqrt(min(nodc.^2));
peakdb = bw + (20*log10(peakrms));
newrms = 10^((newdb-bw)/20);
mindb = bw + (20*log10(minrms));

if(type==2)
     xform = 'mean'; 
     scale = newrms/meanrms;
     newY=scale*nodc;
     maxnew = max(newY);
else
     xform = 'peak';
     olddb = bw + (20*log10(peakrms));
     scale = newrms/peakrms;
     newY = scale*nodc;
     maxnew = max(newY);
end

meanrms2 = sqrt(mean(newY.^2));
meandb2 = bw + (20*log10(meanrms2));
peakrms2 =sqrt(max(newY.^2));
peakdb2 = bw + (20*log10(peakrms2));



outfname = sprintf('%s_%.0fdb%s.wav', infile_root,newdb,xform);

fprintf('Infile: %s \tmean dB:%f \tpeak dB:%f \tmin dB:%f\nOutfile: %s \tmean dB:%f \tpeak dB:%f \n',infile,meandb,peakdb,mindb,outfname, meandb2,peakdb2);

if(peakdb2>bw)
     fprintf('WARNING: OUTPUT WILL CLIP AT THIS AMPLITUDE!!!\n');
end     

% onset and offset ramp
% newY = ramp_snd(newY, 10, 44100);

if resamp == 1
    newY = resample(newY,40000,FS);
    FS = 40000;
end

%output .wav file
wavwrite(newY, FS,outfname);

