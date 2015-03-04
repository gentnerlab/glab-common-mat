function [p ind] = SM_PDFtrialsFR(trials,N,rng)


[fr DFR] = SM_getfiringrate(trials);

rates = makerow(DFR.allFR);


if nargin < 2
    N = 10;
end


if nargin < 3
   rng(1) = min(rates);
   rng(2) = max(rates);
end

[p ind] = makePDF(rates,N,rng);



end


