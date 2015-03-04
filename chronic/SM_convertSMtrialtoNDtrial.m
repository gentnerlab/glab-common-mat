function NDtrial = SM_convertSMtrialtoNDtrial(SMtrial)

NDtrial{1,1} = [];
NDtrial{1,2} = [];
NDtrial{1,3} = [];
NDtrial{1,4} = SMtrial{6};
NDtrial{1,5} = SMtrial{7}(2);

if strmatch(SMtrial{13},'N')
NDtrial{1,6} = 0;
elseif strmatch(SMtrial{13},'L')
NDtrial{1,6} = 1;
elseif strmatch(SMtrial{13},'R')
NDtrial{1,6} = 2;
end

if strmatch(SMtrial{12},'N')
NDtrial{1,7} = 2;
elseif ~isempty(strmatch(SMtrial{12},{'F','f'}))
NDtrial{1,7} = 1;
elseif ~isempty(strmatch(SMtrial{12},{'T','t'}))
NDtrial{1,7} = 0;
end

NDtrial{1,8} = [];


if strmatch(SMtrial{12},'N')
NDtrial{1,9} = 0;
elseif ~isempty(strmatch(SMtrial{12},{'F','T'}))
NDtrial{1,9} = 1;
elseif ~isempty(strmatch(SMtrial{12},{'f','t'}))
NDtrial{1,9} = 0;
end

[hours mins secs] = hoursminutesseconds(SMtrial{3});
NDtrial{1,10} = hours*100+mins;

%WARNING: WATCH OUT FOR THE YEAR 2100 BUG!! - pretty hacky stuff here, dan...
datestring = SMtrial{2};
year = datestring(1:2);
month = datestring(4:5);
day = datestring(7:8);
NDtrial{1,11} = int32(str2num(['20' year month day]));

end
