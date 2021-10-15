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


dataset1=load('4PAM_FM_CW_min20_100_pakets_1MSps_dataset.mat');
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


N=101
while packets<N%10
      
      %% Load Window (3*packet_length) to the buffer 
      % don't need to do  deinterleaving here
      x=stream(pos:pos+N_samples-1);

       counter = counter + 1;
      % delay every two windows || ===> capture__delay(duration=packet_window)__capture__delay__......
    if ~mod(counter, 2)     
          
          packets = packets + 1;
           fprintf('Packet=%d|\n',packets)

              %% Absolute operation removes the unknown CFO
           abstream=abs(x).^2;

           %% Matched filtering
            matcheds=ones(round(Tsymbol/Ts),1); % the pulse of matched filter has duration Tsymbol
            dataconv=conv(abstream,matcheds);   %  aply the filter with convolution
            dataconv=dataconv(1:length(abstream))/length(matcheds);
            %dataconv=dataconv(length(matcheds):end);
 
            %% Downsample same prosedure
            total_env_ds = dataconv(1:over/newover:end); %% by factor of 10 to reduce the computational complexity
            
            abstream = abstream(1:over/newover:end);
             %% Time sync of downsample
            total_envelopea = total_env_ds(newover+1:end-newover+1); % total_env_ds(newover+1:end-newover+1); 
            
            %% remove the DC offset
             total_envelope=total_envelopea-mean(total_envelopea);

             
             for k=1:1: length(total_envelope)- (total_packet_length*newover)+1
                 energy_synq(k)=sum(abs(total_envelope(k : k+total_packet_length*newover-1-newover)).^2);          
             end
           [energy_sinq_max  energy_sinq_ind]=max(energy_synq); 
           pointer1=energy_sinq_ind-total_packet_length*newover               

           if pointer1<=0   
               negative_starts2=negative_starts2+1;
               disp 'Negative start_2';
            continue;
           end
             
             
             %%na allazo to total_envelope apo  total_env_ds
            if DEBUG_en2==1;
                 figure(2);
                 
                    time_axis= 0:Ts:Ts*length(abstream)-Ts; 
                    subplot(2, 1, 1);
                    plot(time_axis,abstream);
                    title('|x|^2', 'FontSize',14)
                    xlabel('Time(Sec)');
                    ylabel('Amplitude');
                    grid on; 
                    subplot(2, 1, 2);
                    time_comv=0:Ts:Ts*length(dataconv)-Ts;
                    plot(time_comv,dataconv)
                    title('LowPass', 'FontSize',14)
                    xlabel('Time (Sec)');
                    ylabel('Amplitude');
                    grid on;              
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
               total_envelopea=-total_envelopea;
               abstream=-abstream;
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
                        
            abssimesshifted=abstream((start:start+total_packet_length*newover));

            
            Sm3=abssimesshifted(3*newover+1:4*newover);
            V0= var(Sm3);
            M0=mean(Sm3);
            
            Sp3=abssimesshifted(2*newover+1:3*newover);
            V3= var(Sp3);
            M3=mean(Sp3);
            
            Sm1=abssimesshifted(5*newover+1:6*newover);
            V1= var(Sm1);
            M1=mean(Sm1);
            
            Sp1=abssimesshifted(6*newover+1:7*newover);
            V2= var(Sp1);
            M2=mean(Sp1);
            
         SimpleTress01a2=((sqrt(V1)*M0+sqrt(V0)*M1)/(sqrt(V1)+sqrt(V0)));
         SimpleTress12a2=((sqrt(V1)*M2+sqrt(V2)*M1)/(sqrt(V1)+sqrt(V2)));
         SimpleTress23a2=((sqrt(V2)*M3+sqrt(V3)*M2)/(sqrt(V3)+sqrt(V2)));
         
           shifted_sync_signal_B=total_envelopea(start+length(preample_neover)+1: start+total_packet_length*newover);
           x=shifted_sync_signal_B(1:newover:end);

            % quantize the input signal x to the alphabet
            % using nearest neighbor method

            % alphabet: -3; -1; 1; 3
            ipHat(find(x< SimpleTress01a2)) = -3;
            ipHat(find(x>= SimpleTress23a2)) = 3;
            ipHat(find(x>=SimpleTress01a2 & x<SimpleTress12a2)) = -1;
            ipHat(find(x>=SimpleTress12a2 & x<SimpleTress23a2)) = 1;
            y_bits=ipHat
         
            
             if DEBUG_en3==1;
                    figure(6);
                    clf('reset')
                    y1=1:newover:length(shifted_sync_signal_B);
                    plot(y1,x, '*');
                    hold on 
                    plot(shifted_sync_signal_B);                    
    
                    plot(SimpleTress01a2*ones(1,length(shifted_sync_signal_B)),'-');
                    plot(SimpleTress12a2*ones(1,length(shifted_sync_signal_B)),'-');
                    plot(SimpleTress23a2*ones(1,length(shifted_sync_signal_B)), '-');
                    title('Means and Vars from Abs(x)^2' ,'FontSize',14)
                    legend('Start Symbol Point','Packet-Signal', 'Thres01', 'Thres12', 'Thres23')
                    grid on;
                    drawnow;

                    
            end   
           
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
%                        if (error_packets==2)
                       % return;
%                        end 
                else
                        disp 'Packet WRONGGGG------------------------';  
                        error_packets=error_packets+1;
                        BER_sum(error_packets) = sum(xor(decision_bits_B,fixedpacketdata));
                        %if (error_packets==3)
                        %return;
                        %end
                end  
          

            
       end 
         pos=pos+N_samples;
          decision_bits_B=zeros(1,length(fixedpacketdata));
         
end    

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

            