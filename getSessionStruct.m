function e = getSessionStruct(id)
% USO: e = getSessionStruct(id)
% id = el identificador del archivo a cargar ej. d1605131058
% e = estructura con la información de la sesión

%%
 nevData = ['C:\Users\eduardo\Google Drive\Exp mono\',id,'.nev'];
 ns1File = ['C:\Users\eduardo\Google Drive\Exp mono\', id, '.ns1'];
 
e = blackRock2event(nevData,ns1File);
if isstruct(e)
    e = addRobMarkers(e);


    nevdir = 'C:\Users\eduardo\Google Drive\Exp mono';
    ns2File = ([nevdir, '\', id,'.ns2']);
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


end
