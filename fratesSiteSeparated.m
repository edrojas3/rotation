close all; clear all; clc

% files with coordinates
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
matfiles = dir([matdir, '\*.mat']);
load 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\preferenceList'

% ids of neurons with preference
lp = find(preference == 1);
rp = find(preference == -1);
pids = ids([lp,rp]);
ptag = [ones(1,length(lp)), -1*ones(1,length(rp))];

% Recording sites of neurons with preference
L = [];
R = [];
C = []; % sorted by rotation preference
for pp = 1:length(pids)
   % load file
   fname = pids{pp}(1:11);
   load([matdir,'\',fname])
   % coordinates of the recording session
   canulas = repmat(e.canulas.coordenadas(1:2),3,1);
   electrodos = [e.electrodos.profundidad - e.electrodos.corteza]'/1000;
   % select channel with the neuron 
   channel = str2num(pids{pp}(end-1));
   if     channel==1;   ch=1;
   elseif channel==3;   ch=2;
   elseif channel==5;   ch=3;
   end
   % create matrices with coordinates
   C = [C;canulas(ch,:),electrodos(ch)];
   if ptag(pp) == 1; L = [L;canulas(ch,:),electrodos(ch)];
   else              R = [R;canulas(ch,:),electrodos(ch)];
   end
end

% firing rate for each neuron sorted by rotation preference
load 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\singleTrialsStep10Tau500'
A = [0.1,0.2,0.4,0.8,1.6,3.2];
lenA = length(A);
pindex=[lp,rp];
timeSec = -0.5:0.01:1;
normIndex = find(timeSec <= 0);

lFRN = {};
rFRN = {};
lFRNE = {};
rFRNE = {};
for f = 1:length(pindex)
    hits = singleTrials(pindex(f)).hits;
    fr = singleTrials(pindex(f)).frates(hits==1,:);
    rotations = singleTrials(pindex(f)).rotations(hits==1);
    for ang = 1:lenA
        lrot = ismember(rotations,A(ang));
        rrot = ismember(rotations,-A(ang));
        lfr = fr(lrot,:);
        rfr = fr(rrot,:);
        if ~(isempty(lfr))
            if size(lfr,1)== 1; lmean = lfr;
            else lmean = nanmean(lfr);
            end
            lnorm = (lmean - mean(lmean(normIndex))) / std(lmean(normIndex));
            lFRN{f,ang} = lnorm;
        end
        
        if ~(isempty(rfr));
            if size(rfr,1) == 1; rmean = rfr;
            else rmean = nanmean(rfr);
            end
            rnorm = (rmean - mean(rmean(normIndex))) / std(rmean(normIndex));
            rFRN{f,ang} = rnorm;
        end
    end
end

% anterior-posterior separation
a = find(C(:,2)>0); %anterior
p = find(C(:,2)<0); %posterior
c = find(C(:,2)==0);%center
na = find(isnan(C(:,2)));
locindex = [a;p;c;na];
loctags = [ones(1,length(a)),-1*ones(1,length(p)),zeros(1,length(c)),99*ones(1,length(na))];
% ignore=[14,30,31,37,52,54];
ignore = 13;
ptagsSorted = ptag(locindex);
angulo = 6;
afr=[];
pfr=[];
cfr=[];
nfr=[];
for l = 1:length(locindex)
    if ismember(locindex(l),ignore);
        continue
    end
    if ptagsSorted(l)==1 && loctags(l)==1;
        afr = [afr;lFRN{locindex(l),angulo}];
        x(l) = l;
    elseif ptagsSorted(l)==-1 && loctags(l)==1
        afr = [afr;rFRN{locindex(l),angulo}];
         x(l) = l;
    elseif ptagsSorted(l)==1 && loctags(l)==-1
        pfr = [pfr;lFRN{locindex(l),angulo}];
         x(l) = l;
    elseif ptagsSorted(l)==-1 && loctags(l)==-1
        pfr = [pfr;rFRN{locindex(l),angulo}];
         x(l) = l;
    end
    
end
close all
subplot(1,2,1)
plot(timeSec,median(afr),'k','linewidth',2); hold on
plot(timeSec,median(pfr),'r','linewidth',2); hold on

% lateral-medial separation
m = find(C(:,1)>0); %anterior
l = find(C(:,1)<0); %posterior
c = find(C(:,1)==0);%center
na = find(isnan(C(:,1)));
locindex = [m;l;c;na];
loctags = [ones(1,length(m)),-1*ones(1,length(l)),zeros(1,length(c)),99*ones(1,length(na))];
% ignore=[14r,30,31,37,52,54];
ptagsSorted = ptag(locindex);
mfr=[];
lfr=[];
cfr=[];
nfr=[];
for l = 1:length(locindex)
%     if ismember(locindex(l),ignore);
%         continue
%     end
    if ptagsSorted(l)==1 && loctags(l)==1;
        mfr = [mfr;lFRN{locindex(l),angulo}];
    elseif ptagsSorted(l)==-1 && loctags(l)==1
        mfr = [mfr;rFRN{locindex(l),angulo}];
    elseif ptagsSorted(l)==1 && loctags(l)==-1
        lfr = [lfr;lFRN{locindex(l),angulo}];
    elseif ptagsSorted(l)==-1 && loctags(l)==-1
        lfr = [lfr;rFRN{locindex(l),angulo}];
    elseif ptagsSorted(l)==1 && loctags(l)==0
        cfr = [cfr;lFRN{locindex(l),angulo}];
    elseif ptagsSorted(l)==-1 && loctags(l)==0
        cfr = [cfr;rFRN{locindex(l),angulo}];
    end
    
end
% close all
subplot(1,2,1)
plot(timeSec,median(mfr),'m','linewidth',2); hold on
plot(timeSec,median(lfr),'b','linewidth',2); hold on
plot(timeSec,median(cfr),'g','linewidth',2); hold on
legend('anterior (16)', 'posterior (33)','medial (33)','lateral (7)','m-l midline (17)')
xlabel('Time from stimulus onset (s)'), ylabel('Normalized firing rate')
title('Firing rates of recording sites')

subplot(1,2,2)
plot(timeSec,pfr','linewidth',2)
% title('Firing rates of medial neurons')

%%
for ii = 1:length(p)
   plot(pfr(ii,:)) 
   pause
   clf
end