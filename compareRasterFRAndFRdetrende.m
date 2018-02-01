clearvars -except singleTrials preference
close all
clc

A = [0.8,1.6,3.2];
timeSec = -.5:.01:1;
pleft = find(preference == 1);
pright = find(preference == -1);
pindex = find(preference == 1);
idleft = singleTrials(pleft).id;
idright = singleTrials(pright).id;

lFR = [];
rFR = [];
lFRD = [];
rFRD = [];
for ii = 11:length(pindex)
    
    %raster
    showRaster(singleTrials(pindex(ii)).id);
    
    % firing rates
    frates = singleTrials(pindex(ii)).frates;
    rotations = singleTrials(pindex(ii)).rotations;
    lrot = ismember(rotations,A);
    rrot = ismember(rotations,-A);
%     lFR = [lFR;frates(lrot,:)];
%     rFR = [rFR;frates(rrot,:)];
    lFR = frates(lrot,:);
    rFR = frates(rrot,:);
    figure
    subplot(1,2,1)
%     plot(lFR','color',[0.5,0.5,1]); hold on
%     plot(rFR','color',[1,0.5,0.5])
    plot(timeSec,nanmean(lFR), 'b','linewidth',2); hold on
    plot(timeSec,nanmean(rFR), 'r','linewidth',2)
    
    % firing rates detrended
    frDet = singleTrials(pindex(ii)).fratesDetrendNorm;
%     lFRD = [lFRD;frDet(lrot,:)];
%     rFRD = [rFRD;frDet(rrot,:)];
    lFRD = frDet(lrot,:);
    rFRD = frDet(rrot,:);
   subplot(1,2,2)
%     plot(lFRD','color',[0.5,0.5,1]); hold on
%     plot(rFRD','color',[1,0.5,0.5])
    plot(timeSec,nanmean(lFRD), 'b','linewidth',2); hold on
    plot(timeSec,nanmean(rFRD), 'r','linewidth',2)
    
    pause
    close all
end