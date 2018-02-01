function [] = fullRunRaster(e)

filenameparts = strread(e.ArchivoNEV,'%s','delimiter','.');
id = filenameparts{1};

if ispc;
    figdir = 'C:\Users\eduardo\Dropbox\rotacion\figures\';
else
    figdir = '/home/eduardo/Dropbox/rotacion/figures/';
end


% Excluir ensayos incorrectos
ntrials = 1:length(e.trial);
correctos = [e.trial.correcto]';
ntrials(correctos == 0) = []; % eliminar ensayos incorrectos


arot = [[e.trial(ntrials).anguloRotacion]', ([e.trial(ntrials).anguloRotacion]' < 0)*-1, ntrials'];
arot(arot(:,2) == 0, 2) = 1;
ar_sort = sortrows(arot,1);
[ar_abs_sort, index] = sortrows(abs(ar_sort(:,1)));
sortmatrix = [ar_abs_sort, ar_sort(index,2), ar_sort(index,3)];
topright = sortrows(sortmatrix,2);
sorted_trials = topright(:,3);



% trialLims = find(sorted_trials > 90);
% sorted_trials = sorted_trials(trialLims);
%sorted_trials = 1:length(e.trial);

spike_names = fieldnames(e.spikes);

for spk = 1:length(spike_names);
    spike_id = {spike_names{spk}};
    
    figure 
    set(gcf, 'position', [1,1,1920,1080]);
    
    subplot(231)
    alignEvent = 'manosFijasFin';
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title([id ' ' spike_id{1} ' ' alignEvent ' n=' num2str(length(sorted_trials))])

    subplot(232)
    alignEvent = 'touchIni';
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title(alignEvent);

    alignEvent = 'movIni';
    subplot(233)
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title(alignEvent);

    alignEvent = 'touchFin';
    subplot(234)
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title(alignEvent);

    alignEvent = 'targOn';
    subplot(235)
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title(alignEvent);

    alignEvent = 'targOff';
    subplot(236)
    myrasterplot(e,spike_id,alignEvent,sorted_trials)
    title(alignEvent);
    saveas(gcf, [figdir, id, '_', spike_id{1}, '_raster'], 'png')
end