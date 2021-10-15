%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 16/7/2018                         %
%     Site: www.Daskalakispiros.com                   %
%     Email: Daskalakispiros@gmail.com                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Threshold01,Threshold12, Threshold23] = ThresholdsWay2(V,M)

%Variance values
V0=V(1);
V1=V(2);
V2=V(3);
V3=V(4);
%Mean values
M0=M(1);
M1=M(2);
M2=M(3);
M3=M(4);

%        Threshold01=((sqrt(V1)*M0+sqrt(V0)*M1)/(sqrt(V1)+sqrt(V0)))+(sqrt(V1)*(V1-V0)/(2*sqrt(V0)*(M1-M0)));
%        Threshold12=((sqrt(V1)*M2+sqrt(V2)*M1)/(sqrt(V1)+sqrt(V2)))+(sqrt(V2)*(V2-V1)/(2*sqrt(V1)*(M2-M1)));
%        Threshold23=((sqrt(V2)*M3+sqrt(V3)*M2)/(sqrt(V3)+sqrt(V2)))+(sqrt(V3)*(V3-V2)/(2*sqrt(V2)*(M3-M2)));    
             
         Threshold01=((sqrt(V1)*M0+sqrt(V0)*M1)/(sqrt(V1)+sqrt(V0)));
         Threshold12=((sqrt(V1)*M2+sqrt(V2)*M1)/(sqrt(V1)+sqrt(V2)));
         Threshold23=((sqrt(V2)*M3+sqrt(V3)*M2)/(sqrt(V3)+sqrt(V2)));
end

