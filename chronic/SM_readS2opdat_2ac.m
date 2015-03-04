function trials = SM_readS2opdat_2ac(filename)
%trials = SM_readS2opdat_2ac(filename,dataformat)
%trials is a cell array with each row being a different trial
%     trials{k,1}  %Session #
%     trials{k,2}  %Trial #
%     trials{k,3}  %Type (1 = normal, 0 = correction trial)
%     trials{k,4}  %Stimulus
%     trials{k,5}  %Class
%     trials{k,6}  %Response Selection
%     trials{k,7}  %Response Accurracy
%     trials{k,8}  %Reaction Time
%     trials{k,9}  %Reinforcement
%     trials{k,10}  %Time of Day
%     trials{k,11}  %Date
%
%     trials{k,12} %Probetype
%     trials{k,13} %offset
%     trials{k,14} %duration
%
%     trials{k,15} %pecks




fid = fopen(filename,'r');
if fid < 0
    error('could not open the file: %s\n',filename)
end
%infile = 'D:\experiments\raw\st517\data\prePenetrationBehaviorOnly\Ses36_112709-1420_BO_R\Subst517Pen00Site00Ses36File19_11-29-09+16-58-30_st517-opdat.txt';

datestring = regexp(filename,'_\d+-\d+-\d++','match','once');
dateparts = regexp(datestring,'\d+','match');
date = str2double(sprintf('%02d%02d',str2double(dateparts{1}),str2double(dateparts{2})));

HMS = textscan(fid, '%d %d %d %s\n','delimiter',':');
starthours = double(HMS{1});
startmins = double(HMS{2});
startseconds = double(HMS{3});

linenum = 0;
numtrials = 0;
trials = cell(1,14);

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    linenum = linenum + 1;
    
    if ~isempty(strfind(lower(tline),'correction'))
        fclose(fid);
        error('WARNING: I have not coded this up to account for correction trials\nclosing the file and quitting the read');
    elseif ~isempty(strfind(tline,'Trial setup, '))
        numtrials = numtrials + 1;
        trials{numtrials,2} = numtrials;
        trialstarttime = textscan(tline, '%f %*[^\n]',1);
        trialstarttime = trialstarttime{1};
        tod = converttime(starthours,startmins,startseconds,trialstarttime);
        trials{numtrials,2} = numtrials;
        trials{numtrials,10} = tod;
        trials{numtrials,11} = date;
    elseif ~isempty(strfind(tline,'**Trial Started:'))
        %     time = textscan(tline, '%f %*[^\n]',1);
        %     tod = converttime(starthours,startmins,startseconds,time{1});
        ind = strfind(tline,'**Trial Started:');
        stim = strtrim(regexp(tline(ind+16:end),'\s+\S+\s+','match','once'));
        trials{numtrials,4} = stim;
        
        class = regexp(tline(ind+16:end),'class .+','match','once');
        class = str2double(class(7:end));
        trials{numtrials,5} = class;
    elseif ~isempty(strfind(tline,'Stimulus output stopped'))
        trialendtime = textscan(tline, '%f %*[^\n]',1);
        trialendtime = trialendtime{1};
        keeplooking = 1;
        while keeplooking == 1 % in case bird pecks in center before responding
            tline = fgetl(fid); %go to next line to find response selection
            if ~ischar(tline), break, end
            if ~isempty(strfind(tline,'Peck Left'))
                trials{numtrials,6} = 1;
                time = textscan(tline, '%f %*[^\n]',1);
                reactiontime = time{1} - trialendtime;
                trials{numtrials,8} = reactiontime;
                keeplooking = 0;
            elseif ~isempty(strfind(tline,'Peck Center'))
                keeplooking = 1;
            elseif ~isempty(strfind(tline,'Peck Right'))
                trials{numtrials,6} = 2;
                time = textscan(tline, '%f %*[^\n]',1);
                reactiontime = time{1} - trialendtime;
                trials{numtrials,8} = reactiontime;
                keeplooking = 0;
            elseif ~isempty(strfind(tline,'Response Window Passed, No Response'))
                trials{numtrials,6} = 0;
                trials{numtrials,7} = 2;
                trials{numtrials,9} = 0;
                time = textscan(tline, '%f %*[^\n]',1);
                reactiontime = time{1} - trialendtime;
                trials{numtrials,8} = reactiontime;
                keeplooking = 0;
            end
        end
        
    elseif ~isempty(strfind(tline,'Feed Started'))
        trials{numtrials,7} = 1;
        trials{numtrials,9} = 1;
    elseif ~isempty(strfind(tline,'Correct but no feed'))
        trials{numtrials,7} = 1;
        trials{numtrials,9} = 0;
    elseif ~isempty(strfind(tline,'Timeout Started'))
        trials{numtrials,7} = 0;
        trials{numtrials,9} = 1;
    elseif ~isempty(strfind(tline,'Wrong but no timeout'))
        trials{numtrials,7} = 0;
        trials{numtrials,9} = 0;
    end
end

fclose(fid);

%hack until I code up correction trials
for i = 1:size(trials,1)
    trials{i,3} = 1;
end

end


function tod = converttime(SH,SM,SS,time)
SS = SS + time;
moremins = round(SS/60);
allmins = SM + moremins;
morehours = floor(allmins/60);
mins = (allmins - (morehours*60));
hours = SH+morehours;
tod = str2double(sprintf('%02d%02d',hours,mins));
end
