function [xticks, yticks] = rasterplot(spiketimes,varargin)
%
% Generates a raster plot of the spike times.
%
% [xticks, yticks] = rasterplot(SpikeTimes)
% [xticks, yticks] = rasterplot(SpikeTimes,'QuickPlot','yes','TickMarkLength',0.8)
% [xticks, yticks] = rasterplot(SpikeTimes,'xlim',[-1 2])
% [xticks, yticks] = rasterplot(SpikeTimes,'displace',.5) Use 'displace' to move the spikes along the x-axis
%
% Example:
% SpikeTimes{1}   = [22 34 58 77];          
% SpikeTimes{2}   = [33 44 55 45 78 98 99];
% [xticks,yticks] = rasterplot(SpikeTimes)
% plot(xticks,yticks)
%
% vhdlf aug2007 - jun2011

% Default parameter values:
TickMarkLength = 0.8;        % Proportion of row height occupied by the spike tick marks.
QuickPlot      = 'no';       % 'yes' will plot dots instead of lines, which is much faster.
xlim           = [-inf inf]; % Plots all spikes by default.
displace       = 0;          % Move the spikes along the x-axis. 
fig            = [];         % Figure handle.
spkColor       = [0,0,0]; % Gray is the default spike color.

% To change the parameter values:
for field_num = 1:2:length(varargin)
   if strcmpi(varargin{field_num},'QuickPlot')
      QuickPlot = varargin{field_num+1};   % Modifies the default value;
   elseif strcmpi(varargin{field_num},'TickMarkLength')
      TickMarkLength = varargin{field_num+1};   % Modifies the default value;
   elseif strcmpi(varargin{field_num},'xlim')
      xlim = varargin{field_num+1};   % Modifies the default value;
   elseif strcmpi(varargin{field_num},'displace')
      displace = varargin{field_num+1};   % Modifies the default value;
   elseif strcmpi(varargin{field_num},'fig')
      fig = varargin{field_num+1};   % Modifies the default value;
   elseif strcmpi(varargin{field_num},'color')
      spkColor = varargin{field_num+1};   % Modifies the default value;
   end
end

if size(xlim,1)==1 % Expand xlim to match the legnth of the spiketimes.
  xlim  = [xlim(1)*ones(length(spiketimes),1) xlim(2)*ones(length(spiketimes),1)];
end

% Platform specific parameters. See the "Memory Allocation" help topic. We're assuming spike times are strored as double.
headerSize = 60; % Bytes.
doubleSize =  8; % Bytes.

%info        = whos('spiketimes');                                    % Get the info about the spiketimes cell array.
%numOfSpikes = (info.bytes-headerSize*length(spiketimes))/doubleSize; % Calculate the number of spikes stored in the whole array.
numOfSpikes = sum(cellfun(@length,spiketimes));

if ~iscell(spiketimes) % In case spiketimes is not a cell array.
   spiketimes = {spiketimes};
end

% Allocate memory for the output matrices/vectors.
if strcmpi(QuickPlot,'yes') % For plotting dots instead of lines.
   xticks = zeros(1,numOfSpikes);
   yticks = zeros(1,numOfSpikes);
else
   xticks = zeros(2,numOfSpikes);
   yticks = zeros(2,numOfSpikes);
end

dk = 1; % A counter.
for trial = 1 : length(spiketimes)

%    spiketimes{k}   = ktrial.spikes(ktrial.spikes>=xlim(1) & ktrial.spikes<=xlim(2)) + displ;
    spkt     = spiketimes{trial}(:);    % Make the spike times a colum vector.
    spkt     = spkt(spkt>=xlim(trial,1) & spkt<=xlim(trial,2)) + displace; % Select the spikes within xlim and displace them
    rowNumb  = trial-TickMarkLength/2;  % The spike tickmark beggins here.
    numSpk   = length(spkt);            % Get the number of spikes in the trial.
    if numSpk > 0;
   % x and y position of each tickmark
       if strcmpi(QuickPlot,'yes') % For plotting dots instead of lines (plotting will be faster).
          xticks ( :, dk:dk + numSpk-1 ) = spkt';
          yticks ( :, dk:dk + numSpk-1 ) = trial*ones(1,numSpk);
       else % For plotting lines (plotting will be slower).
          xticks ( :, dk:dk + numSpk-1 ) = [spkt'; spkt'];
          yticks ( :, dk:dk + numSpk-1 ) = [rowNumb*ones(1,numSpk) ; rowNumb*ones(1,numSpk)+TickMarkLength];
       end
    end
    % Update the counter.
    dk  = dk  + numSpk;
end


% Plotting
if nargout == 0
%    if isempty(fig)
%       %togglefig('rasterplot')
%    else
%       figure(fig)
%    end
% 
   if strcmpi(QuickPlot,'yes') 
      linestyle = 'none'; marker    = '.';
   else
      linestyle = '-'; marker    = 'none';
   end

   % Plot and configure axes.
   line(xticks,yticks,'LineStyle',linestyle,'marker',marker,'markersize', 5,'linewidth',2,'color',spkColor)
%   set(gca,'ylim',[0 length(spiketimes)+1],'tickdir','out'); box off
   set(gca,'tickdir','out'); box off
end

% OLD CODE
% if nargout == 0
%    togglefig('rasterplot')
%    if strcmpi(QuickPlot,'yes') 
%       plot(xticks,yticks,'.')
%    else
%       plot(xticks,yticks,'color',[.5 .5 .5])
% 
%    end
% end
