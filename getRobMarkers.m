function [marker,signal_diff,meandiff,stddiff,start_thresh] = getRobMarkers(signal,varargin)

detrend = getArgumentValue('detrend',0, varargin{:});
filt = getArgumentValue('filt',1, varargin{:});
threshval = getArgumentValue('threshval',1, varargin{:});
startlim = getArgumentValue('startlim',[100,300],varargin{:});%%

signal = double(signal);
original = scale01(signal);
if std(round(100*signal(1:300))) == 0;
    startlim = [200,400];
end
if filt 
    signal = filtSant(signal);
end

if detrend
    signal = signal - mean(signal);
end
signal = scale01(signal);
signal_diff = scale01([0; abs(diff(signal))]);

meandiff = mean(signal_diff(startlim(1):startlim(2)));
stddiff = std(signal_diff(startlim(1):startlim(2)));
start_thresh = threshval*stddiff + meandiff;
start_mask = signal_diff >= start_thresh;
signal_masked = signal.*start_mask;
signal_masked(find(signal_masked == 0)) = nan;


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


if nargout == 0
    plot(signal_diff,'r');
    hold on
    line([1,length(signal)],[start_thresh,start_thresh],'color','g','linestyle','--')
    plot(signal_masked,'color',[0.5,0.5,1],'linewidth',2)
    plot(signal,'k')
    if filt || detrend
        plot(original,'color',[0.5,0.5,0.5],'linewidth',2)
    end

    axis square

    plot(marker,original(marker),'*g')
    title(num2str(marker))
end
%% Old code
% endlim = [length(signal)-300, length(signal)];%getArgumentValue('endlim', [700,1000], varargin{:});
% 
% signal = double(signal(:));
% signal_diff = [0; abs(diff(signal))];
% start_thresh = 2.3*std( signal_diff(startlim(1):startlim(2)) ) + mean( signal_diff(startlim(1):startlim(2)) )  ;
% start_mask = signal_diff >= start_thresh;
% 
% signal_diff(start_mask == 1) = 1;
% signal_diff(start_mask == 0) = 0;
% plot(scale01(signal),'k'); hold on
% plot(signal_diff,'r')
% set(gca, 'ylim', [-0.5,1.5])
% axis square
% 
% count = 20;
% n = startlim(1);
% found = 0;
% while ~found 
%    if all(start_mask(n:n+count) == 1) ;
%        found = 1;
%        marker(1) = n;
%    else
%        n = n + 1;
%    end
% %    plot(signal_diff, '-*'); hold on
% %    plot(n:n+count, signal_diff(n:n+count), '*r')
% %    pause
% %    clf
%    
% end
% %  plot(signal_diff, '-*'); hold on
% %  plot(n:n+count, signal_diff(n:n+count), '*r')
%    
% end_thresh = std( signal_diff(endlim(1):endlim(2)) ) + mean( signal_diff(endlim(1):endlim(2)) );
% end_mask = signal_diff >= end_thresh;
% 
% count = 15;
% found = 0;
% n = endlim(2);
% while ~found
%     if all(end_mask(n-count:n) == 1);
%          found = 1;
%         marker(2) = n;
%         
%     else
%        n = n-1;
%     end
% %     plot(signal_diff, '-*'); hold on
% %     plot(n-count:n, signal_diff(n-count:n), '*r')
% %     pause
% %     clf
% end
% % plot(signal_diff, '-*'); hold on
% % plot(n-count:n, signal_diff(n-count:n), '*r')
% 
% if nargout == 0;
%     % Scale signal between 0 and 1
%     signal_min = min(signal);
%     signal_max = max(signal);
%     signal_range = signal_max - signal_min;
%     signal_scale = (signal - signal_min) ./ signal_range;
%     
%     % Scale derivatives
%     diff_min = min(signal_diff);
%     diff_max = max(signal_diff);
%     diff_range = diff_max - diff_min;
%     diff_scale = (signal_diff - diff_min) / diff_range;
%     plot(signal_scale, 'r'); hold on
%     plot(diff_scale, 'b')
%     xposition = [marker; marker];
%     yposition = [0,0;1,1];
%     line(xposition, yposition, 'color', 'k')
%     legend('signal', 'derivatives','start-end')
% %     plot(n:n+count, signal_diff(n:n+count)/max(signal_diff(n:n+count)), '*r')
% end