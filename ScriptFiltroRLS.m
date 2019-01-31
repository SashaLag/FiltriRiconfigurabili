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

%if Hrx frequency range is bigger than HMeas
if Hrx.Freq(end) > HMeas.Freq(end)
    HMeas.Freq = cat(1,HMeas.Freq, Hrx.Freq(end)); %1 concats vertically
    HMeas.Mod = cat(1,HMeas.Mod, HMeas.Mod(end));
end

%Interpolation
HInter=struct('Freq',Hrx.Freq,'Mod',[],'ModLin',[]);
HInter.Mod = interp1(HMeas.Freq,HMeas.Mod,Hrx.Freq);
%ideal Heq
Heq=struct('Freq',HInter.Freq,'Mod',-HInter.Mod,'ModLin',10.^(-HInter.Mod./20));
%Input variables for LMS in linear
HInter.ModLin = 10.^(HInter.Mod./20);

% here we get impulse responses
H_positive_frequency_only = HInter.ModLin';
HInter_data = zeros(1,2048);
HInter_data(1:1024) = H_positive_frequency_only;
HInter_data(1025:2048) = fliplr(H_positive_frequency_only(1:end));
HInter_final_data = ifft(HInter_data); % No need to use ifftshift like above

H_positive_frequency_only = Hrx.ModLin';
Hrx_data = zeros(1,2048);
Hrx_data(1:1024) = H_positive_frequency_only;
Hrx_data(1025:2048) = fliplr(H_positive_frequency_only(1:end));
Hrx_final_data = ifft(Hrx_data); % No need to use ifftshift like above

H_positive_frequency_only = Heq.ModLin';
Heq_data = zeros(1,2048);
Heq_data(1:1024) = H_positive_frequency_only;
Heq_data(1025:2048) = fliplr(H_positive_frequency_only(1:end));
Heq_final_data = ifft(Heq_data); % No need to use ifftshift like above

%STEP SIZE
delta32 = 1/(10*32*Px);
delta64 = 1/(10*64*Px);
delta128 = 1/(10*128*Px);
%0.01 step size precedente ma forse fuori range
%valore massimo 7.8126*10^-4
%step size più vicino a 7.8126*10^-5

%FUNCTION LMS
% lms1 = dsp.LMSFilter(128,'StepSize', 0.1, 'Method', 'Normalized LMS');
x = real(HInter_final_data'); % input signal
d = real(Hrx_final_data'); % desired signal
% d = real(Heq_final_data'); % desired signal
% [y,e,w] = lms1(ifft(X), complex(ifft(D))); % y uscita, e errore, w
% coefficienti del filtroS
rlsFilt = dsp.RLSFilter(128);
y = rlsFilt(x,d);     
%Hd = dfilt.dffir(w); % discrete time finite impulse response direct fo
freqz(Hd) % risposta in frequenza del filtro
grpdelay(Hd,2048,fs)   % plot group delay

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
plot(HInter.Mod);
title('HInter.Mod');
figure
Hd_fft = (real(fft(Hd.Numerator)))';
Hd_fft_dB = 20*log10(Hd_fft);
plot(Hd_fft_dB(1:64) );
title('Hd_fft_dB(1:64)');
figure
uscita = filter(w,1,x);
plot(real(fft(uscita)));
title('real(fft(uscita))');
figure
freqz(uscita);