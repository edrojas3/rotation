function [signal_lag,k] = alignSignal(template, signal, varargin)

scaling = getArgumentValue('scaling', 1, varargin{:});
crop = getArgumentValue('crop',1,varargin{:});
thresh = getArgumentValue('thresh',1,varargin{:});
plots = getArgumentValue('plots',0,varargin{:});

template = double(template(:));
signal = double(signal(:));

if scaling;
    template = scale01(template);
    signal = scale01(signal);
end
%%
% Crops the signal to reduce search
originalTemplate = template;
originalSignal = signal;
if crop == 1
    cropsignal = 300:500;
    template = scale01(template(cropsignal));
    signal = signal(cropsignal);
end
% lag vector and elongates signal vector for search
len = length(template);
lags = -(len-1):len-1;
signal_min = nan(1, length(lags));
signal2 = scale01([nan(len-1,1); signal;nan(len-1,1)]);

%%

for d = 1:length(signal2)-length(template)
    signal_min(d) = abs(max(template - signal2(d:d+len-1)));
end

smean= mean(signal_min(200:300));
sstd = std(signal_min(200:300));
sthresh = thresh*sstd + smean;
signal_bin = signal_min > sthresh;
proxTo0 = find(signal_bin == 0);

if plots
    subplot(1,2,2)
    plot(1:d,signal_min(1:d),'color',[0.5,1,0.5])
        hold on
    plot(signal_bin)
    line([1,length(signal_min)],[sthresh,sthresh])
    legend('Template-Signal','Template-Signal threshholded','Threshhold')
    legend('boxoff','location','southwest');

    axis square
    
end

%%
% [~, ind] = min(signal_min);
ind = proxTo0(1);
k = lags(ind);

%%
if k < 0;
    signal_crop = originalSignal(1:1000-abs(k));
    signal_lag = [signal_crop(1:abs(k));signal_crop]; 
elseif k > 0;
    indices = (1:1000)-k ;
    signal_crop = originalSignal(indices > 0);
    signal_lag = [signal_crop;repmat(nanmean(originalSignal(700:1000)),k,1)] ;
elseif k == 0;
    signal_lag = originalSignal;
end

% nanindex = isnan(signal_lag);
% signal_lag(nanindex < 300) = nanmean(originalSignal(1:300));
% signal_lag(nanindex > 600) = nanmean(originalSignal(700:1000));

%%
if plots
    subplot(1,2,1)
    plot(originalSignal,'linewidth',1.5); hold on
    plot(originalTemplate, 'r')
    plot(signal_lag,'g')
    legend('Original', 'Template', 'Aligned');
    legend('boxoff');
    axis square
end