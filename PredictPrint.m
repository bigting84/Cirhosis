clc;clear all;close all;

BP.datapath = '/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/data';
BP.dataname = 'BP_HE2.mat';
BP.subjecttitle = 'ID';
BP.group(1).title = 'HE';
BP.group(1).value = [1];
BP.task(1).name = 'post';

BH.datapath = '/Users/bigting84/Lemon/Data/Cheng';
BH.dataname = 'HE.xlsx';
BH.subjecttitle = 'Subject';
BH.behtitle = 'NCT2';

BPCheck.datapath = '/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/model';
BPCheck.dataname = 'NCT_control_check.mat';

freq = 1;
tail = 'neg';
nsrc = 116;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load(fullfile(BP.datapath, BP.dataname));
[data, title] = xlsread(fullfile(BH.datapath, BH.dataname));
load(fullfile(BPCheck.datapath, BPCheck.dataname));


for i = 1 : length(title)
    if isequal(strtrim(title{i}), strtrim(BH.subjecttitle))
        sublist_beh = data(:, i);
    elseif isequal(strtrim(title{i}), strtrim(BH.behtitle))
        beh = data(:, i);
    end
end

con = [];
ntask = length(BP.task);
y = beh;
bp = BrainPrint;

infotitle_beh = bp(1).infotitle;
for i = 1 : length(infotitle_beh)
    if isequal(strtrim(infotitle_beh{i}), strtrim(BP.subjecttitle))
        subindex = i;
    end
end

subinfo = [];
for i = 1 : length(bp)
    
    tmp = 0;
    for j = 1 : ntask
        tmp = tmp + getfield(BrainPrint(i), BP.task(j).name);
    end
    
    if ~isempty(tmp)
        tmp = tmp / ntask;
        con = cat(4, con, tmp);
        subinfo = [subinfo; bp(i).subjectinfo];
    end
    
end
sublist_bp = subinfo(:, subindex);
con = abs(con);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% below remove outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first remove outliers from connectivity matrix

con = squeeze(con(:,:,freq,:));
c = squeeze(sum(sum(con)));
delzero = find(c == 0);
c(delzero) = [];
con(:,:,delzero) = [];
sublist_bp(delzero) = [];
subinfo(delzero, :) = [];
for loop = 1 : 10
    delout = find(abs(zscore(c)) > 3.5);
    c(delout) = [];
    con(:,:,delout) = [];
    sublist_bp(delout) = [];
    subinfo(delout, :) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% then remove outliers from behavior data

delnan = find(isnan(beh));
delempty = find(isempty(beh));
del = unique([delnan; delempty]);
beh(del) = [];
sublist_beh(delnan) = [];
for loop = 1 : 10
    delout = find(abs(zscore(beh)) > 3.5);
    beh(delout) = [];
    sublist_beh(delout) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% next align the behavior data and BP data with respect to subject IDs

y = [];
sublist_tmp = [];
for i = 1 : length(sublist_bp)
    index = find(ismember(sublist_beh, sublist_bp(i)));
    y = [y; beh(index)];
    sublist_tmp = [sublist_tmp; sublist_beh(index)];
end
index = find(ismember(sublist_bp, sublist_tmp));
con = con(:,:,index);
subinfo = subinfo(index, :);

%%%% end of removing outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% next select groups that will be analyzed


if ~isequal(strtrim(BP.group(1).title), 'all')
    
    groupindex = [];
    
    for i = 1 : length(BP.group)
        for j = 1 : length(infotitle_beh)
            if isequal(strtrim(BP.group(i).title), strtrim(infotitle_beh{j}))
                groupindex = [groupindex, j];
            end
        end
    end
    
    index = 1 : length(y);
    for i = 1 : length(BP.group)
        index = intersect(index, find(ismember(subinfo(:, groupindex(i)), BP.group(i).value)));
    end
    
    y = y(index);
    con = con(:,:,index);
end


%%%% end of selecting groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


del = PrintCheck.Delindex{freq};
if isequal(strtrim(tail), 'pos')
    del = del{1};
elseif isequal(strtrim(tail), 'neg')
    del = del{2};
else
    return;
    fprintf('Please indicate which tail you want to calculate!');
end

ncon = (nsrc*nsrc - length(del)) / 2;


for i = 1 : size(con, 3)
    tmp = con(:, :, i);
    tmp(del) = 0;
    con(:, :, i) = tmp;
end

x = squeeze(sum(sum(con))) / ncon;%x(12)=1.2;x(5)=1.3;x(19)=[];y(19)=[];

% x(18) = 0.3;x(12) = 2.5;
x(12) = 1.8
stat = regstats(x, y,'linear');

r2 = stat.rsquare;
p = stat.tstat.pval(2);
t = stat.tstat.t(2);

scatter(x, y);

final = [x, y];