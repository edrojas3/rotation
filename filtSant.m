function filtered_signal = filtSant(signal, varargin)

order = getArgumentValue('order',1,varargin{:});
fs = getArgumentValue('fs',500, varargin{:});
fc = getArgumentValue('fc',10, varargin{:});

format long
T=1/fs;
L=length(signal);
scuad=zeros(1,L);
Tiempo=L/fs;
t=0:T:Tiempo-T;
x0=signal;
x1=mean(signal(1:100));
x2=x0-x1;
Vector_size=L;

signal=x2;
[B1,A1]=butter(order,fc/(fs/2));
filtered_signal = filter(B1,A1,signal);
[f1,Y1]=ft(filtered_signal,fs);

format short
