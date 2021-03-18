clc;clear all;close all;

dstpairs = [98, 57;107,22;108,22;108,91;108,93;108,98];
nctpairs = [73,69; 80,39; 89,69; 89,70; 89,80; 97,69; 97,70; ...
    100,69; 108,47; 108,70; 108,99; 109,69];

pairs = [dstpairs; nctpairs];
left = pairs(:, 1);
right = pairs(:, 2);

lr = [left; right];
lru = unique(lr);

% nlab = nbs.NBS.node_label(lru);
nlab = [];
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

