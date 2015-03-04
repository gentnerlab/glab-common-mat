function [outtimestamp] = SM_getSMUTrialtimestamp(trial,subjectname)

[year month day] = yearmonthday(trial{2},subjectname);

[hours minutes seconds milliseconds] = hoursminutesseconds(trial{3});

outtimestamp = sprintf('%s-%s-%s %s:%s:%s.%s%s',num2str(year),num2str(month),num2str(day),num2str(hours),num2str(minutes),num2str(seconds),num2str(milliseconds));

end


function [year month day] = yearmonthday(SMdate,subjectname)
%[year month day] = yearmonthday(SMdate)

if length(SMdate) == 10
    year = SMdate(1:4);
    month = SMdate(6:7);
    day = SMdate(9:10);
    
elseif length(SMdate) == 8
    
    if any(strcmp(subjectname,{'st515','st517','st503'}))  %'06-12-09' ie MM-DD-YY (st515,st517)
        
        year = ['20' SMdate(7:8)];
        month = SMdate(1:2);
        day = SMdate(4:5);
        
    else % '10-08-19' ie YY-MM-DD (st423, st575,st531) - presumably all new birds unless the s2mat code changes
        
        year = ['20' SMdate(1:2)];
        month = SMdate(4:5);
        day = SMdate(7:8);
        
    end
    
else
    error('huh?!');
end

end

function [hours minutes seconds milliseconds microseconds] = hoursminutesseconds(ssm)
%[hours mins secs msec] = hsm(secondssincemidnight)

hours = floor(ssm / (60*60));

minutes = floor((ssm - hours*60*60)/60);

seconds = floor(ssm - hours*60*60 - minutes*60);

milliseconds = floor((ssm - hours*60*60 - minutes*60 - seconds)*1000);

microseconds = floor((ssm - hours*60*60 - minutes*60 - seconds - milliseconds/1000)*1000000);

end
