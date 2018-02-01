close all; clear all

% wantedid = 'd1603310950.mat';

matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
matfiles = dir([matdir, '\*.mat']);

A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = [-A,A];
% A = [-1.6,1.6];
for f = 1:length(matfiles)
    
    id = matfiles(f).name;
    load([matdir, '\', matfiles(f).name])
    
    aligned = selectTrials(e, 'alignEvent', 'robMovIni');
    angulos = round([aligned.events.anguloRotacion]*10)/10;
    
    for a = 1:length(A)
       signals = submean(reshape([aligned.events(angulos == A(a)).robSignal], 1000, sum(angulos == A(a))));
       timeSec = reshape([aligned.events(angulos == A(a)).robTimeSec], 1000, sum(angulos == A(a)));
       movfin = [aligned.events(angulos == A(a)).robMovFin];
       plot(timeSec, signals,'color',[0.5,0.5,0.5])
       line([0,0],[min(signals(:)),max(signals(:))],'color','r','linewidth',2)
       line([movfin;movfin],[min(signals(:)),max(signals(:))],'color','r','linewidth',2)
       title([id, ' ',num2str(A(a))])
       pause
       clf
    end
end




%%
load c1609081708
A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = [3.2];

aligned = selectTrials(e, 'alignEvent', 'robMovIni');
angulos = round([aligned.events.anguloRotacion]*10)/10;
signals = reshape([aligned.events(angulos == A).robSignal], 1000, sum(angulos == A));
for s = 1:size(signals,2)
   plot(signals(:,s)) 
   pause
   clf
end

%%
n = 98;
spk = 'spike31';
e.matResults(n,:) = [];
e.trial(n) = [];
e.spikes(n) = [];
e.slice.(spk)(n) = [];