 function [filt_egf] = bandpass_filter_egf(egf,sampleRate)

% implement butterworth filter
[b,a] = butter(3,[4 12]/(sampleRate/2)); %bandpass between 4 and 12 Hz
filt_egf = filtfilt(b,a,egf); %zerophase filter

%TO CHECK FREQUENCIES AND DELAY
%{
% check the frequencies
Fs = sampleRate;                                        
L = numel(egf);                                
NFFT = 2^nextpow2(L); 
Y = fft(egf,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

Y_filt = fft(filt_egf,NFFT)/L;
f_filt = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1)),'k') 
hold on
plot(f_filt,2*abs(Y_filt(1:NFFT/2+1)),'r','linewidth',2)
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
axis([0 20 0 inf])

% Plot delay to make sure it is really zero-phase
plot(egf(1:100000),'k','linewidth',2)
hold on
plot(filt_egf(1:100000),'r','linewidth',2)
hold off
%}
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% better filter but doesn't work with filtfilt (at least not obviously)

d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',1/650,1/600,1/200,1/150,60,1,60);
% fst1 - frequency at the edge of the start of the first stop band
% fp1 -  frequency at the edge of the start of the pass band
% fp2 - frequency at the edge of the end of the pass band
% fst2 - frequency at the edge of the start of the second stop band
% ast1 -  attenuation in the first stop band in decibels
% ap - amount of ripple allowed in the pass band
% ast2 -  attenuation in the second stop band in decibels

Hd = design(d,'butter'); %use butterworth filter
filt_egf = filter(Hd,egf); %zero-phase filter
%}

return