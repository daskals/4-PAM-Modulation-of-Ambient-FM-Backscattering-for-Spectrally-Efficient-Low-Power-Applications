close all;
clear all;
clc;


dist=[80   60   40 30 20  ];

BER1=[ 
   0.020084093755591
   0.069695382735446
   0.151426882809862
   0.535936054961025
   0.562184343434343
];



figure5= figure;
axes5 = axes('Parent',figure5,'YGrid','on','XGrid','on','FontSize',18);
semilogy(fliplr(dist),(BER1),'Marker','o','LineWidth',1.5,'Color',[0 0 0]);
%hold on
%semilogy(dist500_v3,BER500u_v2,'Marker','*','LineWidth',1.5,'Color',[0 0 0]);
grid on;
%hold on
%semilogy(dist1_v3, BER1_v2,'Marker','+','LineWidth',1.5,'Color',[0 0 0]);
set(axes5,'FontSize',18)
%xlim(axes3,[-45 -10]);
%box(axes3,'on');
ylabel('Bit Error Rate (BER)','FontSize',18);
xlabel('Tag-to-Reader Distance (cm)','FontSize',18);

grid(axes5,'on');
%legend('500 bps','1000 bps','2000 bps','Location','NorthEast');
set(0, 'DefaultAxesFontName', 'Arial'); 
print(figure5,'-depsc', '-tiff', '-r300', 'BER.eps');