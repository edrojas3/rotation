% load C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\classification
matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';

pref = cell2mat(classif(:,11));
stim = cell2mat(classif(:,7));
izq = stim(:,1);
der = stim(:,2);

rpref = find(izq < 1 & der == 1);
lpref = find(izq == 1 & der < 1);
stimpref = find(izq == 1 & der == 1);

alignEvent = 'robMovIni';
endEvent = 'robMovFin';
blEvent = 'touchIni';

samples = -1:0.01:1;
time_axis = samples;
tau = 0.1;

%%
index = stimpref(verifstim== 1);
left_norm = zeros(length(index),length(samples));
right_norm = zeros(length(index),length(samples));
for i = 1:length(index);
    id = classif{index(i),1};
    spk = classif{index(i),2};
    
    load([matfiles, '\', id])
    if isfield(e.slice, spk);
        slice = e.slice.(spk);
    else
        continue
    end
    e = eslice(e, slice);
  
%     bl_aligned = selectTrials(e, 'alignEvent',blEvent, 'delnotfound', 1);
%     bl_spks = {bl_aligned.spikes.(spk)};
%     bl_attrit = [zeros(length(bl_spks),1), 0.3*ones(length(bl_spks),1)];
%     bl_frate = firingrate(bl_spks, samples, 'FilterType', 'boxcar', 'TimeConstant', tau);
%     bl_mean = nanmean(bl_frate(:));
%     bl_std = std( bl_frate(~( isnan(bl_frate) ) == 1) );
    
    aligned = selectTrials(e, 'alignEvent', alignEvent, 'delnotfound', 1);
    spks = {aligned.spikes.(spk)};
    lefts = [aligned.events.anguloRotacion] > 0;
    left_attrit = [[aligned.events(lefts == 1).(alignEvent)]'-1, [aligned.events(lefts == 1).(endEvent)]'+1];
    left_frate = firingrate({spks{lefts == 1}}, samples, 'FilterType', 'exponential', 'attrit', left_attrit, 'TimeConstant', tau);
    left_mean = nanmean(left_frate);
    left_norm(i,:) = (left_mean - nanmean(left_mean(1:101))) / std(left_mean(isnan(left_mean(1:101)) == 0));
%     left_norm(i,:) = (left_mean - bl_mean) / bl_std;


    right_attrit = [[aligned.events(lefts == 0).(alignEvent)]'-1, [aligned.events(lefts == 0).(endEvent)]'+1];
    right_frate = firingrate({spks{lefts == 0}}, samples, 'FilterType', 'exponential', 'attrit', right_attrit, 'TimeConstant', tau);
    right_mean = nanmean(right_frate);
    right_norm(i,:) = (right_mean - nanmean(right_mean(51:101))) / std(right_mean(isnan(right_mean(51:101)) == 0));
%     right_norm(i,:) = (right_mean - bl_mean) / bl_std;
   
end
%
clf
plot(samples,left_norm, 'color', [0.8,0.8,1]); hold on
plot(samples,right_norm, 'color', [1,0.8,0.8]); 
plot(samples, nanmean(left_norm), 'b', 'linewidth',3); 
plot(samples, nanmean(right_norm), 'r', 'linewidth',3)
set(gca, 'xlim', [-0.1,0.5])
axis square
xlabel('Time from stimulus onset (s)', 'fontsize',20);
ylabel('Normalized firing rate', 'fontsize', 20)
title('Stimulus sensitive (n = 39)', 'fontsize', 20)

%%
saveas(gca, 'C:\Users\eduardo\Documents\proyectos\rotacion\frates\stim_sensitive.png')