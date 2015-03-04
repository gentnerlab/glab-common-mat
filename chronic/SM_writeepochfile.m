function success = SM_writeepochfile(unit,outfile)


success = 1;

fid = fopen(outfile,'w'); %TODO:check if already exists?

if fid > 0
    
    fprintf(fid,'experimenter.experimentername,\t\n');
    fprintf(fid,'experiment.experimentname,\t\n');
    fprintf(fid,'subject.subjectname,\t%s\n',unit.subject);
    fprintf(fid,'sex.sexname,\t\n');
    fprintf(fid,'trainingtype.trainingtypename,\t\n');
    fprintf(fid,'penetration.rostral,\t\n');
    fprintf(fid,'penetration.lateral,\t\n');
    fprintf(fid,'penetration.lesiondepth,\t\n');
    fprintf(fid,'penetration.lesionhealed,\t\n');
    fprintf(fid,'penetration.lesionlocated,\t\n');
    fprintf(fid,'hemisphere.hemispherename,\t\n');
    fprintf(fid,'electrode.serialnumber,\t\n');
    fprintf(fid,'electrodetype.electrodetypename,\t\n');
    fprintf(fid,'electrodetype.impedence,\t\n');
    fprintf(fid,'electrodetype.padconfiguration,\t\n');
    fprintf(fid,'site.depth,\t\n');
    fprintf(fid,'site.regionconfirmation,\t\n');
    fprintf(fid,'region.regionname,\t\n');
    
    fprintf(fid,'epoch.starttimestamp,\t\n');
    fprintf(fid,'epoch.endtimestamp,\t\n');
    fprintf(fid,'protocol.protocoltypename,\t\n');
    %fprintf(fid,'protocol.xyz,\t\n'); %TODO: moreprotocolstuff
    
    fprintf(fid,'cell.cellname,\t%s\n',sprintf('marker%03d',unit.marker)); %this will be used to uniquely identify a cell given an epoch - use one marker code per cell in spike2 then cellname will be 'marker###'
    fprintf(fid,'cell.cellmarker,\t%d\n',unit.marker);
    
    fprintf(fid,'trial.samplingrate,\t\n'); %this is a property of trial which should be allowed to change, but this one will get used for all
    fprintf(fid,'sortquality.sortquality,\t\n'); %this is a property of spiketrain so will get used for all spike trains below - is there a way to change it so that it can be different for different spike trains (ie allow us to mark noise/artifacts on a trial by trial basis?)
    
    numtrials = size(unit.trials,1);
    fprintf(fid,'epoch_numberoftrials,\t%d\n',numtrials);
    
    for trialnum = 1:numtrials
        fprintf(fid,'\nstimulus.stimulusfilename,\t%s\n',unit.trials{trialnum,6});
        fprintf(fid,'trial.timestamp,\t\n');
        fprintf(fid,'trial.stimcodes,\t%d\t%d\t%d\t%d\n',unit.trials{trialnum,7});
        fprintf(fid,'trial.secondsbeforestart ,\t%2.4f\n',unit.trials{trialnum,5}(1));
        fprintf(fid,'trial.secondsafterstart ,\t%2.4f\n',unit.trials{trialnum,5}(2));
        
        numKBevents = size(unit.trials{trialnum,8}.times,1);
        fprintf(fid,'numkbevents,\t%d\n',numKBevents);
        fprintf(fid,'trial_keyboardtimes,\t\n');
        for i = 1:numKBevents
            fprintf(fid,'%2.4f\n',unit.trials{trialnum,8}.times(i));
        end
        fprintf(fid,'trial_keyboardcodes,\t\n');
        for i = 1:numKBevents
            fprintf(fid,'%d\t%d\t%d\t%d\n',unit.trials{trialnum,8}.codes(i,:));
        end
        
        numDMevents = size(unit.trials{trialnum,9}.times,1);
        fprintf(fid,'numdmevents,\t%d\n',numDMevents);
        fprintf(fid,'trial_digmarktimes,\t\n');
        for i = 1:numDMevents
            fprintf(fid,'%2.4f\n',unit.trials{trialnum,9}.times(i));
        end
        fprintf(fid,'trial_digmarkcodes,\t\n');
        for i = 1:numDMevents
            fprintf(fid,'%d\t%d\t%d\t%d\n',unit.trials{trialnum,9}.codes(i,:));
        end
        
        numSpikes = size(unit.trials{trialnum,10},1);
        fprintf(fid,'spiketrain.spikecount,\t%d\n',numSpikes);
        fprintf(fid,'spiketrain.spiketimes,\t\n');
        for i = 1:numSpikes
            fprintf(fid,'%2.4f\n',unit.trials{trialnum,10}(i));
        end
%         fprintf(fid,'Waveforms,\t\n');
%         for i = 1:numSpikes
%             for j = 
%             fprintf(fid,'%2.4f\n',unit.trials{trialnum,11}(i,j));
%             end
%         end
        
    end
    
    fclose(fid);
else
    success = -1;
end

end