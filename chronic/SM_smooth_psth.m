function smoothedpsth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam)
%smoothedpsth = SM_smooth_psth(psth,xbins,smoothmethod,smoothparam)

switch smoothmethod
    case 'ma'
        if isscalar(smoothparam)
            smoothedpsth = smooth(xbins,psth,smoothparam);
        else
            smoothedpsth = smooth(xbins,psth);
        end
    case 'gauss'
        smoothedpsth = gaussconv(psth,smoothparam);
    case 'exp'
        smoothedpsth = expconv(psth,smoothparam);
    case 'none'
        smoothedpsth = psth;
    otherwise
        error('smoothmethod should be defined');
end