function searchset = SM_SS_picksearchset(setstims,nosilence)
%searchset = SM_SS_picksearchset(setstims)


if ~exist('nosilence','var')
nosilence = 0;
end

sizeofsearchset = 18;
percentOTdesired = 100;
percentTdesired = 15;
percentUTdesired = 0;
minNovel = 0;

%shortcircuit
numTpairsdesired = 3;


%TODO: make this happen - assurecurrentsetinclusion = 1;

classes = cell2mat(setstims(:,2));
for i = 1:6
    classinds{i} = classes==i;
end
numOTin = sum(classinds{1}) + sum(classinds{2});
numTin  = sum(classinds{3}) + sum(classinds{4});
numUTin = sum(classinds{5}) + sum(classinds{6});
novelinds = classes==-1;


if percentOTdesired == 0
    numOTpairsout = 0;
else
    numOTpairsout = round((numOTin*(percentOTdesired/100))/2);
end

if ~exist('numTpairsdesired','var')
if percentTdesired == 0
    numTpairsout = 0;
else
    numTpairsout = round((numTin*(percentTdesired/100)/2));
end
else
    numTpairsout = numTpairsdesired;
end

if percentUTdesired == 0
    numUTpairsout = 0;
else
    numUTpairsout = round((numUTin*(percentUTdesired/100)/2));
end

numNovelout = sizeofsearchset - 2*(numOTpairsout + numTpairsout + numUTpairsout);
if numNovelout < minNovel
    error('numNovelout < minNovel: you need to configure your parameters differently')
end

outinds = [];

tinds = find(classinds{1});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numOTpairsout)];

tinds = find(classinds{2});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numOTpairsout)];

tinds = find(classinds{3});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numTpairsout)];

tinds = find(classinds{4});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numTpairsout)];

tinds = find(classinds{5});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numUTpairsout)];

tinds = find(classinds{6});
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numUTpairsout)];


tinds = find(novelinds);
tinds = tinds(randperm(length(tinds)));
outinds = [outinds;tinds(1:numNovelout)];

searchset = setstims(outinds,:);

if ~nosilence
   searchset(size(searchset,1)+1,:) =  {'silence_40k_5s.wav',-1,1,-1,-1,-1,-1,0};
end


end
