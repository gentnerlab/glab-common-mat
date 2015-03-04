function isodate = convertSMdatetoISOdate(SMdate)


if length(SMdate) == 19
    
    year = SMdate(1:4);
    month = SMdate(6:7);
    day = SMdate(9:10);
    
    hours = SMdate(12:13);
    minutes = SMdate(15:16);
    seconds = SMdate(18:19);
        
elseif length(SMdate) == 17
    
    year = ['20' SMdate(7:8)];
    month = SMdate(1:2);
    day = SMdate(4:5);
    
    hours = SMdate(10:11);
    minutes = SMdate(13:14);
    seconds = SMdate(16:17);
    
end


isodate = sprintf('%s-%s-%s %s:%s:%s',year,month,day,hours,minutes,seconds);

end