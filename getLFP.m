clear all; clc

% id = 'd1609231120';
nevdir = 'C:\Users\eduardo\Google Drive\Exp mono';
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecsLFP';
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
matfiles = dir('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\*.mat');
for f = 1:length(matfiles)
    disp([num2str(f),'/', num2str(length(matfiles))])
    id = matfiles(f).name(1:end-4);
    
    if exist([savedir, '\', id, '.mat'],'file')
        continue
    end
    if ~(exist([nevdir, '\',id,'.ns2'],'file'));
        continue        
    end
    
    % Abrir archivo NS2 con los LFPs
    ns2File = ([nevdir, '\', id,'.ns2']);
    ns2 = openNSx(ns2File);
    lfp = ns2.Data;

    % Crear eje de tiempo para cada muestra del LFP
    fs = ns2.MetaTags.SamplingFreq;
    timeSecs = (1:size(lfp,2))/fs;

    % Cortar la señal del LFP usando el inicio y el final de cada ensayo
    load([matdir, '\', id,'.mat'])
    for n = 1:length(e.trial);
        trialStart = e.trial(n).waitCueIni - 1;
        trialEnd = e.trial(n).targOff + 1;
        timeIndex = timeSecs >= trialStart & timeSecs <= trialEnd;
        lfpSection = lfp(:,timeIndex == 1);
        timeSection = timeSecs(timeIndex == 1);
        e.trial(n).lfp = lfpSection;
        e.trial(n).lfpTime = timeSection;
    end

    save([savedir, '\', id], 'e')
end