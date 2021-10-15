%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;

G2=-0.3414-j*0.2881;
G3=0.0223+j*0.1779;
Gr=1;
Gt=1;
freq_mhz=95.8;

D_FM_tag=34.65*1000; % 34 KM
D_tag_SDR=0.8; % around 1 m

ERP=250*1000 ;      %250 KW
EIRP = 1.64*ERP;

 SPL=299792458;					% Speed of light
 freq_khz = freq_mhz*1000;		% Convert the frequency in MHz to kHz
 freq_hz = freq_khz*1000;		% Convert the frequency in kHz to Hz
  lambda = SPL/freq_hz;

RCS= ((lambda^2)/(4*pi))*(Gt^2)*abs(G3'-G2')^2 

Ptag= (EIRP*RCS)/(4*pi*D_FM_tag^2)
PSDR= (Ptag*Gr*lambda^2)/((4*pi)^2*D_tag_SDR^2)
result=10*log(PSDR*1000)/log(10) %dBm 

