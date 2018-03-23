function [] = rasterAndFiringRates(e,spk,varargin)
% Raster plot and firing rate (not normalized) of a neuron plotted in one
% figure.
%
% Usage: rasterAndFiringRates(e,spk)



% Settings para la tasa de disparo
samples = getArgumentValue('samples',-0.5:0.01:1,varargin{:});
tau = getArgumentValue('tau',0.05,varargin{:});
alignEvents = getArgumentValue('alignEvents',{'manosFijasIni','touchIni', 'robMovIni'},varargin{:});
endEvents = getArgumentValue('endEvents',{{'manosFijasIni'},...
            {'touchCueIni','manosFijasFin','robMovIni'},...
            {'robMovFin', 'touchCueFin', 'targOn', 'targOff'}},varargin{:});
labels = getArgumentValue('labels',{'Wait', 'Contact', 'Stim On'},varargin{:});
rasterlimits = getArgumentValue('rasterlimits',[-0.5, 2;-2,0.8;-0.3,0.3],varargin{:});
sortedBy = getArgumentValue('sortedBy','anguloRotacion',varargin{:});

printraster = getArgumentValue('printraster',1);
timestep = getArgumentValue('timestep',1.3,varargin{:});
praster = getArgumentValue('rasterposition',[0.13,0.23,0.775,0.7],varargin{:});
prate = getArgumentValue('frateposition',[0.13,0.05,0.775,0.17],varargin{:});

% Variables �tiles para las gr�ficas
samp_index = find(samples >= -0.5 & samples < 0.6);
minrate = []; 
maxrate = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

id = e.ArchivoNEV(1:end-4);

% Quitar ensayos malos (que en el raster parezca que la neurona se fue o algo as�)
if isfield(e.slice, spk);
    slice = e.slice.(spk);
else
    slice = ones(1,length(e.trial));
end
e = eslice(e, slice);

% Tiempos en los que inicia cada alineaci�n en el raster. Necesario
% para alinear la gr�fica de tasa de disparo.
subplot(2,1,1);
maxtime = alleventsraster(e, spk,'alignEvents',alignEvents,'endEvents',endEvents,'labels',labels,...
                        'rasterlimits',rasterlimits,'sortedBy',sortedBy,'printraster',0);
maxtime = maxtime(1:length(alignEvents));
rasterxlim = get(gca, 'xlim');
% Crar subplots con dimensiones modificadas para que el raster se vea
% m�s grande que la tasa de disparo.
%     subplot(2,1,1, 'position', praster);

subplot(2,1,2);
set(gca, 'position', prate)
for ae = 1:length(alignEvents)

    % Alineaci�n de los ensayos 
    aligned = selectTrials(e, 'alignEvent', alignEvents{ae},'aciertos',1, 'delnotfound', 0);
    spks = {aligned.spikes.(spk)};

    % Caluclar la mediana de la duraci�n del evento de alineaci�n para
    % usarla como valor m�ximo de las muestras en la funci�n de tasa de
    % disparo
    end_median = median([aligned.events.(endEvents{ae}{end})]);
    if strcmp(alignEvents{ae},endEvents{ae})
        samples = rasterlimits(ae,1):0.01:rasterlimits(ae,2); 
    else
        samples = rasterlimits(ae,1):0.01:end_median+0.3;
    end

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
set(gca, 'xlim', rasterxlim, 'ylim', ylim, 'box', 'off','xtick', maxtime, 'xticklabel', zeros(length(maxtime),1))
% Marcadores de los eventos de alineaci�n 
line([maxtime; maxtime], repmat(ylim',1,length(maxtime)), 'color', 'k', 'linewidth', 1.5)

% Raster. Por alg�n motivo desaparece si lo grafico antes de la tasa
% del c�digo que calcula la tasa de disparo.
subplot(2,1,1);
set(gca, 'position', praster)
alleventsraster(e, spk,'anguloRotacion', {alignEvents{1:end}}, endEvents, labels,rasterlimits,1);
set(gca, 'xlim', rasterxlim)
title([id,spk])


