function plotresults2(t,signal,filteredsignal,f,X,fy,Y,interval)
% ,title1,tipo,sub1,sub2
color=rand(1,1);
color1=reshape(hsv2rgb(reshape([color,1,0.8],1,1,3)),1,3,1);

if(color>=0.5)
    color2=reshape(hsv2rgb(reshape([color-0.5,1,0.8],1,1,3)),1,3,1);
else
    color2=reshape(hsv2rgb(reshape([color+0.5,1,0.8],1,1,3)),1,3,1);
end

figure

subplot(2,2,[1 2])
plot(t(interval),signal(interval),'Color',color1),hold on
axis tight
% title({title1;['FIR Filter:',tipo]})
ylabel('Amplitude')
xlabel('Time(s)')

subplot(2,2,3)
plot(f,X,'Color',color1)
axis tight
% title(['Single-Sided Amplitude spectrum of the ',sub1])
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

subplot(2,2,[1 2])
plot(t(interval),filteredsignal(:,interval),'Color',color2)
axis tight

subplot(2,2,4)
plot(fy,Y,'Color',color2)
axis tight
% title(['Single-sided amplitude spectrum of the ',sub2])
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
end