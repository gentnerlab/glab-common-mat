%Subject loading tool
error('I''m a script - don''t run me, try ''edit  SM_subjectLoader.m''')

%% Read in Units
%Units = reads2lib(subject,keepspikeshapes,dataonFugl2,verbose,noProcess,noGetSortQual)

subjectname = 'st842';
keepspikeshapes = 0;
dataonibon = 1;
verbose = 1;
noProcess = 0;
noGetSortQual = 0;

eval(['U' subjectname(3:end) ' = SM_readlib20110805(subjectname,keepspikeshapes,dataonibon,verbose,noProcess,noGetSortQual)']);

%save these units to the workingdata folder
save(fixfilesep([workingdataroot 'U' subjectname(3:end) '_' datestr(now,'YYYYmmdd') '.mat']),['U' subjectname(3:end)]);

%% insert setstiminfo to database

conn = DBconnect;

DBinsert_setstiminfo(conn, SM_getsubjectinfofile(subjectname));

%% get and update proper protocol names
newprotocolids = DBprocess_insertprotocolinfofromepochname(conn); %should only effect epochs with epochid = 0


%% load cells into database
edit DBinsert_LotsOfCells.m

%this is preferred: edit DBinsert_LotsOfCells.m
%or
%WARNING: THERE IS NO CHECK FOR THE CELL ALREADY EXISTING
%probably, DBadd_SMunit will run through all the trials/trialevents and see
%that they're already in the database and you will just waste a bunch of 
%time, BUT I haven't checked thoroughly
% profile on
% U = eval(['U' subjectname(3:end)]);
% for i = 1:length(U)
%     h=waitbar(i/length(U));
%     fprintf(1,'subject\t=\t%s\n',U(i).subject)
%     fprintf(1,'i\t=\t%d of %d\n',i,length(U))
%     fprintf(1,'marker\t=\t%d\n\n',U(i).marker)
%     
%     [subjectid{i}, penid{i}, siteid{i}, sortid{i}, trialid{i}, trialeventids{i}] = DBadd_SMunit(conn, U(i));
% end
%  profile viewer
% close(h)


%% update new cells

currcellids = cell2mat(DBget_x(conn,'SELECT cellid FROM cell WHERE cellid > 234 ORDER BY cellid'));

[cellengmode cellidout] = DBcalcIU_cell_engmode(conn,currcellids); %updates cellcalc

for cn = 1:length(currcellids)
[cellid(cn) minq(cn) maxq(cn)] = DBcalcIU_cellcalc_minmaxsortquality(conn,currcellids(cn)); %updates cellcalc
end

%% update trialcalc with engmode

alltrialids = cell2mat(DBget_x(conn,'SELECT trialid FROM trial WHERE trialid > 87086 ORDER BY trialid')); 
[trialengmode trialidout] = DBcalcIU_trial_engmode(conn,alltrialids);

%% update new subjects - might want to restrict this to new trials in future - LONG
DBprocessIU_protocolntrials_nontrainingstims(conn,DBget_subjectID(conn,subjectname))


%% update new trialcalc 
currtrialcalcids = cell2mat(DBget_x(conn,'SELECT trialcalcid FROM trialcalc WHERE trialcalcid > 87086 ORDER BY trialcalcid')); 
DBprocessU_trialcalc_numpecks(conn,currtrialcalcids)
DBprocessIU_trialcalcnontrainingstimblanks(conn,currtrialcalcids)

%% for SS birds 

edit DBprocess_associatealltrialswithDBtrials.m

%% make sstrials - LONG TIME ~100 seconds for 1000 trials

currentalltrials=alltrials;

% currcellids = cell2mat(DBx(conn,'SELECT cellid FROM cell WHERE cellid > 234 ORDER BY cellid'));
% currtrials = unique(DBget_trial_cell(conn,currcellids));
% atinds = ismember(cell2mat(alltrials(:,20)),currtrials);
% currentalltrials = alltrials(~atinds,:);

[newsstrialids updatedsstrialids justskippedthese_addthemmanually justskippedthese_alreadyadded] = DBadd_SStrialsfromalltrials(conn,currentalltrials,subjectname);
%%DAN LISTEN! WHEN DONE WITH THIS - UNCOMMENT THE ERROR ON LINE 184

if ~isempty(justskippedthese_addthemmanually)
   justskippedthese_addthemmanually
   warning('THESE TRIALS WERE NOT ADDED - ADD THEM MANUALLY!!!') 
   keyboard
   atinds = ismember(cell2mat(alltrials(:,20)),justskippedthese_addthemmanually);
currentalltrials = alltrials(atinds,:);
[newsstrialids updatedsstrialids justskippedthese_addthemmanually justskippedthese_alreadyadded] = DBadd_SStrialsfromalltrials(conn,currentalltrials,subjectname);
end



%% get an effectiveSSclass for each sstrial per cell - 
currcellids = cell2mat(DBget_x(conn,'SELECT cellid FROM cell WHERE cellid > 234 ORDER BY cellid'));
onlyaddnew_noupdate = 0;
for cn = 1:length(currcellids)
    ctic = tic;
weirdcellidstimid{cn} = DBcalcIU_sseffclass_cell(conn,currcellids(cn),onlyaddnew_noupdate)
disp(sprintf('cell %d took %4.4f seconds\n',currcellids(cn),toc(ctic)));
end

%% make sets for SS birds
weirdthings = DBcalcIU_sssets_subject(conn,DBget_subjectID(conn,subjectname));

%%
%now if histology done - do the histology corrections
%otherwise manually add '9' to the cellcalc regionid column
%then manually add 'byeyeaud' with DBplot_rasterscell_bystim
%
%
% update sstrial protocolmode column
%THIS GOT ADDED TO DBadd_SStrialsfromalltrials - shouldn't need to run it 
%DBprocessIU_sstrialprotocolmode(conn,alltrials,subjectname)






