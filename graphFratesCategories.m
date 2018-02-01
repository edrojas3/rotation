clear all; close all; clc


pref = -1;

if pref == -1
    preference = 'right';
elseif pref == 1;
    preference = 'left';
end
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification';
load([matdir, '\',preference,'Preference'], 'left_detrend', 'left_err_detrend','right_detrend','right_err_detrend');


A = 1:6; %Todos los ángulos
% A = 1:3; % ángulos chicos
% A = 4:6; % ángulos grandes
left = left_detrend;
left_err = left_err_detrend;
right = right_detrend;
right_err = right_err_detrend;
samples = -0.3:0.001:1;
glevel = linspace(0.2,0.9,6);
b = [zeros(6,1), glevel', ones(6,1)];
r = [ones(6,1), glevel', zeros(6,1)];
g = [zeros(6,1), glevel', zeros(6,1)];

for ang = 1:length(A)
    
    left_mean = nanmean(cell2mat(left(:,A(ang))));
    right_mean = nanmean(cell2mat(right(:,A(ang))));
    
    if size(cell2mat(left_err(:,A(ang))), 1) == 1;
        left_mean_err = cell2mat(left_err(:,A(ang)));
    else
        left_mean_err = nanmean(cell2mat(left_err(:,A(ang))));
    end
    
    if size(cell2mat(right_err(:,A(ang))),1) == 1;
        right_mean_err = cell2mat(right_err(:,A(ang)));
    else
        right_mean_err = nanmean(cell2mat(right_err(:,A(ang))));
    end
    
    subplot(1,2,1)
    plot(samples, left_mean, 'color', g(A(ang),:), 'linewidth',2); hold on
    plot(samples, left_mean_err,'--','color', g(A(ang),:), 'linewidth',2); 
    
    subplot(1,2,2)
    plot(samples, right_mean, 'color', g(A(ang),:),'linewidth',2); hold on
    plot(samples, right_mean_err,'--','color', g(A(ang),:), 'linewidth',2); 
    
    maxy(ang) = max([left_mean,left_mean_err,right_mean,right_mean_err]);
    miny(ang) = min([left_mean,left_mean_err,right_mean,right_mean_err]);
    
end

subplot(1,2,1)
set(gca,'xlim', [-0.3,1], 'ylim', [min(miny), max(maxy)])
line([0,0], ylim, 'color', 'k')
xlabel('Time from stimulus off set'); ylabel('Normalized firing rate')
title('Left Rotations')
% axis square

subplot(1,2,2)
set(gca,'xlim', [-0.3,1], 'ylim', [min(miny), max(maxy)])
line([0,0], ylim, 'color', 'k')
title('Right Rotations')
% axis square



