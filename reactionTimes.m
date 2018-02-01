clear all
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
matfiles = dir([matdir,'\*.mat']);
A = [0.1,0.2,0.4,0.8,1.6,3.2];
for f = 1:length(matfiles)
    load([matdir,'\',matfiles(f).name]) 
    hits = [e.trial.correcto];
    rotations = round([e.trial.anguloRotacion]*10) / 10;
    for ang = 1:length(A)
        indexH = find(abs(rotations) == A(ang) & hits == 1);
        indexE = find(abs(rotations) == A(ang) & hits == 0);
        rtH = [e.trial(indexH).targOff] - [e.trial(indexH).targOn];
        rtE = [e.trial(indexE).targOff] - [e.trial(indexE).targOn];
        reactionTimesHits(f,ang) = mean(rtH);
        reactionTimesErrors(f,ang) = mean(rtE);
    end
end

%%
close all
for ang = 1:6
   subplot(2,3,ang)
   histogram(reactionTimesHits(:,ang),10) 
   hold on
   histogram(reactionTimesErrors(:,ang),30,'facecolor','y')
   title(['|',num2str(A(ang)),'|'])
   set(gca,'xlim',[0,4])
end

%%
clf

histogram(reactionTimesHits(:),10,'normalization','probability') 
hold on
histogram(reactionTimesErrors(:),55,'facecolor','r','normalization','probability')
