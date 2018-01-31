function e = getSessionStruct(id)
% USAGE: e = getSessionStruct(id)
% id = file identifier ej. d1605131058
% e = struct with session info separated by trial

% File path
nevFile = ['datafiles\',id,'.nev'];
ns1File = ['datafiles\', id, '.ns1'];
ns2File = (['datafiles\', id,'.ns2']);

% Session structure
if exist(nevFile,'file') && exist(ns1File,'file');
    e = blackRock2event(nevFile,ns1File); % event time-stamps and spikes
    if isstruct(e)
        e = addRobMarkers(e); % Add markers of the stimulus movement
        % Add LFP signal to the structure
        if exist(ns2File,'file')
            ns2 = openNSx(ns2File);
            lfp = ns2.Data;
            fs = ns2.MetaTags.SamplingFreq;
            timeSecs = (1:size(lfp,2))/fs; 
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
            warning('No ns2 file found. LFP will not be added to session structure');
        end
    end
else
    error('No nev or ns1 file found.')
end
