% clear all; clc

files = dir('C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns\*.png');
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\classification_struct.mat')

preference = -1;
prefindex = classif.stimulus.pref == preference;

files = files(prefindex == 1);

alignEvent = 'robMovIni';
rotationTimes = [0.064,0.084,0.110,0.154,0.292,0.546];

% A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = [0.1,0.2,0.4];
% A = [0.8,1.6,3.2];

angulos_esperados = [-A, A];

samples = -0.3:0.001:1;
tau = 0.05;

normindex = find(samples <= 0);

glevel = linspace(0.2,0.9,6);
b = [zeros(6,1), glevel', ones(6,1)];
r = [ones(6,1), glevel', zeros(6,1)];
g = [zeros(6,1), glevel', zeros(6,1)];

left = {};
right = {};
left_err = {};
right_err = {};
left_counter = 0;
right_counter = 0;
left_counter_err = 0;
right_counter_err = 0;

%subplots
leftsubs = [1,2,3,7,8,9];
rightsubs = [4,5,6,10,11,12];

for f = 1:length(files)    
    id = files(f).name(1:11);
    spk = files(f).name(12:18);
    
    
    
    if exist([matdir, '\', id,'.mat']);
        load([matdir, '\', id])
    else
        disp([id, ' not found'])
        continue
    end
    
    if isfield(e.slice, spk);
        slice = e.slice.(spk);
    else
        continue
    end
    
    e = eslice(e, slice);
    aligned = selectTrials(e, 'alignEvent', alignEvent,'aciertos',1, 'delnotfound', 1);
    angulos = round([aligned.events.anguloRotacion]*10)/10;
    spks = {aligned.spikes.(spk)};
    
    aligned_err = selectTrials(e, 'alignEvent', alignEvent,'aciertos',0, 'delnotfound', 1);
    angulos_err = round([aligned_err.events.anguloRotacion]*10)/10;
    spks_err = {aligned_err.spikes.(spk)};
    
    left_counter = left_counter + 1;
    left_counter_err = left_counter_err + 1;
    right_counter = right_counter + 1;
    right_counter_err = right_counter_err + 1;
        
      
    for ang = 1:length(A)
        
        left_frates = firingrate({spks{angulos == A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', [-0.3, 1]);
        right_frates = firingrate({spks{angulos == -A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', [-0.3, 1 ]); 
        
        if ~(isempty(left_frates));
            if size(left_frates,1) == 1;
                left_mean = left_frates;
            else
                left_mean = nanmean(left_frates);
            end
            left_norm = (left_mean - mean(left_mean(normindex))) / std(left_mean(normindex));
            left{left_counter, ang} = left_norm;
        end
        
        if ~(isempty(right_frates));
            if size(right_frates,1) == 1;
                right_mean = right_frates;
            else
                right_mean = nanmean(right_frates);
            end
            right_norm = (right_mean - mean(right_mean(normindex))) / std(right_mean(normindex));
            right{right_counter, ang} = right_norm;
        end
        
       left_frates_err = firingrate({spks_err{angulos_err == A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', [-0.3, 1]);
       right_frates_err = firingrate({spks_err{angulos_err == -A(ang)}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau, 'attrit', [-0.3, 1]); 
        
        if ~(isempty(left_frates_err));
            if size(left_frates_err,1) == 1;
                left_mean_err = left_frates_err;
            else
                left_mean_err = nanmean(left_frates_err);
            end
            left_norm_err = (left_mean_err - mean(left_mean_err(normindex))) / std(left_mean_err(normindex));
        else           
            left_norm_err = nan(1,length(samples));
        end
        left_err{left_counter_err,ang} = left_norm_err;
        
        if ~(isempty(right_frates_err));
            if size(right_frates_err,1) == 1;
                right_mean_err = right_frates_err;
            else
                right_mean_err = nanmean(right_frates_err);
            end
            right_norm_err = (right_mean_err - mean(right_mean_err(normindex))) / std(right_mean_err(normindex));
        else
            right_norm_err = nan(1, length(samples));
        end
        right_err{right_counter_err,ang} = right_norm_err;
        
    end
    
      
   
end



%
close all
figure
hold on
for ang = 1:length(A)
    
    left_mean = nanmean(cell2mat(left(:,ang)));
    right_mean = nanmean(cell2mat(right(:,ang)));
    
    if size(cell2mat(left_err(:,ang)), 1) == 1;
        left_mean_err = cell2mat(left_err(:,ang));
    else
        left_mean_err = nanmean(cell2mat(left_err(:,ang)));
    end
    
    if size(cell2mat(right_err(:,ang)),1) == 1;
        right_mean_err = cell2mat(right_err(:,ang));
    else
        right_mean_err = nanmean(cell2mat(right_err(:,ang)));
    end
    
    subplot(1,2,1)
    plot(samples, left_mean, 'color', g(ang,:), 'linewidth',2); hold on
    plot(samples, left_mean_err,'color', r(ang,:), 'linewidth',2); 
    
    subplot(1,2,2)
    plot(samples, right_mean, 'color', g(ang,:),'linewidth',2); hold on
    plot(samples, right_mean_err,'color', r(ang,:), 'linewidth',2); 
    
    maxy(ang) = max([left_mean,left_mean_err,right_mean,right_mean_err]);
    miny(ang) = min([left_mean,left_mean_err,right_mean,right_mean_err]);
%     pause
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

% indexmat = [13,14,15;19,20,21;16,17,18;22,23,24];
% 
% for im = 1:size(indexmat,2)
%     subplot(4,6,indexmat(1,im))
%     plot(samples, cell2mat(left(:,im))', 'color', g(im,:))
%     set(gca,'xlim', [-0.3,1])
% 
%     subplot(4,6,indexmat(2,im))
%     plot(samples, cell2mat(left_err(:,im))', 'color', r(im,:))
%     set(gca,'xlim', [-0.3,1])
%     
%     subplot(4,6,indexmat(3,im))
%     plot(samples, cell2mat(right(:,im))', 'color', g(im,:))
%     set(gca,'xlim', [-0.3,1])
% 
%     subplot(4,6,indexmat(4,im))
%     plot(samples, cell2mat(right_err(:,im))', 'color', r(im,:))
%     set(gca,'xlim', [-0.3,1])
% 
% end

