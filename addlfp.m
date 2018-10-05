function e = addlfp(e,path2ns)
% Añade el lfp a la estructura.
%
% e = addlfp(e,directorioDeArchivosNS2)
%

% Cargar archivo NS2 con los datos de LFP
id = e.ArchivoNEV(1:end-4);
ns2File = [path2ns,filesep,id,'.ns2'];

if exist(ns2File,'file')
    ns2 = openNSx(ns2File);
    lfp = ns2.Data;

    % Crear eje de tiempo para cada muestra del LFP
    fs = ns2.MetaTags.SamplingFreq;
    timeSecs = (1:size(lfp,2))/fs;

    % Cortar la señal del LFP usando el inicio y el final de cada ensayo
    for n = 1:length(e.trial);
        trialStart = e.trial(n).waitCueIni - 1;
        trialEnd = e.trial(n).targOff + 1;
        timeIndex = timeSecs >= trialStart & timeSecs <= trialEnd;
        lfpSection = lfp(:,timeIndex == 1);
        timeSection = timeSecs(timeIndex == 1);
        e.trial(n).lfp = lfpSection;
        e.trial(n).lfpTime = timeSection;
    end
else
    warning('No se encontró archivo NS2.')
end