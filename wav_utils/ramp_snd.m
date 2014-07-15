function out = ramp_snd(x, time, fs)
% function to add short linear time ramp to the start and end of a
% file.

if nargin<3
    fs = 44100;
end

samps = round((fs/1000)*time); % samples to ramp

startramp = (1:samps).*(1/samps);
endramp = (1:samps).*(-1/samps)+1;

out=[x(1:samps).*startramp'; x(samps+1:end-samps); x(end-samps+1:end).*endramp'];