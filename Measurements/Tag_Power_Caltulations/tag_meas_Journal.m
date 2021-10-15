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
Steps=[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];


%Current ADC is 240 uA
volts=[
    0 
    0.057
    0.113
    0.168
    0.222
    0.278
    0.333
    0.387
    0.441
    0.490
    0.529
    0.557
    0.576
    0.590
    0.600
    0.608
    0.616
    0.625
    ];


        %//11->15.5
        %//13-16.2
        %//7->15.1
        %//6->15.1
        %//0->15.1   
        
        
uAmpCon=[
    15.1 %0
    15.1 %1
    15.1 %2
    15.1 %3
    15.1 %4
    15.1 %5
    15.1 %6
    15.1 %7
    15.1 %8
    15.1 %9
    15.2 %10
    15.2 %11
    15.7 %12
    16.2 %13
    16.8 %14
    17.1 %15
    18.4 %16
    18.7 %17
    ];

uAmpCon=uAmpCon;
Voltage=1.8;
powerCon= uAmpCon.*Voltage;
figure1= figure;
volts4steps=[0  0.333 0.387  0.600] 
powerCon4steps=[15.1 15.1 15.1 16.8];

axes1  = axes('Parent',figure1,'YGrid','on','XGrid','on','FontSize',18);
%plot(volts*1000,Steps,'Marker','o','LineWidth',1.2,'Color',[0 0 0]);
%stem(volts4steps*1000,powerCon4steps, 'LineWidth',1.2,'Marker','*', 'Color','r');

plot(volts,powerCon,'LineWidth',2, 'Marker','o');
hold on;
plot(volts(1),powerCon(1),'r+', 'MarkerSize',15, 'LineWidth',1.8) 
plot(volts(7),powerCon(7),'r+', 'MarkerSize',15, 'LineWidth',1.8) 
plot(volts(8),powerCon(8),'r+', 'MarkerSize',15, 'LineWidth',1.8) 
plot(volts(15),powerCon(15),'r+', 'MarkerSize',15, 'LineWidth',1.8) 
% marking the 10th data point of x and y
ylabel('Tag Power Consuption (\muW)','FontSize',18);
set(axes1,'FontSize',18)

ylim(axes1,[25 35]);
set(gca,'YTick',[25 : 2 : 35]);

xlim(axes1,[0 0.7]);
set(gca,'XTick',[0 : 0.100 : 0.7]);
box(axes1,'on');
xlabel('V_{gate} (V)','FontSize',18);
grid(axes1,'on');

legend('All DAC values', 'Selected for 4-PAM', 'Location','northwest')
%rect = [0.4, 0.75, .15, .15];
set(0, 'DefaultAxesFontName', 'Arial'); 
print(figure1,'-depsc', '-tiff', '-r300', 'volts_vs_power.eps'); 





%%

