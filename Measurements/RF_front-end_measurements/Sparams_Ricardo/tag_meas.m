%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;


Fstart=87.5;
Fstop= 108;
steps=201;
Steps=[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ];

volts=[
    0 
    0.056
    0.112
    0.167
    0.223
    0.279
    0.334
    0.389
    0.442
    0.494
    0.536
    0.566
    0.587
    0.602
    0.613
    0.621 ];

uAmpCon=[
    15.7
    15.7
    15.7
    15.7
    15.7
    15.7
    15.7
    15.7
    15.7
    15.7
    15.9
    16.1
    16.4
    16.8
    17.3
    17.8 ];

uAmpCon=uAmpCon*10^-6;
Voltage=2.012;
%for 15 
WithRFfront15=17.9-15.8;


powerCon= uAmpCon.*Voltage;


figure(2);
plot(Steps, volts, 'o')

figure1= figure;
volts4steps=[0 334 389  602] 
powerCon4steps=[31.59  31.59 31.59  33.8];
axes1  = axes('Parent',figure1,'YGrid','on','XGrid','on','FontSize',20);
plot(volts4steps,powerCon4steps,'Marker','o','LineWidth',1.5,'Color',[0 0 0]);
set(axes1,'FontSize',20)
xlim(axes1,[0 621]);
box(axes1,'on');
ylabel('Tag Power Consumption (uW)','FontSize',20);
xlabel('DAC output (mV)','FontSize',20);
grid(axes1,'on');
rect = [0.4, 0.75, .15, .15];
set(0, 'DefaultAxesFontName', 'Arial'); 
print(figure1,'-depsc', '-tiff', '-r300', 'volts_vs_power.eps'); 





%%

figure4= figure;
axes4  = axes('Parent',figure4,'YGrid','on','XGrid','on','FontSize',20);

hsm = smithchart
hsm.LabelSize=18
hold on;

S0=sparameters('0_v2.s1p'); 
s11_0=rfparam(S0,1,1);
[~,idx_0]=min(abs(S0.Frequencies-95802500));
[~,idx_0_108]=min(abs(S0.Frequencies-108000000));

plot(s11_0, 'LineStyle','-','LineWidth',2);

S6=sparameters('6_v2.s1p');
s11_6=rfparam(S6,1,1);
[~,idx_6]=min(abs(S6.Frequencies-95802500));
[~,idx_6_108]=min(abs(S6.Frequencies-108000000));
plot(s11_6, 'LineStyle','--','LineWidth',2)

S7=sparameters('7_v2.s1p');
s11_7=rfparam(S7,1,1);
[~,idx_7]=min(abs(S7.Frequencies-95802500));
[~,idx_7_108]=min(abs(S7.Frequencies-108000000));
plot(s11_7, 'LineStyle',':','LineWidth',2)

S13=sparameters('13_v2.s1p');
s11_13=rfparam(S13,1,1);
[~,idx_13]=min(abs(S13.Frequencies-95802500));
[~,idx_13_108]=min(abs(S13.Frequencies-108000000));
plot(s11_13, 'LineStyle','-.','LineWidth',2)

plot([s11_0(idx_0),s11_6(idx_6), s11_7(idx_7), s11_13(idx_13)], 'o-','LineWidth',1.2, 'Color',[0 0 0], 'Markersize', 8);
plot([s11_0(idx_0_108),s11_6(idx_6_108), s11_7(idx_7_108), s11_13(idx_13_108)], '*-','LineWidth',1.2, 'Color',[0 0 0], 'Markersize', 8);
%plot(s11_6(idx_6),'*r','LineWidth',1.5, 'Color',[0 0 0], 'Markersize', 12);
%plot(s11_7(idx_7),'+r','LineWidth',1.5, 'Color',[0 0 0], 'Markersize', 12);
%plot(s11_13(idx_13),'^r','LineWidth',1.5, 'Color',[0 0 0], 'Markersize', 12);
%title('S-Parameters P_{in}=-20 dBm 87.5 - 108 MHz');


%set(axes4,'FontSize',20)
%box(axes4,'on');
%grid(axes4,'on');
rect = [0.4, 0.75, .15, .15];
lgd =legend('0 mV','334 mV', '389 mV', '602 mV' , '95.8 MHz', '108 MHz', 'Location','SouthEast', 'FontSize')

%lgd =legend('0 mV','334 mV', '389 mV', '602 mV' , '95.8 MHz, \Gamma_1: -0.71-j0.69','95.8 MHz, \Gamma_2: -0.30-j0.24', '95.8 MHz, \Gamma_3: 0.008+j0.15','95.8 MHz, \Gamma_4: 0.31+j0.63', 'Location','SouthEast', 'FontSize')
lgd.FontSize = 16;
set(0, 'DefaultAxesFontName', 'Arial'); 
print(figure4,'-depsc', '-tiff', '-r300', '4pam_smith.eps'); 

%%

figure(5)
smithchart();
hold on;

S0=sparameters('0.s1p');
s11_0=rfparam(S0,1,1);
[~,idx_0]=min(abs(S0.Frequencies-95802500));
plot(s11_0);

S3=sparameters('3.s1p');
s11_3=rfparam(S3,1,1);
[~,idx_3]=min(abs(S3.Frequencies-95802500));
plot(s11_3);

S4=sparameters('4.s1p');
s11_4=rfparam(S4,1,1);
[~,idx_4]=min(abs(S4.Frequencies-95802500));
plot(s11_4);

S5=sparameters('5.s1p');
s11_5=rfparam(S5,1,1);
[~,idx_5]=min(abs(S5.Frequencies-95802500));
plot(s11_5);

S6=sparameters('6.s1p');
s11_6=rfparam(S6,1,1);
[~,idx_6]=min(abs(S6.Frequencies-95802500));
plot(s11_6)

S7=sparameters('7.s1p');
s11_7=rfparam(S7,1,1);
[~,idx_7]=min(abs(S7.Frequencies-95802500));
plot(s11_7)

S8=sparameters('8.s1p');
s11_8=rfparam(S8,1,1);
[~,idx_8]=min(abs(S8.Frequencies-95802500));
plot(s11_8)


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

plot(s11_0(idx_0),'*r');
plot(s11_3(idx_3),'*r');
plot(s11_4(idx_4),'*r');
plot(s11_5(idx_5),'*r');
plot(s11_6(idx_6),'*r');
plot(s11_7(idx_7),'*r');
plot(s11_8(idx_8),'*r');
plot(s11_9(idx_9),'*r');
plot(s11_10(idx_10),'*r')
plot(s11_11(idx_11),'*r');
plot(s11_12(idx_12),'*r');

title('S-Parameters P_{in}=-20 dBm 87.5 - 108 MHz');
legend('0 mV', '167 mV','223 mV', '279 mV','334 mV', '389 mV','442 mV', '494 mV','536 mV','566 mV', '587 mV' , '95.8 MHz' )



