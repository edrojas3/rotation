function [slicing, index] = getGoodTrials(id, spike)
% [slicing, index] = getGoodTrials(id, spike);
% slicing = a logic vector with ones indicating the selected trials
% index = row in the database corresponding to the id and spike
% id = file id
% spike = spike num
%
% Searches for the row in the database that has the information about the
% selected trials for the spike unit in the id file.

[~,~,trial_database] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\selected_trials.xls');
trial_database(1,:) = [];

found = 0;
index = 0;
while ~found
    index = index + 1;
    if length(trial_database{index,1}) > 11;
        id_database = trial_database{index,1}(1:end-1);
    else
        id_database = trial_database{index,1};
    end
    
    spike_database = trial_database{index,2};
   
   found = strcmp(id, id_database) && strcmp(spike, spike_database) ;
end

ntrials = trial_database{index,3};
slicing_true = trial_database{index,4};
if slicing_true;
    slicing = ones(1,ntrials);
else
    selection = trial_database{index,5};
    slicing = getSlicing(ntrials, selection);
end