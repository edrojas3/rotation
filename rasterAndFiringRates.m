%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS INICIALES %%%%%%%%%%%%
clear all
% Rutas de los archivos y cargar lista con spikes

% Apartir de lista de categorías
% categoria = 'memory_left'; %('memory_left', 'memory_right', 'prefboth','reach_down', 'reach_up', 'touch_down', 'touch_up')
% matdir = ['estructuras\', categoria];
% load(categoria)

% Apartir de estructura con clasificación de actividad por eventos
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\classification_struct')

files = [classif.id];
% files = dir([matdir, '\*.mat']);

% Alineaciones por raster y marcadores

% Todas las alineaciones
alignEvents = {'handFixStart','touchStart', 'robMovStart'};
endEvents = {{'handFixStart'},...
            {'touchCueStart','handFixEnd','robMovStart'},...
            {'robMovEnd', 'touchCueEnd', 'targOn', 'targOff'}};
labels = {'Wait', 'Contact', 'Stim On'};

% Límites de cada raster (el número de filas tiene que ser el mismo que
% número de alignEvents);
rasterlimits = [-0.5, 2;...
                -2, 0.8;...
                -0.3,0.3];

% Sólo alineado al estímulo
% alignEvents = {'robMovIni'};
% endEvents = {{'robMovFin','touchCueFin'}};
% labels = {'Stim ON'};

% Settings para la tasa de disparo
samples = -0.5:0.1:1; % Se reescribe dentro del loop para ajustar el final a cada alineación.
samp_index = find(samples >= -0.5 & samples < 0.6);
tau = 0.05;

% Variables útiles para las gráficas
minrate = []; 
maxrate = [];
praster = [0.13,0.23,0.775,0.7]; % tamaño del raster en la figura
prate = [0.13,0.05,0.775,0.17]; % tamaño de la gráfica de la tasa de disparo dentro de la figura
timestep = 1.3; % Separación de cada alineación en el raster

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
for f = 949:949%length(files)
    disp([num2str(f),'/',num2str(length(files))])
    % ID a partir de lista
%     eval(['id =', categoria,'{f}{1};']) ;
%     eval(['spk =', categoria, '{f}{2};']);
    
    % ID a partir de estructura
    id =  files{f}(1:11);
    spk = files{f}(12:end);
    
%     id = 'c1606011551';
%     spk = 'spike31';
    
    if exist([matdir, '\', id,'.mat'],'file')
        load([matdir, '\', id])
    else
        continue
    end
    
    % Quitar ensayos malos (que en el raster parezca que la neurona se fue o algo así)
    if isfield(e.slice, spk);
        slice = e.slice.(spk);
    else
        continue
    end
    e = eslice(e, slice);
    
    % Tiempos en los que inicia cada alineación en el raster. Necesario
    % para alinear la gráfica de tasa de disparo.
    subplot(2,1,1);
    maxtime = alleventsraster(e, spk,'anguloRotacion', {alignEvents{1:end}}, endEvents, labels,rasterlimits,1);
    maxtime = maxtime(1:length(alignEvents));
    rasterxlim = get(gca, 'xlim');
    % Crar subplots con dimensiones modificadas para que el raster se vea
    % más grande que la tasa de disparo.
%     subplot(2,1,1, 'position', praster);
    
    subplot(2,1,2);
    set(gca, 'position', prate)
    for ae = 1:length(alignEvents)
        
        % Alineación de los ensayos 
        aligned = selectTrials(e, 'alignEvent', alignEvents{ae},'aciertos',1, 'delnotfound', 0);
        spks = {aligned.spikes.(spk)};
        
        % Caluclar la mediana de la duración del evento de alineación para
        % usarla como valor máximo de las muestras en la función de tasa de
        % disparo
        end_median = median([aligned.events.(endEvents{ae}{end})]);
        if strcmp(alignEvents{ae},endEvents{ae})
            samples = rasterlimits(ae,1):0.01:rasterlimits(ae,2); 
        else
            samples = rasterlimits(ae,1):0.01:end_median+0.3;
        end
        
        % Tasa de disparo en función de la rotación del estímulo
        angulos = round([aligned.events.anguloRotacion]*10)/10;
        lefts = angulos > 0;
        left_frate = firingrate({spks{lefts == 1}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau);
        if size(left_frate,1) > 1
            left_mean = mean(left_frate);
        else
            left_mean = left_frate;
        end

        rights = angulos < 0;
        right_frate = firingrate({spks{rights == 1}}, samples, 'FilterType', 'exponential',  'TimeConstant', tau);
        if size(right_frate,1) > 1;
            right_mean = mean(right_frate);
        else
            right_mean = right_frate;
        end

% LÍNEAS DE CÓDIGO CUANDO QUIERAS CALCULAR LA TASA DE DISPARO EN FUNCIÓN DE
% LOS ÁNGULOS DE INICIO
%         nulls = angulos == 0;
%         null_frate = firingrate({spks{nulls == 1}}, samples, 'FilterType', 'exponential',  'TimeConstant', tau);
%         null_mean = mean(null_frate);
    
        % Graficar tasa de disparo para cada alineación
        time_axis = samples + maxtime(ae);
        plot(time_axis, left_mean, 'b', 'linewidth',2); hold on
        plot(time_axis, right_mean, 'r','linewidth',2)
%         plot(time_axis, null_mean, 'g', 'linewidth',2)
        
        % Máximos y mínimos de la tasa de disparo para ajustar el eje de
        % las oordenadas del plot.
        minrate(ae) = min([left_mean,right_mean]);
        maxrate(ae) = max([left_mean,right_mean]);
        
%         minrate(ae) = min([left_mean,right_mean, null_mean]);
%         maxrate(ae) = max([left_mean,right_mean, null_mean]);
    end   
    
    % Settings del subplot de tasa de disparo
    
    xlim = [-0.3,  max(time_axis - timestep)];
    ylim = [min(minrate), max(maxrate)];
    set(gca, 'xlim', rasterxlim, 'ylim', ylim, 'box', 'off','xtick', maxtime, 'xticklabel', zeros(length(maxtime),1))
    % Marcadores de los eventos de alineación 
    line([maxtime; maxtime], repmat(ylim',1,length(maxtime)), 'color', 'k', 'linewidth', 1.5)
    
    % Raster. Por algún motivo desaparece si lo grafico antes de la tasa
    % del código que calcula la tasa de disparo.
    subplot(2,1,1);
    set(gca, 'position', praster)
    alleventsraster(e, spk,'anguloRotacion', {alignEvents{1:end}}, endEvents, labels,rasterlimits,1);
    set(gca, 'xlim', rasterxlim)
    title([id,spk])
    
    % Guardar figura
%     saveas(gcf, ['C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns\', id, spk, '.png'])
%     pause
% 
%     clf
end
