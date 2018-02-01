load 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\rocStep10Tau500'
%
timeSec = -.5:0.01:1;
leftLags = [ROC.leftPreference.leftVSright(6).lags];
rightLags= [ROC.rightPreference.leftVSright(6).lags];
%
clf
subplot(1,2,1)
hist(leftLags)
xticks = get(gca,'xtick');
xticks(xticks==0) = 1;
times = timeSec(xticks);
newxlabels = cell(length(xticks),1);
for x = 1:length(xticks)
    newxlabels{x} = num2str(times(x));
end
set(gca,'xticklabels',newxlabels)
xlabel('Lag times'); ylabel('Number of neurons')
title('Neurons with left preference')

subplot(1,2,2)
hist(rightLags)
xticks = get(gca,'xtick');
xticks(xticks==0) = 1;
times = timeSec(xticks);
newxlabels = cell(length(xticks),1);
for x = 1:length(xticks)
    newxlabels{x} = num2str(times(x));
end
set(gca,'xticklabels',newxlabels)
title('Neurons with right preference')
clc