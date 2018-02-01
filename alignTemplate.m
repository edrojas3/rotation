matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles';
mono = 'dewey';
matid = 'd1606161035';
load([matdir, '\', mono, '\', matid])

templatesfile = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\robSignalTemplates.mat';
load(templatesfile)

a = -1.6;
% angulos = [-0.1,-0.2,-0.4,-0.8,-1.6,-3.2,0.1,0.2,0.4,0.8,1.6,3.2];
anglist = round([e.trial.anguloRotacion]*10)/10;
trials = find(anglist == a);
signals = double(reshape([e.trial(trials).robSignal], 1000, length(trials)));
signals_flip = flipdim(signals,1);

signal_norm = zeros(size(signals));
signal_normflip = zeros(size(signals));
for s = 1:size(signal_norm,2)
   signal_norm(:,s)  = abs( ( signals(:,s) - mean(signals(1:200,s)) ) / std(signals(1:200,s)) );
   signal_normflip(:,s) = abs( ( signals_flip(:,s) - mean(signals_flip(1:200,s)) ) / std(signals_flip(1:200,s)) );
end

tempindx = find(angulos == a);
template_s = templates_start{tempindx};
template_e = templates_end{tempindx};

start_markers = getRobMarkers(signal_norm, template_s, 'start');
end_markers = getRobMarkers(signal_normflip, template_e, 'end');



for n = 1:size(signal_norm,2)
    plot(signal_norm(:,n)); hold on
%     plot([start_markers(n), end_markers(n)], [signal_norm(start_markers(n),n), signal_norm(end_markers(n),n)], '*r')
    plot(start_markers(n), signal_norm(start_markers(n),n), '*r')
    pause
    clf
end

%%
template_mean = mean(template);
len = length(template);
displacements = 1000-len;

for n = 1: size(signal_norm,2);
    start_r = zeros(1,length(displacements));
    end_r = zeros(1,length(displacements));
    for i = 1:displacements;
        section = signal_norm(i:i+len-1,n);
        start_r(i) = corr(section, template);
        end_r(i) = corr(flipdim(section,1), flipdim(template,1));
    end
    [start_val, start_I] = max(start_r);
    [end_val, end_I] = max(abs(end_r));
    
    clf
    plot(signal_norm(:,n)); hold on
    plot([start_I, end_I], [signal_norm(start_I,n),signal_norm(end_I,n) ], '*r')
    pause
    clf
end
%%
for n = 1: size(signal_norm,2);
    r = zeros(1,length(displacements));
    for i = 1:displacements;
        section = signal_norm(i:i+len-1,n);
        section_mean = mean(section);

        temp_demean = template - template_mean;
        section_demean = section - section_mean;

        temp_sqrt = sqrt(sum(temp_demean.^2));
        section_sqrt = sqrt(sum(section_demean.^2));

        r(i) = (sum(temp_demean.*section_demean)) / (temp_sqrt *section_sqrt);
    end
      [val, I] = max(r);
    plot(signal_norm(:,n)); hold on
    plot(I,signal_norm(I,n), '*r')
    pause
    clf
end

%% CROSSCORRELATION

for s = 1:size(signal_norm,2)
    signal_filt = filtsignal(signal_norm(:,s));
    [coefs, lags] = xcorr(signal_filt, template);
    [~,I] = max(coefs);
    lagDiff = lags(I);
    timetemplate = lagDiff + (1:length(template));
    
    plot(signal_norm(:,s)); hold on
    plot(timetemplate, template, 'r')
    pause
    clf 
    
end

%%
signal_filt = filtsignal(signal_norm(:,s));
norm_fft = fft(signal_norm(:,s));
filt_fft = fft(signal_filt);

clf
subplot(2,1,1)
plot(signal_norm(:,s)); hold on
plot(signal_filt,'r')
subplot(2,1,2)
plot(abs(norm_fft), 'linewidth',3); hold on
plot(abs(filt_fft),'r')

%% Slopes distributions
signal = signal_norm(:,1);
center = [];
datapoints = 30;

if  ~(isempty(center));
    displacements = center + 1 : 1000 - (center*2);
    
else 
    displacements = 1 : 1000 - datapoints;
end


for n = displacements
    if ~(isempty(center));
        section = signal(n-center:n+center-1) ;
    else
        section = signal(n:n+datapoints-1);
    end
    
    for iteration = 1:1000
        samples = randsample(1:length(section),2);
        x1 = min(samples); x2 = max(samples);
        y1 = section(x1); y2 = section(x2);
        diffx = x2 - x1;
        diffy = y2 - y1;
        m(iteration) = diffy / diffx;
        
    end
        slope_mean(n) = mean(m);
        slope_std(n) = std(m);
end


clf
slope_norm = ( abs(slope_mean) - mean( abs(slope_mean(1:300)) )) / std( abs(slope_mean(1:300)) );
thresh = 2.3;
thresh_points = find(slope_std >= thresh);
markers = [thresh_points(1), thresh_points(end)];
subplot(2,1,1)
plot(signal); hold on
plot( [markers(1), markers(2)], [signal(markers(1)), signal(markers(2))], '*r')

subplot(2,1,2)
plot(slope_mean); hold on
plot(thresh_points, slope_std(thresh_points), '*r')
plot(slope_std,'k')
shg