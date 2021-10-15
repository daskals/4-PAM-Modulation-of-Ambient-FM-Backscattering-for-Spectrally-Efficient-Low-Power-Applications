%
L = 10;
load power_pam.txt
load ber_pam.txt
power_tx = power_pam(:,1); % dBm
Py0 = power_pam(:,2); % 
Py1 = power_pam(:,3); % 
Py2 = power_pam(:,4); % 
Py3 = power_pam(:,5); % 
Pn = power_pam(1,6);
Power_meas = ber_pam(:,1); % dBm
BER_meas = ber_pam(:,2);
%
PER = zeros(length(power_tx),1);
%
for i = 1:length(power_tx)
    P0 = Py0(i);
    P1 = Py1(i);
    P2 = Py2(i);
    P3 = Py3(i);
    p = Per_ambPAM(Py0,Py1,Py2,Py3,Pn,L);
    PER(i,1) = p;
end

%semilogy(SNRdBrange,PER)
%grid on
%xlabel('SNR (dB)');ylabel('BER (%)')
%
figure(2)
semilogy(power_tx,PER,Power_meas,BER_meas,'r')
grid on
xlabel('TX power (dBm)');ylabel('BER (%)')
legend('Theory','Meas.')
