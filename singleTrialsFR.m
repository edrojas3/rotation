function singleTrials = singleTrialsFR(idlist, matfilesdir,varargin)
% singleTrialsFR() creates a structure with the firing rate of single
% trials of the indicated neurons.
%
% singleTrialsStruct = singleTrialsFR(idlist,matfiles)
% idlist = cell array with the neuron identifiers. For example: 
%          idlist = {'c1607191054spike11', 'd1610101134spike12'};
% matfiles = string of the path where the mat files with neuron data are
% found.
%


% Initial trial settings
alignEvent = getArgumentValue('alignEvent', 'robMovIni',varargin{:});

% Firing rate parameters
samples = getArgumentValue('timeSamples',-0.5:0.01:1,varargin{:});
tau = getArgumentValue('tau',0.5,varargin{:});

attrit = [samples(1),samples(end)];
normindex = find(samples <= 0);

for f = 1:length(idlist) % Loop for every recording session
   
    % Load file
    id = idlist{f}(1:11);
    spk = idlist{f}(12:end);
    
    if exist([matfilesdir, filesep, id,'.mat'],'file');
        disp(['processing ',id,spk])
        load([matfilesdir, filesep, id])
    else
        disp([id,' not found.'])
        continue
    end
    
    % Remove noisy trials
    slice = e.slice.(spk);
    e = eslice(e, slice);
    
    % Align
    
    aligned = selectTrials(e, 'alignEvent', alignEvent,'delnotfound', 1);
    spks = {aligned.spikes.(spk)};
    
    % Get firing rates
    frates = firingrate(spks, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', attrit);
    
    % Detrending (trial(n) - mean of hit trials)
    check4zero = mean(frates,2);
    frates(check4zero == 0,:) = nan;
    fratesMean = nanmean(frates);
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
                    'fratesNorm', fratesNorm, 'rotations', rotations,'hits',hits, 'id', [id,spk],'timeSec',samples);

end


