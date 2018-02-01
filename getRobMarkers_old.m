function [s, e] = getRobMarkers_old(signal)
%%
mono = 'cesar';
matdir = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\', mono];
matfile = 'c1606141649';
a = 0.1;%[-0.1,-0.2,-0.4,-0.8,-1.6,-3.2,3.2,1.6,0.8,0.4,0.2,0.1];
load([matdir, '\', matfile])
angulos = round([e.trial.anguloRotacion]*10)/10;
clf
for i = 1:length(a)
    trials = find(angulos == a(i));
    for n = 1:length(trials)
        signal= abs(double([e.trial(trials(n)).robSignal]'));
%         signal = double(reshape(signal,[1000,length(e.trial(angulos == a(i)))]));
        signal = abs((signal - mean(signal(1:300,1))) / std(signal(1:300),1));

        % Start Point
        signal_diff = diff(abs(signal)); % Signal derivatives
        thresh = max(abs(signal(1:200))); % threshold derivatives
        minL=25; % Filter criterion 

        thresh_signal = zeros(size(signal_diff)); % thresholded derivatives
        thresh_signal(abs(signal_diff)>thresh) = signal_diff(abs(signal_diff)>thresh);
        edgefilt = [ones(1,minL) -ones(1,minL )];
        edges = [zeros(1,minL-1), conv(abs(thresh_signal),edgefilt/minL,'valid')', zeros(1,minL)];
        [~,s] = max(edges(1:400)); 


        plot(signal,'k'); hold on
    %     plot(thresh_signal); 
    %     plot(edges,'r')
    %     plot(edgefilt, 'g')
        plot(s,signal(s),'r*')
        pause
        clf 
    end
end
%%



% End Point
signal_flip = flipdim(signal(:,1),1);
flip_diff = diff(abs(signal_flip));
thresh = max(abs(flip_diff(1:500)));

thresh_flip = zeros(size(signal_flip));
thresh_flip(abs(flip_diff)>thresh) = signal_flip(abs(flip_diff)>thresh);
edges = [zeros(1,minL-1), conv(abs(thresh_flip),edgefilt/minL,'valid')', zeros(1,minL)];
[~,e] = max(edges);
l = length(signal);
e = l-e;


if nargout == 0
    plot(signal,'k'); hold on
    plot(edges,'k')
    plot([s,e],[signal(s), signal(e)],'r*')
    plot([s,e],[edges(s),edges(e)],'r*')
end
