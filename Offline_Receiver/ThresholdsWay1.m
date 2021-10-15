%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 16/7/2018                         %
%     Site: www.Daskalakispiros.com                   %
%     Email: Daskalakispiros@gmail.com                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Threshold01,Threshold12, Threshold23] = ThresholdsWay1(V,M)

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

           %-------------------------------Threshold 01--------------------
           PosThres01=((V1*M0-V0*M1)/(V1-V0))+(sqrt(V1*V0*((M1-M0)^2+(V1-V0)*log(V1/V0)))/(V1-V0));
           NegThres01=((V1*M0-V0*M1)/(V1-V0))-(sqrt(V1*V0*((M1-M0)^2+(V1-V0)*log(V1/V0)))/(V1-V0));
        
           if (M0<=PosThres01 && PosThres01<=M1)
               Threshold01=PosThres01;
           else
               Threshold01=NegThres01;
           end 
           %-------------------------------Threshold 12--------------------
           PosThres12=((V2*M1-V1*M2)/(V2-V1))+(sqrt(V2*V1*((M2-M1)^2+(V2-V1)*log(V2/V1)))/(V2-V1));
           NegThres12=((V2*M1-V1*M2)/(V2-V1))-(sqrt(V2*V1*((M2-M1)^2+(V2-V1)*log(V2/V1)))/(V2-V1));
          
           if (M1<=PosThres12 && PosThres12<=M2)
               Threshold12=PosThres12;
           else
               Threshold12=NegThres12;
           end 
           %-------------------------------Threshold 23--------------------
           PosThres23=((V3*M2-V2*M3)/(V3-V2))+(sqrt(V3*V2*((M3-M2)^2+(V3-V2)*log(V3/V2)))/(V3-V2));
           NegThres23=((V3*M2-V2*M3)/(V3-V2))-(sqrt(V3*V2*((M3-M2)^2+(V3-V2)*log(V3/V2)))/(V3-V2));
         
           if (M2<=PosThres23  &&  PosThres23<=M3)
               Threshold23=PosThres23;
           else
               Threshold23=NegThres23;
           end 
end

