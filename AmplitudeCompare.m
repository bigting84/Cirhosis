clc;clear all;close all;

datapath = 'C:\Users\bigting84\Desktop\USC Projects\Project #4 Cheng\data';
load(fullfile(datapath, 'BP_HE2.mat'));
HEprint = BrainPrint;

load(fullfile(datapath, 'BP_control.mat'));
Cprint = BrainPrint;

a = 89;
b = 17;

che = [];
for i = 1 : length(HEprint) 
    if ~isempty(HEprint(i).pre) && ~isempty(HEprint(i).post) && HEprint(i).subjectinfo(2) == 1
        che = [che, HEprint(i).pre(a, b)];
    end
end

chep = [];
for i = 1 : length(HEprint)
    if  ~isempty(HEprint(i).post) && HEprint(i).subjectinfo(2) == 1
        chep = [chep, HEprint(i).post(a, b)];
    end
end

cnonhe = [];
for i = 1 : length(HEprint)
    if ~isempty(HEprint(i).pre) && HEprint(i).subjectinfo(2) == 0
        cnonhe = [cnonhe, HEprint(i).pre(a, b)];
    end
end

cnonhep = [];
for i = 1 : length(HEprint)
    if ~isempty(HEprint(i).post) && HEprint(i).subjectinfo(2) == 0
        cnonhep = [cnonhep, HEprint(i).post(a, b)];
    end
end

cc = [];
for i = 1 : length(Cprint)
    if ~isempty(Cprint(i).resting)
        cc = [cc, Cprint(i).resting(a, b)];
    end
end