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
newover = over;               % Downsample factor

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


dataset1=load('FM_amb_95_8_Mhz_100_packets_1Msps_v1.mat');
matrix=dataset1.dataset;
% put All the data in a line =>same as Linux fifo
matrixinv=matrix';
stream=matrixinv(1:end)'; %to be compatible with windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug Print variables => activate and deactive the plots
DEBUG_en1=0;
DEBUG_en2=0;
DEBUG_en3=1;
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


N=2
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
            %% Downsample same prosedure
            total_env_ds = dataconv(1:over/newover:end); %% by factor of 10 to reduce the computational complexity
            
             %% Time sync of downsample
            total_envelopea = total_env_ds(newover+1:end-newover+1); % total_env_ds(newover+1:end-newover+1); 
             %% remove the DC offset
             total_envelope=total_envelopea-mean(total_envelopea);
             %%na allazo to total_envelope apo  total_env_ds

         if DEBUG_en1==1
                time_axis= 0:Ts:Ts*length(abstream)-Ts;        %same as xaxis_m= (1: length(abstream))*Ts Captured signal time axis.
                     % fft
                     x_fft = fftshift(fft(x, N_F));
                     F_sensor_est_power=10*log10((abs(x_fft).^2)*Ts/50*1e3)-15; 
                 figure(1);
                  %subplot(2, 1, 1);
%                     plot(time_axis,abstream);
%                     title('Absolute-squared', 'FontSize',14 )  
%                     xlabel('Time (Sec)', 'FontSize',12, 'FontWeight','bold');
%                     ylabel('Amplitude', 'FontSize',12, 'FontWeight','bold');
%                     grid on;
                   %subplot(2, 1, 2);
                    plot(F_axis/1000000, F_sensor_est_power);
                    title('Frequency Domain')  
                    xlabel('Frequency (MHz)');
                   drawnow;               
         end
           
           
        
            if DEBUG_en2==1;
                 figure(2);
                    subplot(2, 1, 1);
                    %time_comv=0:1350*Ts:Ts*length(dataconv);
                    plot(dataconv)
                    title('Matched-filtered' ,'FontSize',14 )
                    xlabel('Time (Sec)', 'FontSize',12, 'FontWeight','bold');
                    ylabel('Amplitude', 'FontSize',12, 'FontWeight','bold');
                    grid on;
                    subplot(2, 1, 2);

                    plot(total_envelope);
                    title('DOWNSAMPLED DC Removal')
                    drawnow;                 
            end 
            
            
            if DEBUG_en5==1;
                 figure5= figure;
                 time_axis= 0:Ts:Ts*length(abstream)-Ts; 
                 time_comv=0:Ts:Ts*length(dataconv)-Ts;
                 axes3  = axes('Parent',figure5,'YGrid','on','XGrid','on','FontSize',14);
                    
                    subplot(2, 1, 1);
                    plot(time_axis,abstream, 'LineWidth',1,'Color',[0 0 0]);
                  
                    xlabel('Time (s)', 'FontSize',14);
                    ylabel('Squared Magnitude', 'FontSize',14);
                      grid on;
                    xlim([0.012 0.18]);
                    drawnow;
                    
                    
                    subplot(2, 1, 2);
                    plot(time_comv,dataconv, 'LineWidth',1,'Color',[0 0 0]); 
                    %title('Matched filtering' ,'FontSize',14 )
                    xlabel('Time (s)', 'FontSize',14);
                    ylabel('Squared Magnitude', 'FontSize',14);
                    xlim([0.012 0.18]);
                    grid on;                  
                    drawnow;        
                 set(0, 'DefaultAxesFontName', 'Arial');                  
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
               %total_envelopea=-total_envelopea;
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
          
            %shifted_sync_signal_B=shifted_sync_signal_B-mean(shifted_sync_signal_B);     
%             indemidlr=1;
%             for  xi=1:newover:length(shifted_sync_signal_B)
%                 mean_symbol_points(indemidlr)=mean(shifted_sync_signal_B(xi:xi+newover-1));
%                 sample2=shifted_sync_signal_B(xi: xi+newover-1);
%                 sumD1_ups(indemidlr)=sum(D1_ups.*sample2');
%                 %newatternt(indemidlr)=sum(shifted_sync_signal_B(xi:xi+newover-1))
%                 %[a  b]=max(xcorr(sample2, D1_ups));
%                 %xcorrres(indemidlr)=a
%                 indemidlr=indemidlr+1; 
%             end 
            
         
            as=ceil(newover/10);
            simashifted=total_envelope(start:start+total_packet_length*newover);
            
 
%             figure(5);
%             plot(simashifted);
%             
            Sm3=simashifted(3*newover-as:3*newover+as);
            V0= var(Sm3);
            M0=mean(Sm3);
            
            Sp3=simashifted(4*newover-as:4*newover+as);
            V3= var(Sp3);
            M3=mean(Sp3);
            
            
            Sm1=simashifted(5*newover-as:5*newover+as);
            V1= var(Sm1);
            M1=mean(Sm1);
            
            Sp1=simashifted(6*newover-as:6*newover+as);
            V2= var(Sp1);
            M2=mean(Sp1);
            
       
           PosTress01=((V1*M0-V0*M1)/(V1-V0))+(sqrt(V1*V0*((M1-M0)^2+(V1-V0)*log(V1/V0)))/(V1-V0));
           NegTress01=((V1*M0-V0*M1)/(V1-V0))-(sqrt(V1*V0*((M1-M0)^2+(V1-V0)*log(V1/V0)))/(V1-V0));
           SimpleTress01=((sqrt(V1)*M0+sqrt(V0)*M1)/(sqrt(V1)+sqrt(V0)))+(sqrt(V1)*(V1-V0)/(2*sqrt(V0)*(M1-M0)));
           SimpleTress01=((sqrt(V1)*M0+sqrt(V0)*M1)/(sqrt(V1)+sqrt(V0)));
           if (M0<=PosTress01 && PosTress01<=M1)
               Tress01=PosTress01;
           else
               Tress01=NegTress01;
           end 
           
           PosTress12=((V2*M1-V1*M2)/(V2-V1))+(sqrt(V2*V1*((M2-M1)^2+(V2-V1)*log(V2/V1)))/(V2-V1));
           NegTress12=((V2*M1-V1*M2)/(V2-V1))-(sqrt(V2*V1*((M2-M1)^2+(V2-V1)*log(V2/V1)))/(V2-V1));
           SimpleTress12=((sqrt(V1)*M2+sqrt(V2)*M1)/(sqrt(V1)+sqrt(V2)))+(sqrt(V2)*(V2-V1)/(2*sqrt(V1)*(M2-M1)));
            SimpleTress12=((sqrt(V1)*M2+sqrt(V2)*M1)/(sqrt(V1)+sqrt(V2)));
           if (M1<=PosTress12 && PosTress12<=M2)
               Tress12=PosTress12;
           else
               Tress12=NegTress12;
           end 
           
           PosTress23=((V3*M2-V2*M3)/(V3-V2))+(sqrt(V3*V2*((M3-M2)^2+(V3-V2)*log(V3/V2)))/(V3-V2));
           NegTress23=((V3*M2-V2*M3)/(V3-V2))-(sqrt(V3*V2*((M3-M2)^2+(V3-V2)*log(V3/V2)))/(V3-V2));
           SimpleTress23=((sqrt(V2)*M3+sqrt(V3)*M2)/(sqrt(V3)+sqrt(V2)))+(sqrt(V3)*(V3-V2)/(2*sqrt(V2)*(M3-M2)));
           SimpleTress23=((sqrt(V2)*M3+sqrt(V3)*M2)/(sqrt(V3)+sqrt(V2)));
           if (M2<=PosTress23  &&  PosTress23<=M3)
               Tress23=PosTress23;
           else
               Tress23=NegTress23;
           end 
           
           Tress01;
           Tress12;
           Tress23;
            
           

               
            % quantize the input signal x to the alphabet
            % using nearest neighbor method
     
                start_symbol_pointsa=shifted_sync_signal_B(1:newover:end);
            x=start_symbol_pointsa;%-mean(start_symbol_pointsa);  
            averagepower =mean(x.^2);

            limit_0=mean(start_symbol_pointsa);
            limit_minus=limit_0-(2*sqrt((averagepower-limit_0^2)/5));
            limit_plus=limit_0+(2*sqrt((averagepower-limit_0^2)/5));
            
              
             if  (packets==2)
                    figure(4);
                    y1=1:newover:length(shifted_sync_signal_B);
                    plot(y1,start_symbol_pointsa, '*');
                    hold on 
                    %plot(y1,mean_per_symbol, 'o');
                    plot(shifted_sync_signal_B);
                    plot(limit_minus*ones(1,length(shifted_sync_signal_B)));
                    plot(limit_0*ones(1,length(shifted_sync_signal_B)));
                    plot(limit_plus*ones(1,length(shifted_sync_signal_B)));
                    title('Start Points' ,'FontSize',14)
                    legend('Start Symbol Point','Packet_Signal', 'Thres01', 'Thres12', 'Thres23')
                    grid on;
                    drawnow;
                    
                    %figure(6);
                    figure6= figure;
                    y1=0:Ts:length(shifted_sync_signal_B)*Ts-Ts;
                    y2=0:Tsymbol:8*Tsymbol;
                    axes6  = axes('Parent',figure6,'YGrid','on','XGrid','on','FontSize',18);
                    plot(y2*1000,start_symbol_pointsa, 'o','LineWidth',1.2,'Color',[0 0 0]);
                    hold on 
                    plot(y1*1000, shifted_sync_signal_B, 'LineWidth',1.2,'Color',[0 0 0]);                    
                    plot(y1*1000,limit_minus*ones(1,length(shifted_sync_signal_B)),'--', 'LineWidth',1.2);
                    plot(y1*1000,limit_0*ones(1,length(shifted_sync_signal_B)),'-.', 'LineWidth',1.2);
                    plot(y1*1000,limit_plus*ones(1,length(shifted_sync_signal_B)), '-', 'LineWidth',1.2);
                    set(axes6,'FontSize',18)
                    ylim(axes6,[0.022 0.027]);
                    xlim(axes6,[0 50]);
                    set(gca,'XTick',[0 : 10 : 50]);
                    box(axes6,'on');
                    xlabel('Time (ms)','FontSize',18);
                    ylabel('Squared Magnitude','FontSize',18);
                    set(0, 'DefaultAxesFontName', 'Arial');  
                    legend('Sampling Points','Signal', 'Threshold 23', 'Threshold 12', 'Threshold 01', 'Location','southwest')
                    grid on;
                    drawnow;
                    

             end
            
            
            
            % alphabet: -3; -1; 1; 3
            ipHat(find(x<  limit_minus)) = -3;
            ipHat(find(x>= limit_plus)) = 3;
            ipHat(find(x>=limit_minus & x<limit_0)) = -1;
            ipHat(find(x>=limit_0 & x<limit_plus)) = 1;
            y_bits=ipHat
            
            
%             % alphabet: -3; -1; 1; 3
%             ipHat(find(x<  limit_minus)) = -3;
%             ipHat(find(x>= limit_plus)) = 3;
%             ipHat(find(x>=limit_minus & x<0)) = -1;
%             ipHat(find(x>=0 & x<limit_plus)) = 1;
%             y_bits=ipHat
           
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
                       return;
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

            