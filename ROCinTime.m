function ROC = ROCinTime(singleTrials,varargin)
%
% ROCinTime() is a function that stores the rocindex values in a structure.
% The function calculates the roc index values for clockwise and counter clockwise rotations of the
% same magnitude , the confidence intervals of each time sample, and in which sample the index is
% statisticaly significant.
%
% roc = rocintime(singleTrials)
% singleTrials = structure with single trials firing rate of each neuron.
% For more details see singleTrialsFR function.
% 
% For more details about the calculation of the roc index see the rocindex
% function.

% set rotation magnitudes
A = getArgumentValue('angles',[.1,.2,.4,.8,1.6,3.2],varargin{:});

% roc settings
alpha = getArgumentValue('alpha',0.05,varargin{:});
bins = getArgumentValue('bins',10,varargin{:});
timeSec = singleTrials.timeSec;

% variable prealocation
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

for s = 1:length(singleTrials)
   hits = singleTrials(s).hits ;
   frH = singleTrials(s).fratesDetrend(hits==1,:);
   rotations = singleTrials(s).rotations(hits==1);
   
   frE = singleTrials(s).fratesDetrend(hits==0,:);
   rotationsE = singleTrials(s).rotations(hits==0);
   
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
   ID{s} = singleTrials(s).id;
end

ROC.leftVSright = struct('index',lROC,'lags',lLag,'ci',lCI);
ROC.leftHitsVSleftErr = struct('index',lrotROCE,'lags',lrotLagE,'ci',lrotCIE);
ROC.rightHitsVSrightErr = struct('index',rrotROCE,'lags',rrotLagE,'ci',rrotCIE);
ROC.ids = ID;
ROC.timeSec = timeSec;

