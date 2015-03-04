function Units = SM_getS2MLswapunits

readspikeshapes = 0;
verbose = 0;

S2MLswap = 'D:\SpikeMatlabSwap\swap.mat';

Units = SM_reads2mat(S2MLswap,readspikeshapes,verbose);

end