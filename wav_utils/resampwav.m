function resamplewav(infile, fsnew)

infile_root = strtok(infile, '.');

%read in the wave format soundfile
[Y,FS,NBITS]=wavread(infile);

newY = resample(Y,fsnew,fs);

outfname = sprintf('%s_%0.4gkHz.wav', infile_root, fsnew/1000);

%output .wav file
wavwrite(newY, fsnew, outfname);