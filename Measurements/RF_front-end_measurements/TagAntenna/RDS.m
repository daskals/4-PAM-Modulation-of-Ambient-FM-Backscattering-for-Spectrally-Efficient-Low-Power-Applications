%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;

G2=-0.3414-j*0.2881;
G3=0.0223+j*0.1779;
G=2.15;
freq_mhz=95.8;

 SPL=299792458;					% Speed of light
 freq_khz = freq_mhz*1000;		% Convert the frequency in MHz to kHz
 freq_hz = freq_khz*1000;		% Convert the frequency in kHz to Hz
 WL = SPL/(freq_hz);				% Calculate the wavelength (lambda)
    
RDS= (WL^2)/(4*pi)*G^2 
