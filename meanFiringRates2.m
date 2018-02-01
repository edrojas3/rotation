%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS INICIALES %%%%%%%%%%%%
% Rutas donde est�n los archivos
files = dir('C:\Users\eduardo\Documents\proyectos\rotacion\frates\categories\prefright\*.png');
matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';

% Alineaciones por raster y marcadores
alignEvents = {'manosFijasIni','touchIni', 'robMovIni'};
endEvents = {{'touchCueIni', 'manosFijasFin', 'touchIni'},...
            {'robMovIni'},...
            {'robMovFin', 'touchCueFin', 'targOn', 'targOff'}};
labels = {'Wait', 'Contact', 'Stim On'};

% alignEvents = {'robMovIni'};
% endEvents = {{'robMovFin','touchCueFin'}};
% labels = {'Stim ON'};

% Settings para la tasa de disparo
samples = -0.5:0.001:1; % Se reescribe dentro del loop para ajustar el final a cada alineaci�n.
samp_index = find(samples >= -0.5 & samples < 0.6);
tau = 0.05;

% Variables �tiles para las gr�ficas
minrate = []; 
maxrate = [];
praster = [0.13,0.23,0.775,0.7]; % tama�o del raster en la figura
prate = [0.13,0.05,0.775,0.17]; % tama�o de la gr�fica de la tasa de disparo dentro de la figura
timestep = 1.3; % Separaci�n de cada alineaci�n en el raster

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
for f = 1:1%length(files)
    
    id = files(f).name(1:11) ;
    spk = files(f).name(12:18);
     
    load([matfiles, '\', id])
    
    % Quitar ensayos malos (que en el raster parezca que la neurona se fue o algo as�)
    if isfield(e.slice, spk);
        slice = e.slice.(spk);
    else
        continue
    end
    e = eslice(e, slice);
    
    % Tiempos en los que inicia cada alineaci�n en el raster. Necesario
    % para alinear la gr�fica de tasa de disparo.
    maxtime = alleventsraster(e, spk,'anguloRotacion', {alignEvents{1:end}}, endEvents, labels,0);
    maxtime = maxtime(1:length(alignEvents));
   
    % Crar subplots con dimensiones modificadas para que el raster se vea
    % m�s grande que la tasa de disparo.
%     subplot(2,1,1, 'position', praster);
    subplot(2,1,2, 'position', prate);
    
    for ae = 1:length(alignEvents)
        
        % Alineaci�n de los ensayos 
        aligned = selectTrials(e, 'alignEvent', alignEvents{ae},'aciertos',0, 'delnotfound', 0);
        spks = {aligned.spikes.(spk)};
        
        % Caluclar la mediana de la duraci�n del evento de alineaci�n para
        % usarla como valor m�ximo de las muestras en la funci�n de tasa de
        % disparo
        end_median = median([aligned.events.(endEvents{ae}{end})]);
        samples = -0.5:0.001:end_median+0.3;
        
        % Tasa de disparo en funci�n de la rotaci�n del est�mulo
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

% L�NEAS DE C�DIGO CUANDO QUIERAS CALCULAR LA TASA DE DISPARO EN FUNCI�N DE
% LOS �NGULOS DE INICIO
%         nulls = angulos == 0;
%         null_frate = firingrate({spks{nulls == 1}}, samples, 'FilterType', 'exponential',  'TimeConstant', tau);
%         null_mean = mean(null_frate);
    
        % Graficar tasa de disparo para cada alineaci�n
        time_axis = samples + maxtime(ae);
        plot(time_axis, left_mean, 'b', 'linewidth',2); hold on
        plot(time_axis, right_mean, 'r','linewidth',2)
%         plot(time_axis, null_mean, 'g', 'linewidth',2)
        
        % M�ximos y m�nimos de la tasa de disparo para ajustar el eje de
        % las oordenadas del plot.
        minrate(ae) = min([left_mean,right_mean]);
        maxrate(ae) = max([left_mean,right_mean]);
        
%         minrate(ae) = min([left_mean,right_mean, null_mean]);
%         maxrate(ae) = max([left_mean,right_mean, null_mean]);
    end   
    
    % Settings del subplot de tasa de disparo
    xlim = [-0.3,  max(time_axis - timestep)];
    ylim = [min(minrate), max(maxrate)];
    set(gca, 'xlim', xlim, 'ylim', ylim, 'box', 'off','xtick', maxtime, 'xticklabel', zeros(length(maxtime),1))
    % Marcadores de los eventos de alineaci�n 
    line([maxtime; maxtime], repmat(ylim',1,length(maxtime)), 'color', 'k', 'linewidth', 1.5)
    
    % Raster. Por alg�n motivo desaparece si lo grafico antes de la tasa
    % del c�digo que calcula la tasa de disparo.
    subplot(2,1,1, 'position', praster);
    alleventsraster(e, spk, 'anguloRotacion',{alignEvents{1:end}}, endEvents, labels,1);
    set(gca, 'xlim', xlim)
    title([id,spk])
    
    % Guardar figura
%     saveas(gcf, ['C:\Users\eduardo\Documents\proyectos\rotacion\rasters\stims_hitsErrs\prefleft\', id, spk, '.png'])
% 
%     clf
end
