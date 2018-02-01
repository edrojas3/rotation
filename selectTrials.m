function selected = selectTrials(e,varargin)
% Selecciona los ensayos dependiendo de las variables de la tarea.
% USO: selected = selectTrials(e, varargin)
%
%   Argumentos de entrada:
%      e: estructura con campos que tienen la
%      informacion del ensayo.
%      varargin: puede ser uno o más de los siguientes strings:
%               'anguloInicio' 
%               'anguloRotacion'
%               'anguloTarg'
%               'respMono'
%               'valResp'
%               'velocidad'
%               'alignEvent'
%               'rotDir' % -1 para rotaciones a la derecha, 1 para
            %               rotaciones a la izquierda.
%               'aciertos' % 0 para errores, 1 para aciertos
%        El string tiene que ser seguido por un número, excepto
%        'alignEvent' que tiene que ser seguido por el string del evento
%        al cual quieres alinear la tarea. Si omites 'alignEvent' de los
%        argumentos de entrada la tarea no se va a alinear.
%   
%   Argumentos de salida
%       selected: estructura con los ensayos que tienen las condiciones
%       que especificaste.
%
%EJEMPLO: selected = selctTrials(e, 'anguloInicio', -4, 'anguloRotacion', 16, 'alignEvent', 'touchIni')
%
%En el caso del ejemplo la estructura selected debe de tener sólo
%los ensayos en los que el objeto comenzó 4 grados a la derecha, rotó
%16 grados a la izquierda, y la información temporal va a estar
%alineada al momento en el que el mono toca el objeto.

%%
delnotfound = getArgumentValue('delnotfound', 1, varargin{:});

% Condiciones por las cuales se pueden filtrar los datos

trials = e.trial;

if isfield(e,'spikes');
    spike_events = e.spikes;
else
    spikes = nan;
end

ai = ones(length(trials),1);    % angulo inicial
ar = ones(length(trials),1);    % angulo de rotacion
at = ones(length(trials),1);    % angulo de objetivos
resp = ones(length(trials),1);  % respuesta del mono
vr = ones(length(trials),1);    % respuesta correcta (1) o incorrecta(0)
vel = ones(length(trials),1);   % velocidad
rotdir = ones(length(trials),1);   % direccion de rotacion
aciertos = ones(length(trials),1);

% Vectores lógicos de los ensayos que tienen lo que quieres
for i = 1:2:length(varargin)
    
   campo = varargin{i};
   val = varargin{i+1};
   switch campo
       case 'anguloInicio' 
           ai = [trials.anguloInicio]' == val;
       case 'anguloRotacion'
           ar = [trials.anguloRotacion]' ;
           ar = round(ar*10);
           ar = ar == round(val*10);
       case 'anguloTarg'
           at = [trials.angTar]' == val;
       case 'respMono'
           resp = [trials.respMono]' == val;
       case 'valResp'
           vr = [trials.valResp]' == val;
       case 'velocidad'
           vel = [trials.velocidad]' == val;
       case 'aciertos'
           aciertos = [trials.correcto]' == val;
       case 'rotDir'
           if val > 0;
                rotdir = [trials.anguloRotacion]' > 0;
           elseif val < 0;
                rotdir = [trials.anguloRotacion]' < 0;
           end
       otherwise
           continue
   end
   
end

% Operacion lógica AND para obtener un vector lógico con los índices de los
% ensayos que tienen lo que quieres
filter = ai.*ar.*at.*resp.*vr.*vel.*rotdir.*aciertos;

% Filtrar los ensayos
events = trials(filter == 1);

if isfield(e,'spikes');
    spikes = spike_events(filter == 1);
end
% Alinear los tiempos a un evento
alignEvent  = getArgumentValue('alignEvent','noAlign',varargin{:});
del = [];
if ~(strcmp(alignEvent, 'noAlign'));
    for n = 1:length(events)
        if isfield(events, 'robMovIni');
            if isempty(events(n).robMovIni); disp(['No info found in trial ', num2str(n)]); del(n) = n; continue; end
        end
        alignTime = events(n).(alignEvent);
        events(n).cmdIni            = events(n).cmdIni - alignTime;
        events(n).manosFijasIni     = events(n).manosFijasIni - alignTime;
        events(n).manosFijasFin     = events(n).manosFijasFin - alignTime;
        events(n).waitCueIni        = events(n).waitCueIni - alignTime;
        events(n).waitCueFin        = events(n).waitCueFin - alignTime;
        events(n).touchIni          = events(n).touchIni - alignTime;
        events(n).touchFin          = events(n).touchFin - alignTime;
        events(n).touchCueIni       = events(n).touchCueIni - alignTime;
        events(n).touchCueFin       = events(n).touchCueFin - alignTime;
        events(n).waitRespIni       = events(n).waitRespIni - alignTime;
        events(n).waitRespFin       = events(n).waitRespFin - alignTime;
        events(n).targOn            = events(n).targOn - alignTime;
        events(n).targOff           = events(n).targOff - alignTime;
        events(n).cmdStim           = events(n).cmdStim - alignTime;
        events(n).movIni            = events(n).movIni - alignTime;
        events(n).stimFin           = events(n).stimFin - alignTime;
        events(n).movFin            = events(n).movFin - alignTime;
        events(n).robTimeSec        = events(n).robTimeSec - alignTime;
        events(n).digitalInfo(:,1)  = events(n).digitalInfo(:,1) - alignTime;
        if isfield(events, 'robMovIni');
            events(n).robMovIni        = events(n).robMovIni - alignTime;
            events(n).robMovFin        = events(n).robMovFin - alignTime;
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