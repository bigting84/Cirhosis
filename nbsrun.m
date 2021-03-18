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
    if bp(i).subjectinfo(2) == 0 && ~isempty(bp(i).post);
        pre = cat(3, pre, bp(i).post);
        ypre = [ypre; bp(i).beh2(1)];
        y2pre = [y2pre; bp(i).beh2(2)];
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


la = size(pre, 3);
lb = size(post, 3);
contrast = [[ones(la, 1), zeros(la, 1)];[zeros(lb, 1), ones(lb, 1)]];
m = (cat(3, pre, post));
m(isinf(m)) = 1;





fileID = fopen('nums1.txt','r');
Define the format of the data to read. Use '%f' to specify floating-point numbers.

formatSpec = '%f';
Read the file data, filling output array, A, in column order. fscanf reapplies the format, formatSpec, throughout the file.

A = fscanf(fileID,formatSpec)