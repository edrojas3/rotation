matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
matfiles = dir([matdir, '\*.mat' ]);


t1 = {'touchCueIni', 'manosFijasFin', 'touchCueFin', 'touchFin', 'targOn'};
t2 = {'manosFijasFin', 'touchIni',  'touchFin', 'targOn', 'targOff' };
titles = {'RT: Raise right hand', 'MT: Reach Object', 'RT: Release Object', 'MT: Return right hand', 'MT: Response'};

A = [0.1,0.2,0.4,0.8,1.6,3.2];
angulos_esperados = sort([-A, A]);

for n = 1:length(t1);
    tr = [];
    TR = cell(1,12);
    for f = 1:length(matfiles)
        load([matdir,'\',matfiles(f).name])
        selected = selectTrials(e,'correcto',1);
        angulos = round([selected.events.anguloRotacion]*10)/10;
        for ang = 1:length(angulos_esperados)
            selectedTrials = angulos == angulos_esperados(ang);
            tr = [selected.events(selectedTrials == 1).(t2{n})] - [selected.events(selectedTrials == 1).(t1{n})];
            trvec = [cell2mat(TR(ang)), tr];
            TR{ang} = trvec;
        end
    end

    for t = 1:length(TR)
       filtlimit = std(TR{t}); 
       filtcenter = mean(TR{t});
       
       lowbound = TR{t}(TR{t} > filtcenter - filtlimit);
       upbound = TR{t}(TR{t} < filtcenter + filtlimit);
       
       TRmean(t) = mean([lowbound, upbound]);
       TRstd(t) = std([lowbound, upbound]);
    end
    
    c = [rand, rand, rand];
    plot(1:12,TRmean,'-o', 'color', c); hold on
    set(gca, 'xtick', 1:12,'xticklabel', angulos_esperados, 'ylim',[0.150, 0.5])
%     title(titles{n})
end