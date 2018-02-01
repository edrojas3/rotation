clear all; clc
[~,~,trial_database] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\selected_trials.xls');
trial_database(1,:) = [];

matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\rasters\alleventraster_stimExpanded';
for r = 965:size(trial_database,1)
    disp ([num2str(r), '/', num2str(size(trial_database,1))])
    id = trial_database{r,1};
    if length(id) > 11;
        id = id(1:end-1);
    end
    spike_id = trial_database{r,2};
    if exist([matfiles, '\', id, '.mat'], 'file');
        load([matfiles, '\', id])
    else
        continue
    end
    
    if ~( isfield(e.slice, spike_id) );
        ntrials = trial_database{r,3};
        slicing_true = trial_database{r,4};
        if slicing_true;
            slice = ones(1,ntrials);
        else
            selection = trial_database{r,5};
            e.slice.(spike_id) = getSlicing(ntrials, selection);
        end
        save(id, 'e')
    end
    
    % Raster plot from id's in database
    slicing = e.slice.(spike_id);
    
%     if length(slicing) ~= length(e.trial);
%         e = getSessionStruct(id);
%         e = addRobMarkers(e);
%     end
    
    e = eslice(e,slicing);
    if length(e.trial) < 50; continue; end
    alignEvents = {'manosFijasIni', 'touchCueIni', 'manosFijasFin', 'touchIni', 'robMarkIni', 'touchCueFin','touchFin', 'targOn'};
    endEvents = {{'touchCueIni'}, {'manosFijasFin'}, {'touchIni'},{'robMarkIni'},{'robMarkfin', 'touchFin'}, {'touchFin'}, {'targOn'},{'targOff'}};
    labels = {'Wait', 'Cue On', 'Reach', 'Contact', 'Stim On','Cue Off','Back','Tar On'};

    alleventsraster(e, spike_id, alignEvents, endEvents,labels);
    
    disp('saving...')
    savename = [savedir, '\', id, '_', spike_id, '.png'];
    saveas(gca, savename)
    disp('done...')
end