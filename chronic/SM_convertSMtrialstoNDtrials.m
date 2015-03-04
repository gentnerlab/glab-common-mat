function NDtrials = SM_convertSMtrialstoNDtrials(SMtrials)

for i = 1:size(SMtrials,1)
    NDtrials(i,:) = SM_convertSMtrialtoNDtrial(SMtrials(i,:));
end


end
