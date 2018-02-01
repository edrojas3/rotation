% clear all
% Neuron files
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
% load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\preferenceNeurons.mat')
load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\classification_struct.mat')

% ids = neurons.(p).ids;
ids = classif.id;

% Initial trial settings
alignEvent = 'robMovIni';
A = [0.1,0.2,0.4,0.8,1.6,3.2];
angulos_esperados = [-A, A];

% Firing rate parameters
samples = -0.5:0.01:1;
attrit = [samples(1),samples(end)];
tau = 0.5;
normindex = find(samples <= 0);

for f = 1:length(ids) % Loop for every recording session
    % Load file
    id = ids{f}(1:11);
    spk = ids{f}(12:end);
    
    if exist([matdir, '\',id,'.mat'],'file');
        disp(['processing ',id,spk])
        load([matdir, '\',id])
    else
        disp([id,' not found.'])
        continue
    end
    
    % Remove noisy trials
    slice = e.slice.(spk);
    e = eslice(e, slice);
    
    % Align
    aligned = selectTrials(e, 'alignEvent', alignEvent,'delnotfound', 1);
    angulos = round([aligned.events.anguloRotacion]*10)/10;
    spks = {aligned.spikes.(spk)};
    
    % Select errors and align
%     aligned_err = selectTrials(e, 'alignEvent', alignEvent,'aciertos',0, 'delnotfound', 1);
%     angulos_err = round([aligned_err.events.anguloRotacion]*10)/10;
%     spks_err = {aligned_err.spikes.(spk)};
          
    % Hits firing rates
    frates = firingrate(spks, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);
    
    % Detrending (trial(n) - mean of hit trials)
    hits = [aligned.events.correcto];
    fratesHits = firingrate(spks(hits == 1), samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);
    check4zero = mean(fratesHits,2);
    fratesHits(check4zero == 0,:) = nan;
    fratesMean = nanmean(fratesHits);
    fratesDetrend = zeros(size(frates));
    for tr = 1:size(frates,1);
        fratesDetrend(tr,:) = frates(tr,:) - fratesMean;
    end
    
    % Normalization of frates (z score to samples previous to align event)
    fratesNorm = zeros(size(frates));
    for tr = 1:size(frates,1)
        lbmean = mean(frates(tr,normindex));
        lbstd   = std(frates(tr,normindex));
        fratesNorm(tr,:) = (frates(tr,:) - lbmean) / lbstd;
    end
    
    % Trial and rotations order
    rotations = round([aligned.events.anguloRotacion]*10)/10;
    hits = [aligned.events.correcto];
    
    singleTrials(f) = struct('frates',frates,'fratesDetrend', fratesDetrend,...
                    'fratesNorm', fratesNorm, 'rotations', rotations,'hits',hits, 'id', [id,spk]);

end


