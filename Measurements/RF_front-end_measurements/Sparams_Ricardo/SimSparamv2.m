%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;

[~, ~, raw] = xlsread('C:\Users\Daskals\Desktop\Dropbox\PhD\Papers+Events\MTT2018_Ambient\Measurements\Sparams_Ricardo\Freq95_8MHzsweepPWR.xlsx','Freq95_8MHzsweepPWR','A17:A931');
stringVectors = string(raw(:,1));
stringVectors(ismissing(stringVectors)) = '';

matr1 = stringVectors(:,1);
matr2 = split(matr1,",");
dVecss = cellfun(@str2num, matr2);
complex0 =dVecss(:, 3)+j*dVecss(:, 4);

figure(1)
smithchart();
hold on;

plot(complex0);

%% Import the data
[~, ~, raw] = xlsread('C:\Users\Daskals\Desktop\Dropbox\PhD\Papers+Events\MTT2018_Ambient\Measurements\Sparams_Ricardo\Pin-30dBmsweepfreq.xlsx','Pin-30dBmsweepfreq','A17:A1358');
stringVectors = string(raw(:,1));
stringVectors(ismissing(stringVectors)) = '';

%% Create table
Pin30dBmsweepfreq = table;

matr1b = stringVectors(:,1);
matr2 = split(matr1b,",");

dVec2 = cellfun(@str2num, matr2);

complex =dVec2(:, 3)+j*dVec2(:, 4);

figure(2)
smithchart();
hold on;

plot(complex);
