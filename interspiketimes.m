id = 'd1604270916';
spike_id = 'spike12';

file = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\dewey\', id, '.mat'];
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles';
dewey = [matdir,'\dewey'];
cesar = [matdir, '\cesar'];
linesize = 0.25;

    
% Select monkey directory from filename
if id(1) == 'c'
    filedir = cesar;
else
    filedir = dewey;
end

% Check for multiunit files, existence in directory and load
if length(id) > 11;
    matfile = [filedir,'\',id(1:end-1)];
else
    matfile = [filedir,'\',id];
end

slicing = getGoodTrials(id, spike_id);
load(matfile)
e = eslice(e,slicing);

% Spike times 
alignEvent = {'movIni', 'movFin'};
angulo = 3.2;



left_aligned = selectTrials(e,'alignEvent',alignEvent{1}, 'anguloRotacion', angulo);
left_end_marker = max([left_aligned.events.(alignEvent{2})]);
left_xlim = [-0.3, end_marker];
samples = left_xlim(1):.01:left_xlim(2);
[left_xticks, left_yticks] = rasterplot({left_aligned.spikes.(spike_id)},...
        'xlim',left_xlim,...
        'color','k');
left_spikes = left_xticks(1,:);
left_trials = round(left_yticks(1,:));

right_aligned = selectTrials(e,'alignEvent',alignEvent{1}, 'anguloRotacion', -angulo);
right_end_marker = max([right_aligned.events.(alignEvent{2})]);
right_xlim = [-0.3, end_marker];
samples = right_xlim(1):.01:right_xlim(2);
[right_xticks, right_yticks] = rasterplot({right_aligned.spikes.(spike_id)},...
        'xlim',right_xlim,...
        'color','k');
right_spikes = right_xticks(1,:);
right_trials = round(right_yticks(1,:));

left_prev_lat = [];
left_post_lat = [];
for n = 1:max(left_trials)
   index = find(left_trials == n) ;
   spkt = left_spikes(index);
   prev_index = spkt < 0;
   prev_lat = diff(sort( abs( spkt(prev_index == 1) )));
   left_prev_lat = [left_prev_lat, prev_lat];
   
   post_index = spkt > 0;
   post_lat = diff(spkt(post_index == 1));
   left_post_lat = [left_post_lat, post_lat];
   
end

right_prev_lat = [];
right_post_lat = [];
for n = 1:max(right_trials)
   index = find(right_trials == n) ;
   spkt = right_spikes(index);
   prev_index = spkt < 0;
   prev_lat = diff(sort( abs( spkt(prev_index == 1) )));
   right_prev_lat = [right_prev_lat, prev_lat];
   
   post_index = spkt > 0;
   post_lat = diff(spkt(post_index == 1));
   right_post_lat = [right_post_lat, post_lat];
   
end
