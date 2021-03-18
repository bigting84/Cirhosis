clc;clear all;close all

load('/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/resources/nbs_ctlprenonHEabs.mat')
[left,right] = find(nbs.NBS.con_mat{1});

lr = [left; right];
lru = unique(lr);

nlab = nbs.NBS.node_label(lru);
nlab = [nlab, num2cell(lru)];

left2 = left;
right2 = right;

nconn = length(left);

for i = 1 : nconn
    
    a = left(i);
    b = right(i);
    
    left2(i) = find(lru == a);
    right2(i) = find(lru == b);
    
end

c = zeros(length(lru));
for i = 1 : nconn
    c(left2(i), right2(i)) = 1;
end

c2 = c + c';
nlab = [nlab, num2cell(sum(c2)')];