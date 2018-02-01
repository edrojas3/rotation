clearvars ; clc
load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\c1606141649')
% Firig Rate

% Spike times
aligned = selectTrials(e, 'alignEvent', 'robMovIni','aciertos',1, 'delnotfound', 0);
spk = 'spike11';
spks = {aligned.spikes.(spk)};
tau = 0.05;

% Stimulus features
A = [0.1,0.2,0.4,0.8,1.6,3.2];  
angulos_esperados = [-A, A]; 
angulos = round([aligned.events.anguloRotacion] *10)/10; 
direction = angulos > 0; % direction of rotation (1 = left, 0 = right)

% Firing rate per rotation angle
for ii = 1:length(angulos_esperados)
    trialIndex = angulos == angulos_esperados(ii);
    end_median = median([aligned.events(trialIndex == 1).robMovFin]);
    samples = .02:0.01:end_median+0.3;
    frate = firingrate({spks{trialIndex == 1}}, samples, 'FilterType', 'exponential',  'TimeConstant', tau);
    table(ii,:) = histcounts(frate,[0,15,30,100]);
end
%%
for ii = 0:1
    ind = find(direction == ii);
    table(:,ii) = histc()
end

ps = s./ntrials