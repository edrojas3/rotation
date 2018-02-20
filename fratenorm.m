function [normfrate,samples] = fratenorm(e,spk,varargin)
% Get normalized firing rates for a set of stimuli
%
% Usage: 
% [normfrate,samples] = fratenorm(e,spk)
% fratenorm(e,spk) % plots the normalized firing rates
% 
% To obtain the firing rates the function uses an exponential window with a
% constant decay of 0.5 ms and moving steps of 0.1 ms. The normalization is
% a z-score transformation with respect to the previous 500 ms to the
% align event (default is stimulus onset).
%
% The function uses all the magnitudes but you can specify a subset of
% magnitudes by using the option 'angles'. Ex.
% fratenorm(e,spk,'angles',3.2)
% The previous line only uses the biggest magnitude.

% Initial trial settings
alignEvent = getArgumentValue('alignEvent','robMovIni',varargin{:});
A = getArgumentValue('angles',[0.1,0.2,0.4,0.8,1.6,3.2],varargin{:});
bothways = getArgumentValue('bothways',1,varargin{:});
hits = getArgumentValue('hits',1,varargin{:});
samples = getArgumentValue('samples',-0.5:0.01:1,varargin{:});
tau = getArgumentValue('tau',0.5,varargin{:});
attrit = [samples(1),samples(end)];
normindex = find(samples <= 0);


% Remove noisy trials
if isfield(e,'slice')
    slice = e.slice.(spk);
else
    slice = ones(length(trial),1);
end
e = eslice(e, slice);

% Align
if hits == 0 || hits == 1;
    aligned = selectTrials(e, 'alignEvent', alignEvent,'aciertos',hits,'delnotfound', 1);
else
    aligned = selectTrials(e, 'alignEvent', alignEvent,'delnotfound', 1);
end
spks = {aligned.spikes.(spk)};

% Get firing rates
frates = firingrate(spks, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);

% Normalization of frates (z score to samples previous to align event)
normfrate = zeros(size(frates));
for tr = 1:size(frates,1)
    lbmean = mean(frates(tr,normindex));
    lbstd   = std(frates(tr,normindex));
    normfrate(tr,:) = (frates(tr,:) - lbmean) / lbstd;
end

% Trial and rotations order
rotations = round([aligned.events.anguloRotacion]*10)/10;
if bothways == 1;
    leftindex = ismember(rotations,abs(A));
    rightindex = ismember(rotations,-abs(A));
    if sum(leftindex) > 1;
        leftFR = nanmean(normfrate(leftindex,:));
    else
        leftFr = normfrate(leftindex,:);
    end
    if sum(rightindex)>1;
        rightFR = nanmean(normfrate(rightindex,:));
    else
        rightFr = normfrate(rightindex,:);
    end
    normfrate = [leftFR;rightFR];
else
    index = ismember(rotations,A);
    if sum(index) > 1;
        normfrate = nanmean(normfrate(index,:));
    else
        normfrate = normfrate(index,:);
    end
end

% Plot firing rates
if nargout == 0;
    if bothways == 1;
        plot(samples,normfrate(1,:),'linewidth',3,'color','b'); hold on
        plot(samples,normfrate(2,:),'linewidth',3,'color','r')
        legend('Left','Right')
    else
        plot(samples, normfrate,'linewidth',3,'color',[0.8,0.8,0.8]);
    end

    xlabel('Time from align event (s)'); ylabel('Z-Score')
    title([e.ArchivoNEV(1:end-4),' ',alignEvent])
    set(gca,'box','off')
    grid on
    hold off
end

