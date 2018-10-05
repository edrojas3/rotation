function e = addRobMarkers(e, varargin)

signalFilt = getArgumentValue('signalFilt',0, varargin{:});

for n = 1:length(e.trial);
    signal = double(e.trial(n).robSignal);
    if signalFilt;
        signal = filtSant(signal, 15, 70); % Not recommended.
    end
    ts = e.trial(n).robTimeSec;

    cmdini = e.trial(n).cmdStim;
    cmdfin = e.trial(n).stimFin;
    movini = e.trial(n).movIni;
    movfin = e.trial(n).movFin;

    tsini = cmdini < ts & ts < movini;
    ini = find(tsini == 1);
    if isempty(ini);
        startlim = [1,300];
    else
        startlim  = [ini(1), ini(end)];
    end

    tsend = movfin < ts & ts < cmdfin;
    fin = find(tsend == 1);
    if isempty(fin);
        endlim = [700, 1000];
    else
        endlim = [fin(1), fin(end)];
    end

    try 
        mark = getRobMarkers(signal, 'startlim', startlim, 'endlim', endlim);
    catch err
        e.trial(n).robMarkIni = movini;
        e.trial(n).robMarkfin = movfin;
        continue
    end

    mark = [ts(mark(1)), ts(mark(2))];
    e.trial(n).robMarkIni = mark(1);
    e.trial(n).robMarkfin = mark(2);
end