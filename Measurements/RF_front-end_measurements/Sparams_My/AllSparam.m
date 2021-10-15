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

S0=sparameters('0.s1p');
s11_0=rfparam(S0,1,1);
[~,idx_0]=min(abs(S0.Frequencies-95802500));
plot(s11_0);




S6=sparameters('6.s1p');
s11_6=rfparam(S6,1,1);
[~,idx_6]=min(abs(S6.Frequencies-95802500));
plot(s11_6);

S7=sparameters('7.s1p');
s11_7=rfparam(S7,1,1);
[~,idx_7]=min(abs(S7.Frequencies-95802500));
plot(s11_7);




S14=sparameters('14.s1p');
s11_14=rfparam(S14,1,1);
[~,idx_14]=min(abs(S14.Frequencies-95802500))
plot(s11_14)



s11_0(idx_0)
s11_6(idx_6)
s11_7(idx_7)
s11_14(idx_14)

plot(s11_0(idx_0),'*r');

plot(s11_6(idx_6),'*r');
plot(s11_7(idx_7),'*r');
plot(s11_14(idx_14),'*r')



title('S-Parameters P_{in}=-20 dBm 87.5 - 108 MHz');
legend('0','6', '7', '14')



