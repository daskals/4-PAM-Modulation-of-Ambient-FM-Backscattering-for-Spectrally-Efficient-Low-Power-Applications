222%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;



%%

figure(5)
smithchart();
hold on;

S0=sparameters('tagante_min20.s1p');
s11_0=rfparam(S0,1,1);
[~,idx_0]=min(abs(S0.Frequencies-98570000));
plot(s11_0);

% 
% S1=sparameters('genante_min20.s1p');
% s11_1=rfparam(S1,1,1);
% [~,idx_1]=min(abs(S1.Frequencies-98570000));
% plot(s11_1);

s11_0(idx_0)
plot(s11_0(idx_0),'*r');
z = gamma2z(s11_0(idx_0))
%z = gamma2z(s11_1(idx_1))
%title('S-Parameters P_in}=-20 dBm 87.5 - 108 MHz');




