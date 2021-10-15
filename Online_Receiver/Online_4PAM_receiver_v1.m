%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Spiros Daskalakis                               %
%     last Revision 27/4/2018                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
close all; 
clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(6) %wait six sec 
%% RTL SDR parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GAIN=-15; 
F_ADC = 1e6;  %1 MS/s 
DEC = 1;
Fs = F_ADC/DEC;
Ts = 1/Fs;

%% Sympol parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tsymbol = 5.85e-3 ; 
%Tsymbol = 200e-6 ; 
Tbit=Tsymbol/2;             % Datarate= 1/Tbit => For 500 us: 1 kbps 
over = round(Tsymbol/Ts);   % Oversampling factor 
newover = over;               % Downsample factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


total_packet_duration=total_packet_length*Tsymbol;
preamble_duration=preamble_length*Tbit;

% Preamble in FM0 format with symbols (not bits).
preamble=[+3,-3,+3,-3, +3];
preamble_neg=-1*preamble;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% bitstreams with Data and packet data contained in the packet=>for validation perposes
fixedpacketdata=[0 1  1 1  0 0  0 1  0 1  1 1  1 0  0 0  1 1];  % id + sensor_id + fixedata  
ipHat = zeros(1,length(fixedpacketdata)/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sigmal Prosesing  Variables
% For FFT plots (not used)
Resolution = 1;   % in Hz
N_F = Fs/Resolution;
F_axis = -Fs/2:Fs/N_F:Fs/2-Fs/N_F;
%% Capture Window Parameters
framelength=3;                                      %Window=3*packet_length
t_sampling = framelength*total_packet_duration;     % Sampling time frame (seconds).
N_samples = round(Fs*t_sampling);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import Datasets
fi = fopen('PAMAmbient', 'rb');
t = 0:Ts:t_sampling-Ts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug Print variables => activate and deactive the plots
DEBUG_en1=0;
DEBUG_en2=1;
DEBUG_en3=1;
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

HIST_SIZE =100;
while (1)

            x = fread(fi, 2*N_samples, 'float32');  % get samples (*2 for I-Q)
            x = x(1:2:end) + j*x(2:2:end);          % deinterleaving
             
         counter = counter + 1;
        %dataset= [dataset ; x];
        
     % delay every two windows || ===> capture__delay(duration=packet_window)__capture__delay__......
    if ~mod(counter, 2)  
          packets = packets + 1;
           fprintf('Packet=%d|\n',packets)

           %% Absolute operation removes the unknown CFO
           abstream=abs(x).^2;

           %% Matched filtering
            matcheds=ones(round(Tsymbol/Ts),1); % the pulse of matched filter has duration Tsymbol
            dataconv=conv(abstream,matcheds);   %  aply the filter with convolution
            dataconv=dataconv/length(matcheds);
            
            %% Downsample same prosedure
            total_env_ds = dataconv(1:over/newover:end); %% by factor of 10 to reduce the computational complexity
            
             %% Time sync of downsample
            total_envelopea = total_env_ds(newover+1:end-newover+1); % total_env_ds(newover+1:end-newover+1); 
             %% remove the DC offset
             total_envelope=total_envelopea-mean(total_envelopea);
             %%na allazo to total_envelope apo  total_env_ds

            
         if DEBUG_en1==1;
                time_axis= 0:Ts:Ts*length(abstream)-Ts;        %same as xaxis_m= (1: length(abstream))*Ts Captured signal time axis.
                     % fft
                     x_fft = fftshift(fft(x, N_F));
                     F_sensor_est_power=10*log10((abs(x_fft).^2)*Ts/50*1e3)-15; 
                 figure(1);
                  %subplot(2, 1, 1);
                    plot(time_axis,abstream);
                    title('Absolute-squared', 'FontSize',14 )  
                    xlabel('Time (Sec)', 'FontSize',12, 'FontWeight','bold');
                    ylabel('Amplitude', 'FontSize',12, 'FontWeight','bold');
                    grid on;
%                    subplot(2, 1, 2);
%                     plot(F_axis/1000000, F_sensor_est_power);
%                     title('Frequency Domain')  
%                     xlabel('Frequency (MHz)');
                   drawnow;               
         end
           
           
%         if DEBUG_en2==1;
%                  figure(2);
%                     time_axis= 0:Ts:Ts*length(abstream)-Ts; 
%                     subplot(2, 1, 1);
%                     plot(time_axis,abstream);
%                     title('Initial Signal', 'FontSize',14)
%                     xlabel('Time (Sec)');
%                     ylabel('Amplitude');
%                     grid on; 
%                     subplot(2, 1, 2);
%                     time_comv=0:Ts:Ts*length(dataconv)-Ts;
%                     plot(time_comv,dataconv)
%                     title('Low Pass', 'FontSize',14)
%                     xlabel('Time (Sec)');
%                     ylabel('Amplitude');
%                     grid on;              
%         end 
           
            if DEBUG_en2==1;
                 figure(2);
                    subplot(2, 1, 1);
                    plot(dataconv);
                    title('Matched-filtered' ,'FontSize',14 )
                    xlabel('Time (Sec)', 'FontSize',12, 'FontWeight','bold');
                    ylabel('Amplitude', 'FontSize',12, 'FontWeight','bold');
                    grid on;
                    subplot(2, 1, 2);
                    plot(total_envelopea);
                    title('DOWNSAMPLED DC Removal')
                    xlabel('Time (Sec)', 'FontSize',12, 'FontWeight','bold');
                    ylabel('Amplitude', 'FontSize',12, 'FontWeight','bold');
                    drawnow;                 
            end 
            
           
             
            
            %% dc zero offser
             %% Assume symbol synchronization, which can be implemented using correlation with a sequence of known bits in the preamble       
             % comparison of the detected preamble bits with the a priori known bit sequence
             %convert the header to a time series for the specific sampling frequency and bit duration. 
            %% create the preamble neover format
            preample_neover=upsample(preamble, newover);
            preample_neg_neover=upsample(preamble_neg, newover);
            
            %% Sync via preamble correlation
            corrsync_out = xcorr(preample_neover, total_envelope);
            corrsync_out_neg = xcorr(preample_neg_neover, total_envelope);
            
            [m ind] = max(corrsync_out);
            [m_neg ind_neg] = max(corrsync_out_neg);
             %notice that correlation produces a 1x(2L-1) vector, so index must be shifted.
             %the following operation points to the "start" of the packet.
             
            if (m < m_neg)
               start = length(total_envelope)-ind_neg;
               total_envelope=-total_envelope;
               total_envelopea=-total_envelopea;
               start1=start
            else
               start = length(total_envelope)-ind;
               start2=start
            end
           
            if(start <= 0)
                negative_starts1 = negative_starts1 + 1;
                disp 'Negative start';
                continue;
            elseif start+((total_packet_length))*newover > length(total_envelope)  %% Check if the detected packet is cut in the middle.
                cut_packets = cut_packets + 1;
                disp 'Packet cut in the middle!';
                continue;
            end 
            
            shifted_sync_signal_B=total_envelopea(start+length(preample_neover)+1: start+total_packet_length*newover);
           
            start_symbol_pointsa=shifted_sync_signal_B(1:newover:end);
            x=start_symbol_pointsa;%-mean(start_symbol_pointsa);  
            averagepower =mean(x.^2);

            limit_0=mean(start_symbol_pointsa);
            limit_minus=limit_0-(2*sqrt((averagepower-limit_0^2)/5));
            limit_plus=limit_0+(2*sqrt((averagepower-limit_0^2)/5));

               if DEBUG_en3==1
                    figure(6);
                    clf('reset')
                    y1=1:newover:length(shifted_sync_signal_B);
                    plot(y1,x, '*');
                    hold on 
                    plot(shifted_sync_signal_B);                    
                    plot(limit_minus*ones(1,length(shifted_sync_signal_B)),'-');
                    plot(limit_0*ones(1,length(shifted_sync_signal_B)),'-');
                    plot(limit_plus*ones(1,length(shifted_sync_signal_B)), '-');
                    title('Start Points' ,'FontSize',14)
                    legend('Start Symbol Point','Packet-Signal', 'Thres01', 'Thres12', 'Thres23')
                    grid on;
                    drawnow;
               end 

            % alphabet: -3; -1; 1; 3
            ipHat(find(x<  limit_minus)) = -3;
            ipHat(find(x>= limit_plus)) = 3;
            ipHat(find(x>=limit_minus & x<limit_0)) = -1;
            ipHat(find(x>=limit_0 & x<limit_plus)) = 1;
            y_bits=ipHat
           
            bitsind=1;
            %(-3 || 00)----(-1 || 01)------(1 || 11)-----(3 || 10)
            for i=1:length(y_bits)
                if y_bits(i)==-3
                    decision_bits_B (bitsind)=0;
                    decision_bits_B (bitsind+1)=0;
                elseif y_bits(i)==-1
                    decision_bits_B (bitsind)=0;
                    decision_bits_B (bitsind+1)=1;
                elseif y_bits(i)==1
                    decision_bits_B (bitsind)=1;
                    decision_bits_B (bitsind+1)=1;
                elseif y_bits(i)==3
                    decision_bits_B (bitsind)=1;
                    decision_bits_B (bitsind+1)=0;
                end
                bitsind=bitsind+2;
            end 
            
             final_packet=decision_bits_B;
             
                if  isequal(final_packet, fixedpacketdata)
                      disp 'Packet Correct !!!!!!!!!!!!!!!!!!!!!!!!!';
                      correct_packets=correct_packets+1;      
                      %return;
                else
                        disp 'Packet WRONGGGG------------------------';  
                        error_packets=error_packets+1;
                        BER_sum(error_packets) = sum(xor(decision_bits_B,fixedpacketdata));   
                        %return;    
                end 
         end     

         decision_bits_B=[];
         

      if(mod(packets,HIST_SIZE) ==0)

           infomatr(1)=correct_packets;
           infomatr(2)=error_packets;
           infomatr(3)=negative_starts1+negative_starts2;
           infomatr(4)=cut_packets;
           infomatr(5)=error_packets /(correct_packets+error_packets);
           infomatr(6)= sum(BER_sum);
           infomatr(7)= sum(BER_sum)/((correct_packets+error_packets)*length(fixedpacketdata));
            
            fprintf('Corecct Packets=%d|Packet Error=%d\n',correct_packets, error_packets) 
            fprintf('Negative Starts=%d|Cut Packets=%d\n', negative_starts1, cut_packets)
            fprintf('Negative Starts2=%d\n', negative_starts2)
            %PER is the number of incorrectly received data packets divided by the total number of received packets.
            fprintf('Packet Error Rate=%d\n', error_packets / (correct_packets+error_packets)) 
            fprintf('Bit error rate (BER)=%d\n', sum(BER_sum)/((correct_packets+error_packets)*length(fixedpacketdata)))
                     
            %save('FM_amb_95_8_Mhz_100_packets_1Msps_v7','dataset')
            %save('4PAM_FM_amb_100_pakets_1mps_v5','infomatr')
             return;
      end
        
end




