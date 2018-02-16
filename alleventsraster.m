function  maxtime = alleventsraster(e, spike_id,varargin)
% USO: 
%      maxtime = alleventsraster(e, spike_id,sortedBy, alignEvents, endEvents,labels, printraster)
% 
% alleventsraster es una funci�n que crea un raster plot para m�ltiples
% eventos de la tarea dentro de un mismo plot. Cada raster est� alineado a
% diferentes eventos y cada evento puede tener diferentes marcadores que
% indican el tiempo en el que ocurrieron diferentes eventos posteriores a
% la alineaci�n. 
%
% Argumentos de entrada:
% e: estructura en el que vienen los tiempos de los eventos de la tarea.
% spike_id: nombre de la unidad en el formato spike11;
% sortedBy: modo en los que quieres que se ordenen los ensayos: por
%           anguloInicio o anguloRotaci�n.
% alignEvents: celda con la lista de eventos de alineaci�n (ex. alignEvents={'touchIni', 'robMovIni'};)
% endEvents: lista con los marcadores de eventos posteriores al de
%           alineaci�n. Puede haber m�ltiples endEvents por alineaci�n, por lo tanto
%           la variable tiene que ser una lista de celdas y en cada celda la lista de
%           endEvents. Ejemplo: endEvents={{robMovIni, robMovFin}, {robMovFin,...
%           touchFin, targOn}}; en este caso cada celda tiene una lista de endEvents
%           para cada alineaci�n de alignEvents.
% labels: titulos que quieres que cada alineaci�n tenga en el raster para
%           poder identificarlos (deber�a de ser argumento opcional, pero por ahora
%           no lo es). Es una celda con la lista de las etiquetas de cada alineaci�n,
%           por lo tanto su longitud tiene que ser igual a la de alignEvents.
% printraster: 1 si quieres que lo imprima, 0 si no.
%
% Argumentos de salida:
% maxtime: variable que utiliza meanFiringRates2.m
%
% Funciones que llama:
% selectTrials
% rasterplot
% getmarkers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% sortedBy, alignEvents, endEvents,labels,rasterlimits,printraster
sortedBy = getArgumentValue('sortedBy','anguloRotacion',varargin{:});
alignEvents = getArgumentValue('alignEvents',{'manosFijasIni','touchIni', 'robMovIni'},varargin{:});
endEvents = getArgumentValue('endEvents',{{'manosFijasIni'},...
            {'touchCueIni','manosFijasFin','robMovIni'},...
            {'robMovFin', 'touchCueFin', 'targOn', 'targOff'}},varargin{:});
labels = getArgumentValue('labels',{'Wait', 'Contact', 'Stim On'},varargin{:});
rasterlimits = getArgumentValue('rasterlimits',[-0.5, 2;-2,0.8;-0.3,0.3],varargin{:});
printraster = getArgumentValue('printraster',1);

%%
id = e.ArchivoNEV(1:end-4);
ntrials = length(e.trial);

% rasterlimits = [-0.5, 2;...
%                 -2, 0.8;...
%                 -0.3,0.3];
rasterlimits = [rasterlimits;0,0];
% printraster = 1; sortedBy = 'anguloRotacion';
% Ordenar ensayos dependiendo de la magnitud y direcci�n de rotaci�n del
% est�mulo. 
angevents = selectTrials(e,'alignEvent','robMovIni','delnotfound', 1);
contact = [angevents.events.touchIni];
angulos = [angevents.events.(sortedBy)];
errores = find([angevents.events.correcto]' == 0);
[angulos_sorted, index] = sortrows([angulos',contact'],[1,-2]);
angulos_der = [angulos_sorted(angulos_sorted(:,1) < 0,1), index(angulos_sorted(:,1) < 0)];
angulos_der_sorted = sortrows(abs(angulos_der), 1);
angulos_izq = [angulos_sorted(angulos_sorted(:,1) > 0), index(angulos_sorted(:,1) > 0)];
n_der = size(angulos_der,1);

if strcmp(sortedBy, 'anguloInicio')
    angulos_null = [angulos_sorted(angulos_sorted == 0)', index(angulos_sorted == 0)'];
    sorted_trials = [angulos_der_sorted(:,2); angulos_null(:,2); angulos_izq(:,2)];
    der_start = 1;
    null_start = size(angulos_der_sorted,1)+1;
    izq_start = null_start + size(angulos_null,1);
    mark_der_index = 1:size(angulos_der_sorted,1);
    mark_null_index = null_start : null_start + size(angulos_null,1) - 1;
    mark_izq_index = izq_start : izq_start + size(angulos_izq,1) -1;
else
    sorted_trials = [angulos_der_sorted(:,2); angulos_izq(:,2)];
end

% Indice de los ensayos incorrectos para pintarlos de diferente color
err_indx = sort(find(ismember(sorted_trials, errores) == 1));

% Limites de los rasters
% if (alignEvents) == size(rasterlimits,1)
%     rasterlimits = [rasterlimits;0,0];
% else
%     error('Las filas de rasterlimits tiene que ser igual a la longitud de alignEvents')
% end

% Inicializaci�n de variables
xticks = cell(length(alignEvents),1);
yticks = xticks;
start_xmarkers = xticks;
start_ymarkers = xticks;
end_xmarkers = xticks;
end_ymarkers = xticks;

% Obtener los ticks para el raster de los spikes y los marcadores
for ae = 1:length(alignEvents)
  
    aligned = selectTrials(e,'alignEvent',alignEvents{ae}, 'delnotfound', 1);
    
    maxang = [angulos_der_sorted(end-10:end,2); angulos_izq(end-10:end,2)];    
    end_median = median([aligned.events(maxang).(endEvents{ae}{end})]);
    end_median = median([aligned.events.(endEvents{ae}{end})]);
    xlim = [rasterlimits(ae,1),end_median + rasterlimits(ae,2)];
    
    if spike_id;
        [xticks{ae}, yticks{ae}] = rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
            'xlim',xlim,...
            'color','k');
    end
    
    [start_xmarkers{ae}, start_ymarkers{ae}] = getmarkers(aligned.events, sorted_trials, alignEvents{ae});
    
    for eE = 1:length(endEvents{ae})
        [end_xmarkers{ae}(:,eE), end_ymarkers{ae}(:,eE)] = getmarkers(aligned.events, sorted_trials, endEvents{ae}{eE});
    end
    
    index = find(end_xmarkers{ae} > xlim(2));
    end_xmarkers{ae}(index) = nan;
  
end

% Convertir los ticks y marcadores en vectores
maxtime(1) = 0;

if spike_id;
    r = size(xticks{1},1);
    c = size(xticks{1},2);
    Xticks = [];
    Yticks = [];
end

Xmarkers_start = [];
Xmarkers_end = [];
Ymarkers_start = [];
Ymarkers_end = [];


for i = 1:size(xticks,1)
    if spike_id;
        Xticks = [Xticks,cell2mat(xticks(i)) + maxtime(i)];
        Yticks = [Yticks,cell2mat(yticks(i))];
    end
        Xmarkers_start = [Xmarkers_start; cell2mat(start_xmarkers(i)) + maxtime(i)];
        Ymarkers_start = [Ymarkers_start; cell2mat(start_ymarkers(i))];
   
%     xmarkers = cell2mat(end_xmarkers(i)) + maxtime(i);
%     ymarkers = cell2mat(end_ymarkers(i));
%     for em = 1:size(end_xmarkers{i},2)
%         Xmarkers_end = [Xmarkers_end; xmarkers(:,em)];  
%         Ymarkers_end = [Ymarkers_end; ymarkers(:,em)];
        end_xmarkers{i} = end_xmarkers{i} + maxtime(i);
%     end
    if i < size(rasterlimits,1);
        if strcmp(alignEvents{i}, endEvents{i}{end})
            timestep = 0.8 + rasterlimits(i,2) + abs(rasterlimits(i+1,1));
        else
            timestep = 0.8 + abs(rasterlimits(i+1,1));
        end
        maxtime(i+1) = max(max(end_xmarkers{i}))+ timestep;
    end
end

if printraster

    if strcmp(sortedBy, 'anguloInicio')
        plot(Xmarkers_start(mark_der_index), Ymarkers_start(mark_der_index), '.r'); hold on
        plot(Xmarkers_start(mark_null_index), Ymarkers_start(mark_null_index), '.g'); hold on
        plot(Xmarkers_start(mark_izq_index), Ymarkers_start(mark_izq_index), '.b'); hold on
    else
        plot(Xmarkers_start, Ymarkers_start, '.g'); hold on
    end
    
    for ex = 1:length(end_xmarkers)
        if strcmp(alignEvents{ex}, 'manosFijasIni');
            color = {'b','y','g'};
        elseif strcmp(alignEvents{ex}, 'touchIni');
            color = {'m','b','c','y'};
        elseif strcmp(alignEvents{ex}, 'robMovIni');
            color = {'b','r','y','m','g','r'};
%             color = {[243/255,0,104/255],[1,1,0],[82/255,38/255,181/255],[213/255,1,69/255],[32/255,0,1],[0,1,177/255]};
        else
            color = {'b','c','y','m','c','r'};
        end
  
        for l = 1:size(end_xmarkers{ex},2) 
           plot(end_xmarkers{ex}(:,l), end_ymarkers{ex}(:,l), '.', 'color',color{l})
        end
    end
    
    if spike_id;
        markersize = 1;
        line(Xticks, Yticks,'color', 'k'); 
%         plot(Xticks(1,:), Yticks(1,:), '.k', 'markersize', markersize)
        ylim = [1,ntrials+1];
        
        % Cambiar ensayos en los que se equivoc� por ticks rojos
        y_err_indx = find(ismember(Yticks(1,:), err_indx - 0.4) == 1);
%         line( repmat([-0.3;0.8],1,length(err_indx)), [err_indx'; err_indx'], 'color', [1,0.9,0.9]);
%         line(Xticks(:,y_err_indx), Yticks(:,y_err_indx),'color', 'r', 'linewidth',1)
%         plot(Xticks(1,y_err_indx), Yticks(1,y_err_indx),'.r','markersize', markersize)

    end

    ypos = length(e.trial) + length(e.trial)*0.02;
    for t = 1:length(maxtime)-1
        text(maxtime(t), ypos, labels{t});
    end

    set(gca,'xlim',[rasterlimits(1), max(max(Xticks))], 'ylim',[0,length(angulos)+1], 'xtick', maxtime, 'xticklabel', zeros(length(maxtime),1), 'box', 'off', 'xcolor', 'w')

    T = title([id,' ', spike_id]);
    T_position = get(T, 'position');
    T_offset = T_position(2) + (T_position(2) * 0.01);
    set(T, 'position', [T_position(1), T_offset, T_position(3)]);
    shg
end

