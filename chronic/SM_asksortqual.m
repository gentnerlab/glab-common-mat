function sortQual = SM_asksortqual(dispString)

if nargin < 1
    dispString = 'Select sort quality:';
elseif isempty(dispString)
    dispString = 'Select sort quality:';
end

str = {'5.0','4.5','4.0','3.5','3.0','2.5','2.0','1.5','1.0','0.5','0.0'};

[selection,ok] = listdlg('PromptString',dispString,'SelectionMode','single','ListString',str,'ListSize',[600 150]);

if ok == 1
    sortQual = str2double(str{selection});
else
    sortQual = -99;
end

end

