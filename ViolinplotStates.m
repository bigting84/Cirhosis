clc;clear all;close all;

[data, title] = xlsread('State16ThetaMacc10.xls');

a = data(:,14:23);

statename = cell(1520, 1);
for i = 1 :10
    for j = 1 : 152
        if i == 10
            statename{152*(i-1)+j} = ['State99'];
        else
            statename{152*(i-1)+j} = ['State' num2str(i)];
        end
    end
end

a = reshape(a, 1520, 1);

figure('color',[1 1 1]);
vs = violinplot(a, statename);
vs(8).ViolinColor = [45,186,30]/255;
vs(9).ViolinColor = [229,43,0]/255;
vs(10).ViolinColor = [255,255,43]/255;
ylabel('Proportional occupancy')
set(gca,'FontSize',30);