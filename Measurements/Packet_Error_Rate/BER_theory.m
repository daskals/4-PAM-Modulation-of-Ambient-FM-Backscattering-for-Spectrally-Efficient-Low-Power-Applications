
close all;
clear all;
clc;





%%
power=[ -20  -25  -30 -35 -40 -45];

power_theory=[-15 -20  -25  -30 -35 -40];

power_theory_stat_weight=[-20 -25  -30 -35 -40];
BER_theory_stat_weight=[
   1.5385e-08
   3.6254e-04   
   0.0157
   0.0481   
   0.1339
   0.1927
];


power_theory_newb=[ -20  -25 -30 -35 -40];
 BER_theory_newb=[
         4.2284e-04
             0.0169
             0.0516
             0.1439
             0.2055
     ]


 
 
BER=[
    8.163265306122449e-04
    0.020272743913601   
    0.056773088023088
    0.142393162393162
    0.245535714285714
    0.410493827160494
    ];


figure3= figure;
axes3 = axes('Parent',figure3,'YGrid','on','XGrid','on','FontSize',18);
semilogy(power,BER,'o', 'LineWidth',1.5,'Color',[0 0 0]);
hold on
%semilogy(power_theory,BER_theory_newb,'LineWidth',1.5,'Marker','o','Color',[0 0 0]);
semilogy(power_theory,BER_theory_stat_weight,'LineWidth',1.5,'Marker','x','Color',[0 0 0]);
set(axes3,'FontSize',18)
xlim(axes3,[-45 -15]);
%box(axes3,'on');
ylabel('Bit Error Rate (BER)','FontSize',18);
xlabel('Transmit Power (dBm)','FontSize',18);
grid(axes3,'on');
legend('Measurements','Theory','Theory non Equal Prob','Location','southwest');
set(0, 'DefaultAxesFontName', 'Arial'); 
print(figure3,'-depsc', '-tiff', '-r300', 'BER_chamber_fig.eps');


