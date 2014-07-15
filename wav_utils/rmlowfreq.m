function [x_bs,f]=rmlowfreq(input, fs, cutoff)

% removes everything below frequency cutoff
% if starting from wav file, use [input, fs] = wavread('wavfile');
% ec 02/08 mb 10/08

[xfft, f, nfft]=calc_plot_powerspect(input,fs);

arbitraryscalar = 0.3;

lim = f(end);
if cutoff>lim;
    disp('cutoff over limit, decreasing to limit')
    cutoff=lim;
end
if cutoff<0
    cutoff = 0;
end

start=find(f>=cutoff,1) ;

if start>1
	xfft(1:start)=0;
end

x_bs=ifft(xfft,'symmetric');
x_bs=x_bs/(max(x_bs));          %get into normal amplitude range
x_bs=arbitraryscalar*x_bs;                 %avoid clipping
x_bs=x_bs(1:length(input));     %get rid of fft padding
