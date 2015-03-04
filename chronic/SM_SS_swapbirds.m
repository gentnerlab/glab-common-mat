
error('do not run me! try: ''edit SM_SS_swapbirds''')

%% transfer setstims bird from ndege to chron box
birdid = '854';

fromNDname = ['Z:\behavior\fromndege\B' birdid '\setstims' birdid '.stim'];
newName = ['D:\experiments\raw\st' birdid '\stims\' 'setstims' birdid '_fromND_' datestr(now,'yyyymmdd+HHMMSS') '.MASTERstimX'];

SM_SS_convertsetstimfilefromndege(fromNDname,newName);

ss1 = SM_SS_readsetstimfile(newName);

nss = ss1([ss1{:,end}] == 1,:);

newSSstimfilename = ['D:\experiments\raw\st' birdid '\stims\' 'setstims' birdid '_fromND_' datestr(now,'yyyymmdd+HHMMSS') '.currsetstim'];

SM_SS_writeS2setstimsstimfile(nss,newSSstimfilename);

%now go remove the 'fromND' and 'X' part

%% transfer setstimsbird from chronbox to ndege
birdid = '';

cd(['D:\experiments\raw\st' birdid '\stims\'])
ss = SM_SS_readsetstimfile(['setstims' birdid '.MASTERstim']);

SM_SS_writeNdegesetstimsfile(ss,['setstims' birdid '_toND_' datestr(date,'yyyymmdd') '.MASTERstim']);

%now go transfer this to ndege via winscp

%% convert 3 and 4 stims to 31 41 to mark a difference (for st650, when I transferred to chron box had been a LONG time since these stims were used)
birdid = '';
Uss = SM_SS_readsetstimfile(SM_SS_getmasterstimfile(birdid));


for i = 1:size(Uss,1)
    if Uss{i,2} == 3
        Uss{i,2} = 31;
    end
    if Uss{i,2} == 4
        Uss{i,2} = 41;
    end
end

newmasterstimname = ['D:\experiments\raw\' birdid '\stims\' 'setstims' birdid '_update34classesto3141_' datestr(now,'yyyymmdd+HHMMSS') '.MASTERstimX'];
SM_SS_writeS2setstimsstimfile(Uss,newmasterstimname);

%now go remove the 'fromND' and 'X' part