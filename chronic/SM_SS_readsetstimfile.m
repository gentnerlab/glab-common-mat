function setstims = SM_SS_readsetstimfile(infile)
% setstims = SM_SS_readsetstimfile(infile)

fidIN = fopen(infile,'r');
tline = fgets(fidIN);
if strcmp(tline(1),'"') == 1 %this is spike2readable ( has " and , )
    frewind(fidIN);
    dat1 = textscan(fidIN, '%s %d %d %d %d %d %d %d\n','delimiter',' \t,','multipledelimsasone',1);
    frewind(fidIN);
    dat2 = textscan(fidIN, '%s %d %d %d %d %d %d %d\r','delimiter',' \t,','multipledelimsasone',1);
    
    %this is a terribly inelegant hack to get around the fact that depending on which
    %instance of matlab is called, I need to parse the file with either \n
    %or \r, and for the life of me I can't figure out why.
    if size(dat2{1,1},1) > size(dat1{1,1},1)
        dat = dat2;
    else
        dat = dat1;
    end
    
    %     if double(tline(end)) == 10
    %         dat = textscan(fidIN, '%s %d %d %d %d %d %d %d\n','delimiter',' \t,','multipledelimsasone',1);
    %     elseif double(tline(end)) == 13
    %         dat = textscan(fidIN, '%s %d %d %d %d %d %d %d\r','delimiter',' \t,','multipledelimsasone',1);
    %     else
    %         error('huh??');
    %     end
    
    for i = 1:length(dat{1})
        dat{1}{i} = dat{1}{i}(2:end-1);
    end
else %this is from ndege ( no " nor , )
    frewind(fidIN);
    dat = textscan(fidIN, '%s %d %d %d %d %d %d %d\n');
end
setstims = [dat{1} num2cell(dat{2}) num2cell(dat{3}) num2cell(dat{4}) num2cell(dat{5}) num2cell(dat{6}) num2cell(dat{7}) num2cell(dat{8})];


fclose(fidIN);

end