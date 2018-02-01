id = 'd1606081016';
spike_id = 'spike11';
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles';
dewey = [matdir,'\dewey'];
cesar = [matdir, '\cesar'];
[~,~,trial_database] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\selected_trials.xls');
trial_database(1,:) = [];
linesize = 0.5;
  
% Select monkey directory from filename
found = 0;
f = 1;
while ~found
    database_id = trial_database{f,1};
    if length(database_id) > 11;
        database_id = database_id(1:end-1);
    end
    if strcmp(id, database_id) && strcmp(spike_id, trial_database{f,2});
        found = 1;
    else
        f = f + 1;
    end
end

if trial_database{f,1}(1) == 'c'
    filedir = cesar;
else
    filedir = dewey;
end

load([filedir, '\', id])

% Select good trials
ntrials = trial_database{f,3};
slicing_true = trial_database{f,4};
if slicing_true;
    slicing = ones(1,ntrials);
else
    selection = trial_database{f,5};
    slicing = getSlicing(ntrials, selection);
end
e = eslice(e,slicing);

% Spike times and raster
alignEvent = {'movIni', 'movFin'};


angulos = [e.trial.anguloRotacion];
[angulos_sorted, index] = sort(angulos);
angulos_der = [angulos_sorted(angulos_sorted < 0)', index(angulos_sorted < 0)'];
angulos_der_sorted = sortrows(abs(angulos_der), 1);
angulos_izq = [angulos_sorted(angulos_sorted > 0)', index(angulos_sorted > 0)'];
sorted_trials = [angulos_der_sorted(:,2); angulos_izq(:,2)];
n_der = size(angulos_der,1);

xticks = cell(8,1);
yticks = xticks;
start_xmarkers = xticks;
start_ymarkers = xticks;
end_xmarkers = xticks;
end_ymarkers = xticks;

c = 1;
for ae = 1:length(alignEvent)-1
    if ae == 6; continue; end
    aligned = selectTrials(e,'alignEvent',alignEvent{ae});
    end_marker = max([aligned.events.(alignEvent{ae+1})]);
    xlim = [-0.3, end_marker+0.3];
    samples = xlim(1):.01:xlim(2);
    [xticks{c}, yticks{c}] = rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
            'xlim',xlim,...
            'color','k');
    [start_xmarkers{c}, start_ymarkers{c}] = getmarkers(aligned.events, sorted_trials, alignEvent{ae});
    [end_xmarkers{c}, end_ymarkers{c}] = getmarkers(aligned.events, sorted_trials, alignEvent{ae+1});
    c = c+1;
end

maxtime = 0;
r = size(xticks{1},1);
c = size(xticks{1},2);
Xticks = [];
Yticks = Xticks;
Xmarkers_start = Xticks;

Xmarkers_end = Xticks;
Ymarkers_start = Xticks;
Ymarkers_end = Xticks;

for i = 1:size(xticks,1)
   Xticks = [Xticks,cell2mat(xticks(i)) + maxtime];
   Yticks = [Yticks,cell2mat(yticks(i))];
   Xmarkers_start = [Xmarkers_start; cell2mat(start_xmarkers(i)) + maxtime];
   Xmarkers_end = [Xmarkers_end; cell2mat(end_xmarkers(i)) + maxtime];
   Ymarkers_start = [Ymarkers_start; cell2mat(start_ymarkers(i))'];
   Ymarkers_end = [Ymarkers_end; cell2mat(end_ymarkers(i))'];
   maxtime = max(max(xticks{i}) + maxtime + 0.5);
end

line(Xticks, Yticks,'color', 'k'); hold on
plot(Xmarkers_start, Ymarkers_start, '.g')
plot(Xmarkers_end, Ymarkers_end, '.r')

% set(gca,'xlim',[-0.3, maxtime], 'ylim',[1,length(e.trial)+1])
title([trial_database{f,1},' ', spike_id])

