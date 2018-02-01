function marker = getRobMarkers(signal,varargin)

startlim = getArgumentValue('startlim',[1,300], varargin{:});
%%
% startlim = [1,300];
% clf
endlim = [length(signal)-300, length(signal)];%getArgumentValue('endlim', [700,1000], varargin{:});

signal = double(signal(:));
signal_diff = [0; abs(diff(signal))];
start_thresh = 2.3*std( signal_diff(startlim(1):startlim(2)) ) + mean( signal_diff(startlim(1):startlim(2)) )  ;
start_mask = signal_diff >= start_thresh;

% signal_diff(start_mask == 1) = 1;
% signal_diff(start_mask == 0) = 0;
% plot(scale01(signal),'k'); hold on
% plot(signal_diff,'r')
% set(gca, 'ylim', [-0.5,1.5])
% axis square
%
count = 20;
n = startlim(1);
found = 0;
while ~found 
   if all(start_mask(n:n+count) == 1) ;
       found = 1;
       marker(1) = n;
   else
       n = n + 1;
   end
%    plot(signal_diff, '-*'); hold on
%    plot(n:n+count, signal_diff(n:n+count), '*r')
%    pause
%    clf
   
end
%  plot(signal_diff, '-*'); hold on
%  plot(n:n+count, signal_diff(n:n+count), '*r')
   
end_thresh = std( signal_diff(endlim(1):endlim(2)) ) + mean( signal_diff(endlim(1):endlim(2)) );
end_mask = signal_diff >= end_thresh;

count = 15;
found = 0;
n = endlim(2);
while ~found
    if all(end_mask(n-count:n) == 1);
         found = 1;
        marker(2) = n;
        
    else
       n = n-1;
    end
%     plot(signal_diff, '-*'); hold on
%     plot(n-count:n, signal_diff(n-count:n), '*r')
%     pause
%     clf
end
% plot(signal_diff, '-*'); hold on
% plot(n-count:n, signal_diff(n-count:n), '*r')

if nargout == 0;
    % Scale signal between 0 and 1
    signal_min = min(signal);
    signal_max = max(signal);
    signal_range = signal_max - signal_min;
    signal_scale = (signal - signal_min) ./ signal_range;
    
    % Scale derivatives
    diff_min = min(signal_diff);
    diff_max = max(signal_diff);
    diff_range = diff_max - diff_min;
    diff_scale = (signal_diff - diff_min) / diff_range;
    plot(signal_scale, 'r'); hold on
    plot(diff_scale, 'b')
    xposition = [marker; marker];
    yposition = [0,0;1,1];
    line(xposition, yposition, 'color', 'k')
%     plot(n:n+count, signal_diff(n:n+count)/max(signal_diff(n:n+count)), '*r')
end