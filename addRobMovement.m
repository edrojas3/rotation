function e = addRobMovement(e)
% Creates a template for the signal of each stimulus, identifies start and
% end points, sections it, and makes a trial by trial comparison of the
% template with the signal to identify when the stimulus starts and ends.
% Adds the information as robMovStart and robMovEnd in e.trial field.
%
%USAGE: e = addRobMovement(e)
%
% Calls functions:
% getRobMarkers
% submean
% scale01

A = [0.1,0.2,0.4,0.8,1.6,3.2];
angs = [-A,A];

D = [0.064,0.084,0.102,0.154,0.292,0.546];
durations = [D,D];
angles = round([e.trial.rotationAngle]*10)/10;
for a = 1:length(angs)
    % Signal per stimulus magnitude
    signals = reshape([e.trial(angles== angs(a)).robSignal],1000, sum(angles == angs(a))) ;
    signals = submean(scale01(signals)); 
    trial_index = find(angles == angs(a));

    % Align signals to first trial
    signals_aligned = zeros(size(signals));
    for ss = 1:size(signals,2)
        signals_aligned(:,ss) = alignSignal(signals(:,2), signals(:,ss), 'scaling', 1);
    end

    % Template (average signal) and start/end markers
    signals_mean = mean(signals_aligned,2); 
    markers = getRobMarkers(filtSant(filtSant(signals_mean)));
    template = signals_mean(markers(1):markers(2));
    lenTemplate = length(template);

    % Difference between signals and template
    lenSignal = size(signals,1);
    for ss = 1:size(signals,2)

        signal = scale01(signals(:,ss));
        t = zeros(size(template));
        differ = [];
        t = template;

        for d = 1:lenSignal - lenTemplate
           s = signal(d:d+lenTemplate-1); 
           differ(d) = mean(abs(t - s));
        end
        
        % Single trial start/end markers
        [markini, ini_indx] = min(differ);
        calcfin_indx = ini_indx + lenTemplate -1;
        fixedfin_indx = ini_indx + ((durations(a)*1000)/2);
        calculated_markers = [ini_indx, calcfin_indx];
        fixed_markers = [ini_indx, fixedfin_indx];

        % Add values to e struct
        e.trial(trial_index(ss)).robMovStart = e.trial(trial_index(ss)).robTimeSec(ini_indx);
        e.trial(trial_index(ss)).robMovEnd= e.trial(trial_index(ss)).robTimeSec(fixedfin_indx);
    end

end


