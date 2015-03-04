%%
clear currT currS trialsB

beginT = datenum(2012,9,12,15,22,0);

  beginT = datenum(2012,9,12,7,00,0);
%beginT = datenum(now());
endT = datenum(2012,9,12,19,26,0);

onM = 28;
offM = 32;

currT(1) = beginT;
trialsB(1) = true;
k = 1;
while currT(k)<endT
    k = k+1;
    currT(k) = addtodate(currT(k-1),onM,'minute');
    trialsB(k) = false;
    if currT(k)>endT
        break
    end
    k = k+1;
    currT(k) = addtodate(currT(k-1),offM,'minute');
    trialsB(k) = true;
end

currS = datestr(currT);
disp('currS')
currS
disp('trialsavailable')
trialsB
fprintf(1,'endT: %s\n\n',datestr(endT))
if trialsB(end-1) == 1
    disp('should be all set with lights out')
else
    disp('should check lights out at end of day')
end