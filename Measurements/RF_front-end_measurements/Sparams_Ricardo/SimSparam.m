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



S9=sparameters('9.s1p');
s11_9=rfparam(S9,1,1);
[~,idx_9]=min(abs(S9.Frequencies-95802500));
plot(s11_9)

S10=sparameters('10.s1p');
s11_10=rfparam(S10,1,1);
[~,idx_10]=min(abs(S10.Frequencies-95802500));
plot(s11_10)


S11=sparameters('11.s1p');
s11_11=rfparam(S11,1,1);
[~,idx_11]=min(abs(S11.Frequencies-95802500));
plot(s11_11)


S12=sparameters('12.s1p');
s11_12=rfparam(S12,1,1);
[~,idx_12]=min(abs(S12.Frequencies-95802500));
plot(s11_12)

S13=sparameters('13.s1p');
s11_13=rfparam(S13,1,1);
[~,idx_13]=min(abs(S13.Frequencies-95802500));
plot(s11_13)

S14=sparameters('14.s1p');
s11_14=rfparam(S14,1,1);
[~,idx_14]=min(abs(S14.Frequencies-95802500));
plot(s11_14)





S22=sparameters('22.s1p');
s11_22=rfparam(S22,1,1);
[~,idx_22]=min(abs(S22.Frequencies-95802500));
plot(s11_22)





plot(s11_0(idx_0),'*r');

plot(s11_9(idx_9),'*r');
plot(s11_10(idx_10),'*r')
plot(s11_11(idx_11),'*r');
plot(s11_12(idx_12),'*r');
plot(s11_13(idx_13),'*r');
plot(s11_14(idx_14),'*r')

plot(s11_22(idx_22),'*r');


title('S-Parameters P_{in}=-20 dBm 87.5 - 108 MHz');
%legend('0 mV', '167 mV','223 mV', '279 mV','334 mV', '389 mV','442 mV', '494 mV','536 mV','566 mV', '587 mV' , '95.8 MHz' )
legend('0','9','10', '11','12','13', '14' ,'22')


