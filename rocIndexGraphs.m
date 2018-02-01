% clear all
close all
clc

load 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\rocStep10Tau500'
lhits = {ROC.leftPreference.leftVSright.index};
lerrs = {ROC.rightPreference.leftHitsVSleftErr.index};
rhits = {ROC.rightPreference.leftVSright.index};
rerrs = {ROC.rightPreference.rightHitsVSrightErr.index};

% set rotation magnitudes
A = [0.1,0.2,0.4,0.8,1.6,3.2];
% A = [0.1,0.2,0.4];
% A = [0.8,1.6,3.2];
lenA = length(A);
timeSec = -0.5:0.001:1;
timeSec = -0.5:0.01:1;

glevel = linspace(0.2,0.8,lenA);
b = [zeros(lenA,1), glevel', ones(lenA,1)];
r = [ones(lenA,1), glevel', zeros(lenA,1)];
g = [zeros(lenA,1), glevel', zeros(lenA,1)];


% subplot(1,2,1)

for a = 1:length(A)
    plot(timeSec,nanmean(lhits{a}), 'color', b(a,:),'linewidth',2); hold on
    plot(timeSec,nanmean(rhits{a}), 'color', r(a,:),'linewidth',2); hold on
end
set(gca,'ylim',[0,1],'box','off')
xlabel('Time from stimulus onset'), ylabel('ROC index')
axis square
shg
% title('Hits')
% subplot(1,2,2)
% 
% for a = 1:3
%     plot(timeSec,nanmean(lerrs{a}), 'color', b(a,:),'linewidth',2); hold on
%     plot(timeSec,nanmean(rerrs{a}), 'color', r(a,:),'linewidth',2); hold on
% end
% set(gca,'ylim',[0,1])
% title('Left Preference Neurons (hits vs err for 0.1, 0.2, and 0.4 rotations)')
% legend('left hits vs left err', 'right hits vs right err' )