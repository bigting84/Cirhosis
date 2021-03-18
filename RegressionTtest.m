clc;clear all;close all;

datapath = '/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/data';
dataname = 'BP_HE2.mat';
group = 1;
site = 'post';
task = 'DST';
tail = 'neg';
thr = 0.01;


load(fullfile(datapath, dataname));
bp = BrainPrint;

pre = [];ypre = [];y2pre = [];
post = [];ypost = [];y2post = [];
for i = 1 : length(bp)
    if bp(i).subjectinfo(2) == group && ~isempty(bp(i).pre);
        pre = cat(3, pre, bp(i).pre);
        ypre = [ypre; bp(i).beh(1)];
        y2pre = [y2pre; bp(i).beh(2)];
    end
    
    if bp(i).subjectinfo(2) == group && ~isempty(bp(i).post);
        post = cat(3, post, bp(i).post);
        ypost = [ypost; bp(i).beh2(1)];
        y2post = [y2post; bp(i).beh2(2)];
    end
end

p = zeros(116);delta = zeros(116);
for i = 1 : 115
    for j = i+1 : 116
        a = squeeze(pre(i,j,:));
        b = squeeze(post(i,j,:));
        [vv, pp] = ttest2(a, b);
        p(i, j) = pp;
        delta(i, j) = mean(b) - mean(a);
    end
end

[indx, indy] = find(delta > 0 & p < 0.005);
index = find(delta > 0 & p < 0.005);
c = [];
for i = 1 : size(post, 3)
    tmp = post(:, :, i);
    c = [c; sum(abs(tmp(index)))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if task == 'DST'
    eval(['ytask=y2' site]);
elseif task == 'NCT'
    eval(['ytask=y' site]);
end

eval(['xtask=' site]);
check = [];
ypred = [];
check_pairs = [];
for loop = 1 : length(ytask)
    
    yout = ytask(loop);
    xout = xtask(:, :, loop);
    yin = ytask;
    yin(loop) = [];
    xin = xtask;
    xin(:, :, loop) = [];
    
    p = zeros(116); r = zeros(116);
    for i = 1 : 115
        [loop, i]
        for j = i+1 : 116
            x = squeeze(xin(i,j,:));
            str = regstats(yin,abs(x),'linear');
            r(i, j) = str.beta(2);
            p(i, j) = str.tstat.pval(2);
        end
    end
    p(p == 0) = 1;
    
    if tail == 'pos'
        [indx, indy] = find(r > 0 & p < thr);
        index = find(r > 0 & p < thr);
    elseif tail == 'neg'
        [indx, indy] = find(r < 0 & p < thr);
        index = find(r < 0 & p < thr);
    end
    check{loop} = [indx, indy];
    
    if loop == 1
        check_pairs = table([indx, indy]);
    else
        check_pairs = intersect(check_pairs, table([indx, indy]));
    end
    
    c = [];
    for i = 1 : size(xin, 3)
        tmp = xin(:, :, i);
        c = [c; sum(abs(tmp(index)))];
    end
    str = regstats(yin,c,'linear');
    ypred = [ypred; str.beta(1) + str.beta(2) * sum(abs(xout(index)))];
end

check_final = unique(check_pairs);

scatter(ytask, ypred);
[cpred, ppred] = corr(ytask, ypred)

% index = find(r > 0 & p < 0.05);
% cpre = [];cpost = [];
% for i = 1 : size(post, 3)
%     tmp = post(:, :, i);
%     cpost = [cpost; sum(abs(tmp(index)))];
% end
% for i = 1 : size(pre, 3)
%     tmp = pre(:, :, i);
%     cpre = [cpre; sum(abs(tmp(index)))];
% end
% [v, pp] = ttest2(cpre, cpost)
% mean(cpre)
% mean(cpost)

