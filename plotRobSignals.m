clf; clc

% d1604271044, d16040301146 tiene desfases
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
matfiles = dir([matdir, '\*.mat']);
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\alignTemplate\leftrightoverlap';

a = [ 0.1,  0.2,  0.4,  0.8, 1.6,  3.2];

for f = 45:length(matfiles)
    id = matfiles(f).name(1:end-4);
    load(id)
    if ~isfield(e.trial, 'robMovIni'); continue; end
    angulos = abs(round([e.trial.anguloRotacion]*10)/10);
    del = find(ismember(angulos, a) == 0);
    if del; e.trial(del) = []; end

    aligned = selectTrials(e, 'alignEvent', 'robMovIni');
    for i = 1:length(aligned.events)
       plot(aligned.events(i).robTimeSec, aligned.events(i).robSignal) ; hold on
    end
    title(id)
    savename = [savedir, '\', id, '.png'];
    saveas(gcf, savename)
    clf
end
%%

for f = 1:length(matfiles)
    clf
    disp([num2str(f), '/', num2str(length(matfiles))])
    id = matfiles(f).name;
    load([matdir, '\',id])
    
    iniEvent = 'movIni';
    finEvent = 'movFin';
    aligned = selectTrials(e,'alignEvent','robMovIni');
    
    angulos = round([aligned.events.anguloRotacion]*10)/10;
    a = [ 0.1,  0.2,  0.4,  0.8, 1.6,  3.2];
    a = [-0.1, 0.1, -0.2, 0.2, -0.4, 0.4, -0.8, 0.8, -1.6, 1.6, -3.2, 3.2];
    for ang = 1:length(a)
         S = [];
         T = [];
        index = find(angulos == a(ang));
        for i = 1:length(index)
            s = index(i);
            if sign(aligned.events(s).anguloRotacion) == -1
                signal = -1*(double(aligned.events(s).robSignal));
                right = 1;
            else
                signal = double(aligned.events(s).robSignal);
                right = 0;
            end
            ts = aligned.events(s).robTimeSec;
            ini = aligned.events(s).(iniEvent);
            fin = aligned.events(s).(finEvent);
            cueoff = aligned.events(s).touchCueFin;
            
            S = [S, scale01(signal(:))];
            T = [T, ts(:)];
            if right;
                c = 'b';
            else
                c = 'r';
            end
%             subplot(3,2,ang)
%             plot(ts,scale01(signal), 'color', c); hold on

        end
        figure
        plot(T,S, 'color', [0.7,0.7,0.7]), hold on
        plot(T(:,1), mean(S,2), 'r')
        set(gca, 'ylim', [-0.1,1.1])
        title(num2str(a(ang)))
    end
%     savename = [savedir, '\', id(1:end-4), '.png'];
%     saveas(gcf, savename)
end