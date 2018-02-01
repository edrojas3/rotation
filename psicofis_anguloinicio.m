matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
matfiles = dir([matdir, '\*.mat' ]);

anguloInicio = [-4,0,4];

p = nan(3,length(matfiles));
for f = 35:length(matfiles)
    load(matfiles(f).name)
    ai = round([e.trial.anguloInicio]*10)/10;
    
    trials_indx = find(ismember(ai, anguloInicio) == 1);
    e.trial = e.trial(trials_indx);
    [a,p(:,f)] = psicofis(e, 'anguloInicio');
   
end


plot(anguloInicio,nanmean(p,2), 'o')
set(gca,'xlim',[-4.5,4.5] ,'ylim', [0,1])