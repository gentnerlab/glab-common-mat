function yout = bandpass(y,fs,Fc1,Fc2,N)

% yout = bandpass(y,fs,lowfc,highfc,order)

% Butterworth Bandpass filter designed using the BUTTER function.

% All frequency values are in Hz.
if nargin < 5
N   = 4;     % Order
end
if nargin < 4
    Fc1 = 100;    % First Cutoff Frequency
end
if nargin < 3
    Fc2 = 10000;  % Second Cutoff Frequency   
end

[B,A] = butter(N, [Fc1 Fc2]/(fs/2));        
yout = filtfilt(B,A,y);
