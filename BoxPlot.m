clc;clear all;close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datapath = '/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/data'; 
dataname = 'BP_control.mat';
load(fullfile(datapath, dataname));
bp = BrainPrint;

ctl = [];yctl = [];yctl2 = [];
for i = 1 : length(bp)
    if ~isempty(bp(i).resting)
        ctl = cat(3, ctl, bp(i).resting);
        yctl = [yctl; bp(i).beh(1)];
        yctl2 = [yctl2; bp(i).beh(2)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datapath = '/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/data';
dataname = 'BP_HE2.mat';
group = 1;

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

group = 1;

load(fullfile(datapath, dataname));
bp = BrainPrint;

pre_1 = [];ypre_1 = [];y2pre_1 = [];
post_1 = [];ypost_1 = [];y2post_1 = [];
for i = 1 : length(bp)
    if bp(i).subjectinfo(2) == group && ~isempty(bp(i).pre);
        pre_1 = cat(3, pre_1, bp(i).pre);
        ypre_1 = [ypre_1; bp(i).beh(1)];
        y2pre_1 = [y2pre_1; bp(i).beh(2)];
    end
    
    if bp(i).subjectinfo(2) == group && ~isempty(bp(i).post);
        post_1 = cat(3, post_1, bp(i).post);
        ypost_1 = [ypost_1; bp(i).beh2(1)];
        y2post_1 = [y2post_1; bp(i).beh2(2)];
    end
end


for i = 1 : size(ctl, 3)
    ctl(:,:,i) = ctl(:,:,i) + ctl(:,:,i)';
end
ctl(isnan(ctl)) = 1;
pre(isinf(pre)) = 1;
post(isinf(post)) = 1;
pre_1(isinf(pre_1)) = 1;
post_1(isinf(post_1)) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/resources/nbs_ctlprenonHEabs.mat')
[left,right] = find(nbs.NBS.con_mat{1});
% load('/Users/bigting84/Desktop/USC Projects/Project #4 Cheng/model/DST_control_check2.mat');
% pairs = PrintCheck.PairCheck{1,1}{1,1};
% left = pairs(:,1); right = pairs(:,2);
% left = [left;[73;80;89;89;97;97;100;108;108;108;109]];
% right = [right;[69;69;70;80;69;70;69;47;70;99;69]];



dstpairs = [98, 57;107,22;108,22;108,91;108,93;108,98];
nctpairs = [73,69; 80,39; 89,69; 89,70; 89,80; 97,69; 97,70; ...
    100,69; 108,47; 108,70; 108,99; 109,69];
pairs = [dstpairs;nctpairs];
left = pairs(:, 1);
right = pairs(:, 2);



cc = [];c1 = [];c2 = [];
for i = 1 : length(left)
    cc = [cc, squeeze(abs(ctl(left(i), right(i), :)))];
    c1 = [c1, squeeze(abs(pre(left(i), right(i), :)))];
    c2 = [c2, squeeze(abs(post(left(i), right(i), :)))];
end
%[v, p] = corr(sum(c, 2), yctl2)
[vall, pall] = ttest2(mean(c2, 2), mean(c1, 2))
[v, p] = ttest2((c1), (c2))
mean(cc(:))
mean(c1(:)) 
mean(c2(:))

%%%%%%%%%%%%% violin plot %%%%%%%%%%%%%%%%%%%%%%%%%


% figure('color', [1 1 1])
% vs = violinplot(c1);
% for i = 1 : size(c1,2)
% vs(i).ViolinColor = [45,186,30]/255;
% vs(i).MedianColor = [0,0,0];
% end
% hold on;
% vs2 = violinplot(c2+0.05);
% for i = 1 : size(c1,2)
% vs2(i).ViolinColor = [229,43,0]/255;
% vs2(i).MedianColor = [0,0,1];
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% violin plot for individuals

figure('color', [1 1 1])
nc = size(cc, 1);n1 = size(c1, 1);n2 = size(c2, 1);
call = [cc; c1; c2];
for i = 1 : nc
    statename{i} = 'Control';
end
for i = 1 : n1
    statename{nc+i} = 'Pre_LT';
end
for i = 1 : n2
    statename{nc+n1+i} = 'Post_LT';
end
boxplot(mean(call,2), statename,'Notch','on','Widths',0.2);
set(gca, 'FontSize', 30)
ylabel('Network strength','FontSize',30);