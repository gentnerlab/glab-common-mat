function motdat = SM_getmotifinfo(varargin)

if isempty(varargin)
    fname = fullfile(getdanroot(),'stimuli','MotifBoundaries_010509.txt');
else
    fname = varargin{1};
end

fid = fopen(fname);
motdat = textscan(fid,'%d%d%s%f%f','Delimiter',';');
fclose(fid);

end