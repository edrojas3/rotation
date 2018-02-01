clearvars -except singleTrials preference
close all
clc

A = [0.8,1.6,3.2];
lA = length(A);
pleft = find(preference == 1);
pright = find(preference == -1);

len = length(singleTrials);
ts = -0.5:0.001:1;

glevel = linspace(0.2,0.9,lA);
b = [zeros(lA,1), glevel', ones(lA,1)];
r = [ones(lA,1), glevel', zeros(lA,1)];
g = [zeros(lA,1), glevel', zeros(lA,1)];

for l = 649:len
    fr = singleTrials(l).fratesDetrend;
    rotations = singleTrials(l).rotations;
    
    Lfr = [];
    Rfr = [];
    for a = 1:length(A)
        lfr = nanmean(fr(rotations==A(a),:));
        rfr = nanmean(fr(rotations==-A(a),:));
        plot(ts,lfr,'color',b(a,:));hold on
        plot(ts,rfr,'color',r(a,:))
        
        Lfr = [Lfr;lfr];
        Rfr = [Rfr;rfr];
    end
    plot(ts,nanmean(Lfr),'b','linewidth',2)
    plot(ts,nanmean(Rfr),'r','linewidth',2)
    
%     preference(l) = input('pref: ');
    pause
    clf
end