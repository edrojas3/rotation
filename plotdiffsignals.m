function marker = plotdiffsignals(signal,varargin)

detrend = getArgumentValue('detrend',0, varargin{:});
filt = getArgumentValue('filt',0, varargin{:});
threshval = getArgumentValue('threshval',1, varargin{:});
startlim = getArgumentValue('startlim',[1,300],varargin{:});

% endlim = [length(signal)-300, length(signal)];

original = scale01(signal);

if filt 
    signal = filtSant(signal);
end

if detrend
    signal = signal - mean(signal);
end
signal = scale01(signal);
signal_diff = scale01([0; abs(diff(signal))]);

start_thresh = threshval*std( signal_diff(startlim(1):startlim(2)) ) + mean( signal_diff(startlim(1):startlim(2)) )  ;
start_mask = signal_diff >= start_thresh;
signal_masked = signal.*start_mask;
signal_masked(find(signal_masked == 0)) = nan;

plot(signal_diff,'r');
hold on
line([1,length(signal)],[start_thresh,start_thresh],'color','g','linestyle','--')
plot(signal_masked,'color',[0.5,0.5,1],'linewidth',2)
plot(signal,'k')
if filt || detrend
    plot(original,'color',[0.5,0.5,0.5],'linewidth',2)
end

axis square

count = 20;
n = startlim(1);
found = 0;
marker = 900;
while n ~= 900 || found == 1
    if all(start_mask(n:n+count) == 1) ;
        found = 1;
        marker = n;
        break
    else
        n = n + 1;
    end

end

plot(marker,original(marker),'*g')
% title(num2str(marker))