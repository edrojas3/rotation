function [frdetrended, samples] = fratedetrend(e,spk,varargin)

alignEvent = getArgumentValue('alignEvent','robMovIni',varargin{:});
A = getArgumentValue('angles',[0.1,0.2,0.4,0.8,1.6,3.2],varargin{:});
bothways = getArgumentValue('bothways',1,varargin{:});
hits = getArgumentValue('hits',1,varargin{:});
samples = getArgumentValue('samples',-0.5:0.01:1,varargin{:});
tau = getArgumentValue('tau',0.5,varargin{:});
attrit = [samples(1),samples(end)];

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

% Detrending (trial(n) - mean of hit trials)
check4zero = mean(frates,2);
frates(check4zero == 0,:) = nan;
fratesMean = nanmean(frates);
frdetrended = zeros(size(frates));
for tr = 1:size(frates,1);
    frdetrended(tr,:) = frates(tr,:) - fratesMean;
end

% Trial and rotations order
rotations = round([aligned.events.anguloRotacion]*10)/10;
if bothways == 1;
    leftindex = ismember(rotations,abs(A));
    rightindex = ismember(rotations,-abs(A));
    leftFR = nanmean(frdetrended(leftindex,:));
    rightFR = nanmean(frdetrended(rightindex,:));
    frdetrended = [leftFR;rightFR];
else
    index = ismember(rotations,A);
    frdetrended = nanmean(frdetrended(index,:));
end


if nargout == 0;
    if bothways == 1;
        plot(samples,frdetrended(1,:),'linewidth',3,'color','b'); hold on
        plot(samples,frdetrended(2,:),'linewidth',3,'color','r')
        legend('Left','Right')
    else
        plot(samples, frdetrended,'linewidth',3,'color',[0.8,0.8,0.8]);
    end

    xlabel('Time from align event (s)'); ylabel('Z-Score')
    title([e.ArchivoNEV(1:end-4),' ',alignEvent])
    set(gca,'box','off')
    grid on
    hold off
end
