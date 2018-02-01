clearvars -except singleTrials preference ids
close all
clc

% set rotation magnitudes
A = [.1,.2,.4,.8,1.6,3.2];
% A = [0.1,0.2,0.4];
% A = [0.8,1.6,3.2];
timeSec = -0.5:0.01:1;

% rotation preference vectors
pleft = find(preference == 1); 
pright = find(preference == -1);

% roc settings
alpha = 0.05;
bins = 10;

% LEFT PREFERENCE NEURONS
lROC = cell(1,length(A));
lLag = cell(1,length(A));
lCI = cell(1,length(A));
lrotROCE = cell(1,length(A));
lrotLagE = cell(1,length(A));
lrotCIE = cell(1,length(A));
rrotROCE = cell(1,length(A));
rrotLagE = cell(1,length(A));
rrotCIE = cell(1,length(A));
ID = {};
for p = 1:length(pleft)
   hits = singleTrials(pleft(p)).hits ;
   frH = singleTrials(pleft(p)).fratesDetrend(hits==1,:);
   rotations = singleTrials(pleft(p)).rotations(hits==1);
   
   frE = singleTrials(pleft(p)).fratesDetrend(hits==0,:);
   rotationsE = singleTrials(pleft(p)).rotations(hits==0);
   
   for a = 1:length(A)
       % Hits
       lrot = ismember(rotations,A(a));
       rrot = ismember(rotations,-A(a));
       lfr = frH(lrot,:);
       rfr = frH(rrot,:);
       [roc,ci,lag] = rocindex(lfr, rfr,'alpha',alpha,'numOfConsBins',bins);
       if length(roc) == length(timeSec);
           lROC{a} = [lROC{a}; roc];   
           if isempty(lag); lag = nan;end
           lLag{a} = [lLag{a},lag];
           lCI{a} = [lCI{a};ci];
       end
       
       % left hits vs left errors
       lrotE = ismember(rotationsE,A(a));
       lfrE = frE(lrotE,:);
       [lrocE,lci,llagE] = rocindex(lfr, lfrE,'alpha',alpha,'numOfConsBins',bins);
       if length(lrocE) == length(timeSec);
           lrotROCE{a} = [lrotROCE{a}; lrocE];  
           if isempty(llagE); llagE = nan;end
           lrotLagE{a} = [lrotLagE{a};llagE];
           lrotCIE{a} = [lrotCIE{a};lci];
       end
       
       % right hits vs right errors
       rrotE = ismember(rotationsE,-A(a));
       rfrE = frE(rrotE,:);
       [rrocE,rci,rlagE] = rocindex(rfr, rfrE,'alpha',alpha,'numOfConsBins',bins);
       if length(rrocE) == length(timeSec);
           rrotROCE{a} = [rrotROCE{a}; rrocE];   
           if isempty(rlagE); rlagE = nan;end
           rrotLagE{a} = [rrotLagE{a};rlagE];
           rrotCIE{a} = [rrotCIE{a};rci];
       end
   end
   ID{p} = ids{pleft(p)};
   inlist(p) = pleft(p);
end

ROC.leftPreference.leftVSright = struct('index',lROC,'lags',lLag,'ci',lCI);
ROC.leftPreference.leftHitsVSleftErr = struct('index',lrotROCE,'lags',lrotLagE,'ci',lrotCIE);
ROC.leftPreference.rightHitsVSrightErr = struct('index',rrotROCE,'lags',rrotLagE,'ci',rrotCIE);
ROC.leftPreference.ids = ID;
ROC.leftPreference.inlist = inlist;
% RIGHT PREFERENCE NEURONS
rROC = cell(1,length(A));
rLag = cell(1,length(A));
rCI = cell(1,length(A));
lrotROCE = cell(1,length(A));
lrotLagE = cell(1,length(A));
lrotCIE = cell(1,length(A));
rrotROCE = cell(1,length(A));
rrotLagE = cell(1,length(A));
rrotCIE = cell(1,length(A));
ID = {};
inlist = [];
for p = 1:length(pright)
   hits = singleTrials(pright(p)).hits ;
   frH = singleTrials(pright(p)).fratesDetrend(hits==1,:);
   rotations = singleTrials(pright(p)).rotations(hits==1);
   
   frE = singleTrials(pright(p)).fratesDetrend(hits==0,:);
   rotationsE = singleTrials(pright(p)).rotations(hits==0);
   
   for a = 1:length(A);
       % left hits vs right hits
       lrot = ismember(rotations,A(a));
       rrot = ismember(rotations,-A(a));
       lfr = frH(lrot,:);
       rfr = frH(rrot,:);
       [roc,ci,lag] = rocindex(lfr, rfr,'alpha',alpha,'numOfConsBins',bins);
       if length(roc) == length(timeSec);
           rROC{a} = [rROC{a}; roc];
           if isempty(lag); lag = nan;end
           rLag{a} = [rLag{a},lag];
           rCI{a} = [rCI{a};ci];
       end
       
       % left hits vs left errors
       lrotE = ismember(rotationsE,A(a));
       lfrE = frE(lrotE,:);
       [lrocE,lci,llagE] = rocindex(lfr, lfrE,'alpha',alpha,'numOfConsBins',bins);
       if length(lrocE) == length(timeSec);
           lrotROCE{a} = [lrotROCE{a}; lrocE];
           if isempty(llagE); llagE = nan;end
           lrotLagE{a} = [lrotLagE{a},llagE];
           lrotCIE{a} = [lrotCIE{a};lci];
       end
       
       % right hits vs right errors
       rrotE = ismember(rotationsE,-A(a));
       rfrE = frE(rrotE,:);
       [rrocE,rci,rlagE] = rocindex(rfr, rfrE,'alpha',alpha,'numOfConsBins',bins);
       if length(rrocE) == length(timeSec);
           rrotROCE{a} = [rrotROCE{a}; rrocE];
           if isempty(rlagE); rlagE = nan;end
           rrotLagE{a} = [rrotLagE{a},rlagE];
           rrotCIE{a} = [rrotCIE{a};rci];
       end
   end
   ID{p} = ids{pright(p)};
   inlist(p) = pright(p);
end
ROC.rightPreference.leftVSright = struct('index',rROC,'lags',rLag,'ci',rCI);
ROC.rightPreference.leftHitsVSleftErr = struct('index',lrotROCE,'lags',lrotLagE,'ci',lrotCIE);
ROC.rightPreference.rightHitsVSrightErr = struct('index',rrotROCE,'lags',rrotLagE,'ci',rrotCIE);
ROC.rightPreference.ids = ID;
ROC.rightPreference.inlist = inlist;

%%

subindex = [1:length(A); length(A)+1:length(A)*2];
for s = 1:length(A)
subplot(2,length(A/2),subindex(1,s))
plot(timeSec,lROC{s}','color',[0.8,0.8,1]); hold on
plot(timeSec,nanmean(lROC{s}),'color','b','linewidth',2)
set(gca, 'ylim',[0,1],'xlim',[timeSec(1),timeSec(end)],'box','off')
title(num2str(A(s)))
% axis square

subplot(2,length(A/2),subindex(2,s))
plot(timeSec,rROC{s}','color',[1,0.8,0.8]); hold on
plot(timeSec, nanmean(rROC{s}),'r','linewidth',2); 
set(gca, 'ylim',[0,1],'xlim',[timeSec(1),timeSec(end)],'box','off')
title(num2str(-A(s)))
% axis square
end
