function selected = selectTrials(e,varargin)
% Select trials with specific features and align the time stamps to a
% specific event.
%
% USAGE: selected = selectTrials(e, varargin)
%
%   Input arguments:
%      e: structure with trial information
%      varargin: can be one or more of the following strings
%               'initialAngle' 
%               'rotationAngle'
%               'targAngle'
%               'choice'
%               'correct'
%               'velocity'
%               'alignEvent'
%               'rotDir' % -1 for right rotations, 1 for left rotations.
%               'hits' % 0 para errors, 1 hits
%       The string that you use as an argument must be followed by a number
%       except alignEvent that must be followed by the string of the event
%       you want to align all the other events.
%   
%  Outputs:
%       selected: struct array with the features you selected.
%
%EJEMPLO: selected = selctTrials(e, 'initialAngle', -4, 'rotationAngle', 16, 'alignEvent', 'touchStart')


%%
delnotfound = getArgumentValue('delnotfound', 1, varargin{:});


trials = e.trial;

if isfield(e,'spikes');
    spike_events = e.spikes;
else
    spikes = nan;
end

ai = ones(length(trials),1);    % initial angle
ar = ones(length(trials),1);    % rotation angle
at = ones(length(trials),1);    % choice target angle
resp = ones(length(trials),1);  % monkey's choice
vr = ones(length(trials),1);    % hits (1) or error(0)
vel = ones(length(trials),1);   % velocity of rotation
rotdir = ones(length(trials),1);   % direction of rotation
aciertos = ones(length(trials),1); % hits or errors

% Vectores lógicos de los ensayos que tienen lo que quieres
for i = 1:2:length(varargin)
    
   campo = varargin{i};
   val = varargin{i+1};
   switch campo
       case 'initialAngle' 
           ai = [trials.initialAngle]' == val;
       case 'rotationAngle'
           ar = [trials.rotationAngle]' ;
           ar = round(ar*10);
           ar = ar == round(val*10);
       case 'targAngle'
           at = [trials.tarAng]' == val;
       case 'choice'
           resp = [trials.choice]' == val;
       case 'choiceVal'
           vr = [trials.correct]' == val;
       case 'velocity'
           vel = [trials.velocity]' == val;
       case 'hits'
           aciertos = [trials.correct]' == val;
       case 'rotDir'
           if val > 0;
                rotdir = [trials.rotationAngle]' > 0;
           elseif val < 0;
                rotdir = [trials.rotationAngle]' < 0;
           end
       otherwise
           continue
   end
   
end

% Logic vector to filter trials
filter = ai.*ar.*at.*resp.*vr.*vel.*rotdir.*aciertos;
events = trials(filter == 1);

if isfield(e,'spikes');
    spikes = spike_events(filter == 1);
end

% Align Events
alignEvent  = getArgumentValue('alignEvent','noAlign',varargin{:});
del = [];
if ~(strcmp(alignEvent, 'noAlign'));
    for n = 1:length(events)
        if isfield(events, 'robMovStart');
            if isempty(events(n).robMovStart); disp(['No info found in trial ', num2str(n)]); del(n) = n; continue; end
        end
        alignTime = events(n).(alignEvent);
        events(n).waitCueStart      = events(n).waitCueStart - alignTime;
        events(n).handFixStart      = events(n).handFixStart - alignTime;
        events(n).waitCueEnd        = events(n).waitCueEnd - alignTime;
        events(n).touchCueStart     = events(n).touchCueStart - alignTime;
        events(n).handFixEnd        = events(n).handFixEnd - alignTime;
        events(n).touchStart        = events(n).touchStart - alignTime;
        events(n).cmdStim           = events(n).cmdStim - alignTime;
        events(n).movStart          = events(n).movStart - alignTime;
        events(n).movEnd            = events(n).movEnd - alignTime;
        events(n).stimEnd           = events(n).stimEnd - alignTime;
        events(n).touchCueEnd       = events(n).touchCueEnd - alignTime;
        events(n).touchEnd          = events(n).touchStart - alignTime;
        events(n).waitRespStart     = events(n).waitRespStart - alignTime;
        events(n).targOn            = events(n).targOn - alignTime;
        events(n).waitRespEnd       = events(n).waitRespEnd - alignTime;
        events(n).targOff           = events(n).targOff - alignTime;
        events(n).robTimeSec        = events(n).robTimeSec - alignTime;
        events(n).digitalInfo(:,1)  = events(n).digitalInfo(:,1) - alignTime;
        if isfield(events, 'robMovIni');
            events(n).robMovStart        = events(n).robMovStart - alignTime;
            events(n).robMovEnd        = events(n).robMovEnd - alignTime;
        end
        if isfield(events, 'lfpTime');
            events(n).lfpTime = events(n).lfpTime - alignTime;
        end
        if isfield(e,'spikes');
            spike_name = fieldnames(spike_events);
            for s = 1:length(spike_name);
               spikes(n).(spike_name{s})   = spikes(n).(spike_name{s}) - alignTime;
            end
        end
        
    end
    

end
if ~isempty(del) && delnotfound
    events(del > 0) = [];
    spikes(del > 0) = [];
end
selected = struct('events',events,...
                   'spikes',spikes);
