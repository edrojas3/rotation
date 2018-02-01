% Initial settings: set directories and database
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
dewey = [matdir,'\dewey'];
cesar = [matdir, '\cesar'];
[~,~,trial_database] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\selected_trials.xls');
trial_database(1,:) = [];
% savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\rasters\alleventraster_stimExpanded';
linesize = 0.25;

% Raster plot from id's in database
for f = 1:size(trial_database,1)
    disp(['file: ', num2str(f), '/', num2str(size(trial_database,1))])
    % Select monkey directory from filename
%     if trial_database{f,1}(1) == 'c'
%         filedir = cesar;
%     else
%         filedir = dewey;
%     end
    
    % Check for multiunit files, existence in directory and load
    if length(trial_database{f,1}) > 11;
%         matfile = [filedir,'\',trial_database{f,1}(1:end-1)];
        matfile = [matdir,'\',trial_database{f,1}(1:end-1)];
    else
%         matfile = [filedir,'\',trial_database{f,1}];
        matfile = [matdir,'\',trial_database{f,1}];

    end
    
    disp('loading...')
    if exist([matfile,'.mat'],'file')
        load(matfile)
    else
        continue
    end
    
    % Spike units
    spike_id = trial_database{f,2};
    
    % Select good trials
    disp('slicing...')
    ntrials = trial_database{f,3};
    slicing_true = trial_database{f,4};
    if slicing_true;
        slicing = ones(1,ntrials);
    else
        selection = trial_database{f,5};
        slicing = getSlicing(ntrials, selection);
    end
    e.slice.(spike_id) = slicing(:);

%     if length(e.trial) < 50; continue;end
    save([savedir, '\', trial_database{f,1}], 'e')
   
end
