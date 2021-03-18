% function [PairCheck, Delindex] = FindPrint(BrainPrint, TaskName, beh, freq, pthr)
clc;clear all;close all;

BP.datapath = 'C:\Users\bigting84\Desktop\USC Projects\Project #4 Cheng\data';
BP.dataname = 'BP_control.mat';
BP.subjecttitle = 'ID';
BP.group(1).title = 'all';
%BP.group(1).value = 0;
% BP.group(1).title = 'Gender';
% BP.group(1).value = 2;
% BP.group(2).title = 'Condition';
% BP.group(2).value = 1;
BP.task(1).name = 'resting';

BH.datapath = 'C:\Data\Cheng';
BH.dataname = 'control.xlsx';
BH.subjecttitle = 'Subject';
BH.behtitle = 'DST';

savepath = 'C:\Users\bigting84\Desktop\USC Projects\Project #4 Cheng\model';
savename = 'NCT_control_check.mat';
pthr = 0.05;
nsrc = 116;

delpeak = [];
nsort = 100;
%load('C:\Users\bigting84\Documents\MATLAB\DPABI_V3.0_171210\DPABI_V3.0_171210\Templates\aal_Labels.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load(fullfile(BP.datapath, BP.dataname));
[data, title] = xlsread(fullfile(BH.datapath, BH.dataname));


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
        con = abs(cat(4, con, tmp));
        subinfo = [subinfo; bp(i).subjectinfo];
    end
    
end
sublist_bp = subinfo(:, subindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% below remove outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first remove outliers from connectivity matrix

c = squeeze(sum(sum(sum(con))));
delzero = find(c == 0);
c(delzero) = [];
con(:,:,:,delzero) = [];
sublist_bp(delzero) = [];
subinfo(delzero, :) = [];
for loop = 1 : 10
    delout = find(abs(zscore(c)) > 3.5);
    c(delout) = [];
    con(:,:,:,delout) = [];
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
con = con(:,:,:,index);
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
        index = intersect(index, find(subinfo(:, groupindex(i)) == BP.group(i).value));
    end
    
    y = y(index);
    con = con(:,:,:,index);
end


%%%% end of selecting groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ybackup = y;
ybegin = y;
conbackup = con;
conbegin = con;

ybackup(delpeak) = [];
conbackup(:,:,:,delpeak) = [];
nsub = length(ybackup);

ynewpall = zeros(nsub, 4);
ynewnall = zeros(nsub, 4);

PrintCheck = [];
for loop = 1 : nsub
    
    loop
    
    y = ybackup;
    con = conbackup;
    yout = y(loop);
    conout = con(:,:,:,loop);
    y(loop) = [];
    con(:,:,:,loop) = [];
    
    
    Rpos = zeros(nsrc,nsrc,4);
    Ppos = zeros(nsrc,nsrc,4);
    Rneg = zeros(nsrc,nsrc,4);
    Pneg = zeros(nsrc,nsrc,4);
    Tpos = zeros(nsrc,nsrc,4);
    Tneg = zeros(nsrc,nsrc,4);
    
    for f = 1 : 1
        for i = 1 : nsrc-1
            formatSpec = ['Processing source %d, in frequency band %d\n'];
            fprintf(formatSpec, [i, f]);
            for j = i+1 : nsrc
                x = squeeze(con(j, i, f, :));
                str = regstats(y,x,'linear');
                if str.beta(2) > 0
                    Rpos(j, i, f) = sqrt(str.rsquare);
                    Ppos(j, i, f) = str.tstat.pval(2);
                    Tpos(j, i, f) = str.tstat.t(2);
                elseif str.beta(2) < 0
                    Rneg(j, i, f) = sqrt(str.rsquare);
                    Pneg(j, i, f) = str.tstat.pval(2);
                    Tneg(j, i, f) = str.tstat.t(2);
                end
            end
        end
    end
    
    
    
    for freq = 1 : 1
        
        P2 = Ppos(:, :, freq);
        T2 = Tpos(:, :, freq);
        R2 = Rpos(:, :, freq);
        P2 = P2 + P2' + eye(nsrc);
        T2 = T2 + T2';
        index1 = unique([find(P2 > pthr); find(P2 == 0)]);
        T2(index1) = 0;
        R2 = R2 + R2';
        R2(index1) = 0;
        P2(index1) = 0;
        n = length(find(R2 ~= 0));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        con1p = squeeze(con(:,:,freq,:));
        
        for i = 1 : size(con1p, 3)
            tmp = con1p(:, :, i);
            tmp(index1) = 0;
            con1p(:, :, i) = tmp;
        end
        
        conout(index1) = 0;
        xout = sum(conout(:));
        str = regstats(y,squeeze(sum(sum(con1p))),'linear');
        ynewpall(loop, freq) = str.beta(1) + str.beta(2) * xout;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        check1 = [];
        for i = 1 : nsrc
            for j = 1 : nsrc
                if con1p(i, j, freq, 1) ~= 0
                    check1 = [check1; [i, j, P2(i,j), R2(i,j)]];
                end
            end
        end
        
%         ynew = [];
%         for i = 1 : size(check1, 1)
%             a = check1(i, 1);
%             b = check1(i, 2);
%             str = regstats(y, squeeze(con1p(a, b, :)),'linear');
%             ynew = [ynew; str.beta(1) + str.beta(2) * conout(a, b)];
%         end
%         
%         [yv, order] = sort(abs(ynew-yout));
%         check1 = check1(order(1:nsort), :);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        P2 = Pneg(:, :, freq);
        T2 = Tneg(:, :, freq);
        R2 = Rneg(:, :, freq);
        P2 = P2 + P2' + eye(nsrc);
        T2 = T2 + T2';
        index2 = unique([find(P2 > pthr); find(P2 == 0)]);
        T2(index2) = 0;
        R2 = R2 + R2';
        R2(index2) = 0;
        P2(index2) = 0;
        n = length(find(R2 ~= 0));
        
        
        
        con1n = squeeze(con(:,:,freq,:));
        
        for i = 1 : size(con1n, 3)
            tmp = con1n(:, :, i);
            tmp(index2) = 0;
            con1n(:, :, i) = tmp;
        end
        
        conout(index2) = 0;
        xout = sum(conout(:));
        str = regstats(y,squeeze(sum(sum(con1n))),'linear');
        ynewnall(loop, freq) = str.beta(1) + str.beta(2) * xout;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        check2 = [];
        for i = 1 : nsrc
            for j = 1 : nsrc
                if con1n(i, j, freq, 1) ~= 0
                    check2 = [check2; [i, j, P2(i,j), R2(i,j)]];
                end
            end
        end
        
%         ynew = [];
%         for i = 1 : size(check2, 1)
%             a = check2(i, 1);
%             b = check2(i, 2);
%             str = regstats(y, squeeze(con1n(a, b, :)),'linear');
%             ynew = [ynew; str.beta(1) + str.beta(2) * conout(a, b)];
%         end
%         
%         [yv, order] = sort(abs(ynew-yout));
%         check2 = check2(order(1:nsort), :);
        
        Delindex{freq} = [{index1}, {index2}];
        PairCheck{freq} = [{check1}, {check2}];
        
    end
 
    PrintCheck(loop).Delindex = Delindex;
    PrintCheck(loop).PairCheck = PairCheck;
    PrintCheck(loop).title =[{'region1'},{'region2'},{'pvalue'},{'connectivity'}];
end

checkp = zeros(116);
for i = 1 : length(PrintCheck)
    c = PrintCheck(i).PairCheck{1}{1};
    for j = 1 : size(c, 1)
        checkp(c(j, 1), c(j, 2)) = checkp(c(j, 1), c(j, 2)) + 1;
    end
end

checkfinal = [];
for i = 1 : 116
    for j = 1 : 116
        if checkp(i, j) == length(ybackup)
            checkfinal = [checkfinal; [i, j]];
        end
    end
end

load('C:\Users\bigting84\Desktop\USC Projects\Project #4 Cheng\model\DST_control_check.mat');
PrintCheck.Delindex{1}{1} = find(checkp ~= length(ybackup));
PrintCheck.PairCheck{1}{1} = checkfinal;


% save(fullfile(savepath, savename), 'PrintCheck');