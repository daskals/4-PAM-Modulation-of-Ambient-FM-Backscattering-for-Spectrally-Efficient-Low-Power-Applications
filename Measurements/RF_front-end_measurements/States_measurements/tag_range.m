%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;



s=load('SNR_NOISE.mat') ;
NOISE=s(1).working_snr;

%%
s=load('SNR_DAC0_min70dbm.mat') ;
DAC0_min70=s(1).working_snr;
s=load('SNR_DAC0_min60dbm_v2.mat') ;
DAC0_min60=s(1).working_snr;
s=load('SNR_DAC0_min50dbm_v2.mat') ;
DAC0_min50=s(1).working_snr;
s=load('SNR_DAC0_min40dbm_v2.mat') ;
DAC0_min40=s(1).working_snr;
s=load('SNR_DAC0_min30dbm.mat') ;
DAC0_min30=s(1).working_snr;
s=load('SNR_DAC0_min20dbm_v2.mat') ;
DAC0_min20=s(1).working_snr;
s=load('SNR_DAC0_min10dbm_v2.mat') ;
DAC0_min10=s(1).working_snr;
s=load('SNR_DAC0_0dbm_v2.mat') ;
DAC0_0=s(1).working_snr;

DAC0=[DAC0_0 DAC0_min10 DAC0_min20 DAC0_min30 DAC0_min40 DAC0_min50 DAC0_min60 DAC0_min70]


s=load('SNR_DAC6_min70dbm_v2.mat') ;
DAC6_min70=s(1).working_snr;
s=load('SNR_DAC6_min60dbm_v2.mat') ;
DAC6_min60=s(1).working_snr;
s=load('SNR_DAC6_min50dbm_v2.mat') ;
DAC6_min50=s(1).working_snr;
s=load('SNR_DAC6_min40dbm_v2.mat') ;
DAC6_min40=s(1).working_snr;
s=load('SNR_DAC6_min30dbm_v2.mat') ;
DAC6_min30=s(1).working_snr;
s=load('SNR_DAC6_min20dbm_v2.mat') ;
DAC6_min20=s(1).working_snr;
s=load('SNR_DAC6_min10dbm_v2.mat') ;
DAC6_min10=s(1).working_snr;
s=load('SNR_DAC6_0dbm_v2.mat') ;
DAC6_0=s(1).working_snr;

DAC6=[DAC6_0 DAC6_min10 DAC6_min20 DAC6_min30 DAC6_min40 DAC6_min50 DAC6_min60 DAC6_min70]