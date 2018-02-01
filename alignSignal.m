function [signal_lag,k] = alignSignal(template, signal, varargin)

scaling = getArgumentValue('scaling', 1, varargin{:});

template = double(template(:));
signal = double(signal(:));

if scaling;
    template = scale01(template);
    signal = scale01(signal);
end

len = length(template);
lags = -(len-1):len-1;
signal_diff = [];%zeros(1000, length(lags));


signal2 = [nan(999,1); signal;nan(999,1)];
for d = 1:length(lags)
    signal_diff(:,d) = max(abs(template - signal2(d:d+999)));%corr(signal2(d:d+999), template); 
end
[~, ind] = min(signal_diff(900:1400));
lags_sec = lags(900:1400);
k = lags_sec(ind);


signal_lag = signal;
indices = [1:1000]-k ;

if k > 0;
    signal_crop = signal(indices > 0);
    signal_lag(1:length(signal_crop)) = signal_crop;

elseif k < 0;
    signal_crop = signal(1:1000-abs(k));
    signal_lag(abs(k)+1:end) = signal_crop; 

elseif k == 0;
    signal_lag = signal;
end

% nanindex = find(isnan(signal_lag(:,n)) == 1);
% signal_lag(nanindex < 300, n) = mean(signal(1:300,n));
% signal_lag(nanindex > 600, n) = mean(signal(700:1000,n));


if nargout == 0
    plot(signal); hold on
    plot(template, 'r')
    plot([1:1000]-k,signal, 'g');
    
    legend('Original', 'Template', 'Aligned');
    legend('boxoff');
    
end