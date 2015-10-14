function tone_gen(Freq, duration_ms, ramp_ms, SRout, outflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will take a generate a sine tone of a specified 
% frequency and duration with a linear on-off ramp of specified
% duration, specicy sample rate for output file,
% and outflag=1 for 16 bit wav format (default), 2 for PCM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check input params

if (round(duration_ms) - duration_ms ) ~= 0
   error('tone duration must be an integer value in msec')
end

if (round(ramp_ms) - ramp_ms ) ~= 0
   error('ramp duration must be an integer value in msec, or zero')
end

outfroot = sprintf('%dHz_sine_%dms_fades',Freq, ramp_ms);

if (outflag==2)
     outfname = sprintf('%s.pcm', outfroot);
else
    outfname = sprintf('%s.wav', outfroot);
end


%generate the sine tone
n_samp = duration_ms * SRout/1000;
step = 1/SRout;
t = 0:step:duration_ms/1000;
T=32767*sin(2*pi*Freq *t);



% add fade in/ fade out with pcmx
n_rampS = ramp_ms * SRout/1000;
for i=1: n_samp
 if (i <= n_rampS)
     T(i) = T(i) * (i/n_rampS);
 end
 if (i > (n_samp-n_rampS))
  T(i)= T(i) * ((n_samp-i)/n_rampS);
 end
end
subplot(2,1,1);plot(T(1:n_samp))

subplot(2,1,2);specgram(T)

 if (outflag==2)
    outfid = fopen(outfname,'w');
    fwrite(outfid,T,'int16');
else
    scaleT = T./ (max(abs(T))+1);
max(scaleT);
    wavwrite(scaleT,SRout,outfname); 
end
