%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 11/7/2017                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;

%% RTL SDR parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GAIN=-15; 
F_ADC = 1e6;  %1 MS/s 
DEC = 1;
Fs = F_ADC/DEC;
Ts = 1/Fs;

%% Sympol parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tsymbol =5.85e-3 ;         % put the Duration (T) or the smallest Sympol of the bitstream 
Tbit=Tsymbol/2;             % Datarate= 1/Tbit => For 500 us: 1 kbps                           % put 0.990e-3 => for 500 bps
over = round(Tsymbol/Ts);   % Oversampling factor 
newover = 585;               % Downsample factor

%%  Tag Packet parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bitstreams length
preamble_length=10;                % NoFM0_prample=[1 0 1 0 1 0 1 1 1 1];
id_length=2;                       % NoFM0_ID=[0 1];
util_length=2;                     % NoFM0_util=[0 1];
codeword_length=14;                % NoFM0_DATA=[0 0 1 1 1 1 0 0 0 1 0 1];
dummybit=0;         %put a dummy bit at the end of packet bitstream for better reception
%%%
total_packet_length=(id_length+preamble_length+util_length+codeword_length+dummybit)/2;
total_packet_duration=(total_packet_length)*Tsymbol;
preamble_duration=preamble_length*Tbit;

%% Sigmal Prosesing  Variables
Resolution = 1;   % in Hz
N_F = Fs/Resolution;
F_axis = -Fs/2:Fs/N_F:Fs/2-Fs/N_F;

% Preamble in FM0 format with symbols (not bits).
%(-3 || 00)----(-1 || 01)------(1 || 11)-----(3 || 10)
preamble=[+3,-3,+3,-3, +3];
preamble_neg=-1*preamble;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Decoder  FM0 vectors
bits_FM0_2sd_wayB=[]; 
decision_bits_B=[];
final_packet=[];
returnthress=0;

fixedpacketdata=[0 1 1 1 0 0  0 1  0 1  1 1  1 0  0 0  1 1];  % id + sensor_id + fixedata  
fixedpacketdata_len=length(fixedpacketdata);

%% Capture Window Parameters
framelength=3;                                      %Window=3*packet_length
t_sampling = framelength*total_packet_duration;     % Sampling time frame (seconds).
N_samples = round(Fs*t_sampling);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import Datasets


dataset1=load('NOISE_100_pakets_1MSps_dataset.mat');
matrix=dataset1.dataset;
% put All the data in a line =>same as Linux fifo
matrixinv=matrix';
stream=matrixinv(1:end)'; %to be compatible with windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug Print variables => activate and deactive the plots
DEBUG_en1=0;
DEBUG_en2=1;
DEBUG_en3=0;
DEBUG_en5=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Decoder General variables
correct_packets=0;
error_packets=0;
cut_packets=0;   
negative_starts1=0;
negative_starts2=0;
droped_packets=0;
pos=1;
FLIPPED=0;
packets = 1;
counter=0;
nopacket_ind=0;
nodroped_packets=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Decoder  FM0 vectors
bits_FM0_2sd_wayB=[]; 
decision_bits_B=zeros(1,length(fixedpacketdata));

BER_sum=[];
infomatr=[];
errorind=[];

%dataset= NaN*ones(0,HIST_SIZE);
dataset= [];
D1_ups=ones(1,newover);

counter = 0;
packets = 0;
HIST_SIZE = 500;
tempSNR_mean=0;
tempSNR_var=0;
N=99
while packets<N%10
      
      %% Load Window (3*packet_length) to the buffer 
      % don't need to do  deinterleaving here
      x=stream(pos:pos+N_samples-1);

       counter = counter + 1;
      % delay every two windows || ===> capture__delay(duration=packet_window)__capture__delay__......
    if ~mod(counter, 2)     
          
          packets = packets + 1
          
        x_corr_fft = fftshift(fft(x, N_F));
        
         if 1
            figure(1);
            semilogy(F_axis, (abs(x_corr_fft).^2));
            grid on;
            axis tight;
            drawnow;
         end
        
         
		p_signal_mean = mean(abs(x_corr_fft).^2);
        maensvector(packets)= p_signal_mean;
      
        p_signal_var = var(abs(x_corr_fft).^2);
        varsvector(packets)=p_signal_var;
        
		tempSNR_mean = tempSNR_mean + p_signal_mean;
        tempSNR_var = tempSNR_var + p_signal_var;
        lenghpack=length(abs(x_corr_fft).^2);
   
       end 
         pos=pos+N_samples;
         
         
end    

            working_snr_mean = tempSNR_mean/packets
            working_snr_var=((lenghpack-1)/(lenghpack*packets-1))*tempSNR_var+((lenghpack*(packets-1))/(lenghpack-1))*var(maensvector)   