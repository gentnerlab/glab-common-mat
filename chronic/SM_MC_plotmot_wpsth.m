function SM_MC_plotmot_wpsth(Unit,motifname,ax,sortmethod,passeng,smoothmethod,smoothparam,codemapname)
%SM_MC_plotmot_wpsth(Unit,motifname,ax,sortmethod,passeng,smoothmethod,smoothparam)

if nargin < 8;codemapname='defaultshading';end
if nargin < 7;smoothparam=10;end
if nargin < 6;smoothmethod='gauss';end
if nargin < 5;passeng='both';end
if nargin < 4;sortmethod='motifposition';end
if nargin < 3;ax=0;end

if ax == 0 
    figure;
    ax=gca;
end

doplot = 1;

axes(ax);
ax1 = subplot(5,1,1:4);
ax2 = subplot(5,1,5);

[trialindsout out toes rastcodes] = SM_MC_plotmot(Unit,motifname,ax1,sortmethod,passeng,doplot,codemapname);

v = axis;

% [psth xbins] = SM_getpsth_from_toesnrastcodes(toes,rastcodes,-2,3,20,1:2);
% smoothedpsth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam);
% 
% plot(ax2,xbins,smoothedpsth,'linewidth',3);
% axes(ax2)
% axrangeX(v(1),v(2));

[psth xbins] = SM_getpsth_from_toesnrastcodes(toes(1:61),rastcodes(1:61),-2,3,20,1:2);
smoothedpsth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam);

plot(ax2,xbins,smoothedpsth,'linewidth',3);
axes(ax2)
axrangeX(v(1),v(2));

hold on

[psth xbins] = SM_getpsth_from_toesnrastcodes(toes(61:end),rastcodes(61:end),-2,3,20,1:2);
smoothedpsth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam);

plot(ax2,xbins,smoothedpsth,'linewidth',3,'color','r');
axes(ax2)
axrangeX(v(1),v(2));


end