function e = getSessionStruct(file)
% USO: e = getSessionStruct(file)
% file = file with the complete path; ex. /home/documents/files/d1605131058
% e = struct array with time events, spikes, and lfp separated by trials.

%%
if exist([file,'.nev'],'file')
    [pathstr,name] = fileparts([file,'.nev']);
    nevData = [pathstr,filesep,name,'.nev'];
    ns1File = [pathstr,filesep,name,'.ns1'];
else
    error([file, 'not found.'])
end

e = blackRock2event(nevData,ns1File);
if isstruct(e)
    e = addRobMarkers(e);

    ns2File = [pathstr,filesep,name,'.ns2'];
    ns2 = openNSx(ns2File);
    lfp = ns2.Data;

    % Crear eje de tiempo para cada muestra del LFP
    fs = ns2.MetaTags.SamplingFreq;
    timeSecs = (1:size(lfp,2))/fs;

    % Cortar la se�al del LFP usando el inicio y el final de cada ensayo
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
