function taperwav(infile, len)

infile_root = strtok(infile, '.');

%read in the wave format soundfile
[Y,FS,NBITS]=wavread(infile);

pts = ceil(len*FS/1000);

newY = Y;
newY(1:pts) = Y(1:pts) .* (0:pts-1)'./pts;
newY(end-pts+1:end) = Y(end-pts+1:end) .* flipud((0:pts-1)'/pts);

outfname = sprintf('%s_%0.4gmstaper.wav', infile_root, len);

%output .wav file
wavwrite(newY, FS, outfname);