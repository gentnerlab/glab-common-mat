function [p ind] = SM_MC_PDFtrialsFR_motif(Unit,motifname,trialinds,N,rng)


[fr DFR] = SM_getfiringrate_motif(Unit,motifname,trialinds);

rates = makerow(DFR.allFR);


if ~exist('N','var')
    N = 10;
end

if ~exist('rng','var')
   rng(1) = min(rates);
   rng(2) = max(rates);
end

[p ind] = makePDF(rates,N,rng);



end


