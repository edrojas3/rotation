function [normfrate,samples] = fratenorm(e,spk,varargin)
% Get normalized firing rates for a set of stimuli
%
% Usage: 
% [normfrate,samples] = fratenorm(e,spk)
% fratenorm(e,spk)  plots the normalized firing rates
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
normMean = getArgumentValue('normMean',1,varargin{:});
hits = getArgumentValue('hits',1,varargin{:});
samples = getArgumentValue('samples',-0.5:0.01:1,varargin{:});
singleTrials = getArgumentValue('singleTrials',0,varargin{:});
tau = getArgumentValue('tau',0.05,varargin{:});
attrit = [samples(1),samples(end)];
normindex = find(samples <= 0);

if ischar(e)
    load(e)
end

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
    warning('Ignoring hit input; invalid argument value.')
    aligned = selectTrials(e, 'alignEvent', alignEvent,'delnotfound', 1);
end
spks = {aligned.spikes.(spk)};
rotations = round([aligned.events.anguloRotacion]*10)/10;

% Get firing rates
if bothways == 0;
    normfrate = cell(1,length(A));
else
    normfrate = cell(2,length(A));
end
for ang = 1:length(A)
    frates = firingrate({spks{rotations == A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);

    if ~(isempty(frates));
        if size(frates,1) == 1;
            frmean = frates;
        else
            frmean = nanmean(frates);
        end
        frnorm = (frmean - nanmean(frmean(normindex))) / std(frmean(normindex));
       normfrate{1, ang} = frnorm;
    end
    
    if bothways == 1;
        fratesInverse = firingrate({spks{rotations == -A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);

        if ~(isempty(fratesInverse));
            if size(fratesInverse,1) == 1;
                frInverseMean = fratesInverse;
            else
                frInverseMean = nanmean(fratesInverse);
            end
            frInverseNorm = (frInverseMean - nanmean(frInverseMean(normindex))) / std(frInverseMean(normindex));
            normfrate{2, ang} = frInverseNorm;
        end
    end
end


% Plot firing rates
if nargout == 0;
    if bothways == 1;
        if normMean
            izq = mean(cell2mat(normfrate(1,:)'));
            der = mean(cell2mat(normfrate(2,:)'));
            plot(samples,izq,'linewidth',3,'color','b'); hold on
            plot(samples,der,'linewidth',3,'color','r')
            legend('Left','Right')
        else
            lenA = length(A);
            glevel = linspace(0,1,lenA);
            b = [zeros(lenA,1), glevel', ones(lenA,1)];
            r = [ones(lenA,1), glevel', zeros(lenA,1)];
            g = [zeros(lenA,1), glevel', zeros(lenA,1)];

            for n = 1:lenA
                plot(samples,normfrate{1,n},'linewidth',2,'color',b(n,:)); hold on
                plot(samples,normfrate{2,n},'linewidth',2,'color',r(n,:))
            end           
        end
    else
        plot(samples, normfrate,'linewidth',3,'color',[0.8,0.8,0.8]);
    end

    xlabel('Time from align event (s)'); ylabel('Z-Score')
    title([e.ArchivoNEV(1:end-4),' ',alignEvent])
    set(gca,'box','off')
    grid on
    hold off
end

