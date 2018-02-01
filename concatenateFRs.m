clearvars -except singleTrials preference
close all
clc

A = [0.1,0.2,0.4,0.8,1.6,3.2];
% A = [0.1,0.2,0.4];
A = [3.2];
ts = -.5:0.01:1;
pleft = find(preference == 1);
pright = find(preference == -1);

idleft = singleTrials(pleft).id;
idright = singleTrials(pright).id;

% FIRING RATES FOR LEFT PREFERENCE NEURONS
lFR = [];
rFR = [];
lFRerr = [];
rFRerr = [];
for ii = 1:length(pleft)
       
    % firing rates (hits)
    hits = singleTrials(pleft(ii)).hits;
    fr = singleTrials(pleft(ii)).fratesDetrend(hits == 1,:);
    rotations = singleTrials(pleft(ii)).rotations(hits == 1);
    lrot = ismember(rotations,A);
    rrot = ismember(rotations,-A);   
    lfr = fr(lrot,:);
    [val,maxind] = max(max(lfr,[],2));
    if val > 50; continue; end
    lFR = [lFR;fr(lrot,:)];
    rFR = [rFR;fr(rrot,:)];
    
    % firing rates(errors)
    frErr = singleTrials(pleft(ii)).fratesDetrend(hits == 0,:);
    rotations = singleTrials(pleft(ii)).rotations(hits == 0);
    lrot = ismember(rotations,A);
    rrot = ismember(rotations,-A);    
    lFRerr = [lFRerr;fr(lrot,:)];
    rFRerr = [rFRerr;fr(rrot,:)];
    
end
subplot(1,2,1)
% plot(ts,nanmean(lFRerr),'color',[0.8,0.8,1]); hold on
% plot(ts,nanmean(rFRerr),'color',[1,0.8,0.8])
plot(ts,lFR','color',[0.8,0.8,1]); hold on
plot(ts,rFR','color',[1,0.8,0.8])
plot(ts, nanmean(lFR),'b'); hold on
plot(ts, nanmean(rFR),'r')
title('Left Preference')

% FIRING RATES FOR RIGHT PREFERENCE NEURONS
lFR = [];
rFR = [];
lFRerr = [];
rFRerr = [];
for ii = 11:length(pright)
       
    % firing rates (hits)
    hits = singleTrials(pright(ii)).hits;
    fr = singleTrials(pright(ii)).fratesDetrend(hits == 1,:);
    rotations = singleTrials(pright(ii)).rotations(hits == 1);
    lrot = ismember(rotations,A);
    rrot = ismember(rotations,-A);
    lFR = [lFR;fr(lrot,:)];
    rFR = [rFR;fr(rrot,:)];
    
     % firing rates(errors)
    frErr = singleTrials(pright(ii)).fratesDetrend(hits == 0,:);
    rotations = singleTrials(pright(ii)).rotations(hits == 0);
    lrot = ismember(rotations,A);
    rrot = ismember(rotations,-A);    
    lFRerr = [lFRerr;fr(lrot,:)];
    rFRerr = [rFRerr;fr(rrot,:)];
end
subplot(1,2,2)
% plot(ts,nanmean(lFRerr),'color',[0.5,0.5,1]); hold on
% plot(ts,nanmean(rFRerr),'color',[1,0.8,0.8])
plot(ts,lFR','color',[0.8,0.8,1]); hold on
plot(ts,rFR','color',[1,0.8,0.8])
plot(ts, nanmean(lFR),'b'); hold on
plot(ts, nanmean(rFR),'r')
title('Right Preference')