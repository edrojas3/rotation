function [f,y]=ft(signal,fs)

y=fft(signal)/length(signal);
y=abs(y(1:round(length(y)/2)));
f=(0:length(y)-1)*(fs/2)/(length(y)-1);
