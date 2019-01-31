clear all
close all
clc

fs = 250e6;
Nsamples=1024;
Px = 1; %input power. Set to 1 because we don't know the input power.

%format from .txt in two structs
fID = fopen('H_meas_example.txt');
C = textscan(fID, '%f%f');
fclose(fID);
Label = {'Freq','Mod'};
HMeas = cell2struct(C,Label,2);
fID = fopen('Hrx_example.txt');
C = textscan(fID, '%f%f%f');
fclose(fID);
Label = {'Freq','Mod','Phase'};
Hrx = cell2struct(C,Label,2);
clear ans fID C Label;
% we add ModLin
[Hrx(:).ModLin] = 10.^(Hrx.Mod./20);
fieldnames(Hrx);

% here we get impulse responses
H_positive_frequency_only = Hrx.ModLin';
Hrx_data = zeros(1,2048);
Hrx_data(1:1024) = H_positive_frequency_only;
Hrx_data(1025:2048) = fliplr(H_positive_frequency_only(1:end));
Hrx_final_data = ifft(Hrx_data); % No need to use ifftshift like above

%FUNCTION LMS
rls1 = dsp.RLSFilter('Length', 128);
x = zeros(1,2048);
x(1) = 1.1;
x(2) = 0.2;
x(3) = 0.1;
x(4) = 0.12;
x(5) = 0.1;
x = x.';
%x = real(HInter_final_data'); % input signal
d = real(Hrx_final_data'); % desired signal
% d = real(Heq_final_data'); % desired signal
%[y,e,w] = lms1(ifft(X), complex(ifft(D))); % y uscita, e errore, w coefficienti del filtro
[y,e] = rls1(x, d); % y uscita, e errore, w coefficienti del filtro
                     % SERVONO X E D NEL TEMPO

w = rls1.Coefficients;
                     
Hd = dfilt.dffir(w); % discrete time finite impulse response direct form FIR
freqz(Hd) % risposta in frequenza del filtro

% plot
figure
subplot(2,1,1); 
plot(1:2048, [d,y,e]);
title('System Identification of an FIR filter');
legend('Desired', 'Output', 'Error');
xlabel('time index'); 
ylabel('signal value');
subplot(2,1,2); 
stem(w);
legend('Estimated'); 
xlabel('coefficient #'); 
ylabel('coefficient value');

figure
Hd_fft = (real(fft(Hd.Numerator)))';
Hd_fft_dB = 20*log10(Hd_fft);
plot(Hd_fft_dB(1:64));
title('Risposta in frequenza del filtro [dB]');

figure
uscita=filter(w,1,x);
freqz(uscita);
title('uscita frequenza, DB');

figure
uscita = real(fft(uscita));
plot(Hrx.Freq, uscita(1:1024));
title('uscita frequenza, LINEARE');