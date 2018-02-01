close all; clear all
sortedBy = 'anguloRotacion';
% id = 'd1609231120';
id = 'd1609231120';
load(['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\', id, '.mat'])
channel = 2;


alignEvents = {'manosFijasIni','touchIni', 'robMovIni'};
endEvents = {{'manosFijasIni'},...
            {'touchCueIni','manosFijasFin','robMovIni'},...
            {'robMovFin', 'touchCueFin', 'targOn', 'targOff'}};
labels = {'Wait', 'Contact', 'Stim On'};

% Ordenar ensayos dependiendo de la magnitud y dirección de rotación del
% estímulo. 
angevents = selectTrials(e,'alignEvent','robMovIni','delnotfound', 1);
angulos = [angevents.events.(sortedBy)];
errores = find([angevents.events.correcto]' == 0);
[angulos_sorted, index] = sort(angulos);
angulos_der = [angulos_sorted(angulos_sorted < 0)', index(angulos_sorted < 0)'];
angulos_der_sorted = sortrows(abs(angulos_der), 1);
angulos_izq = [angulos_sorted(angulos_sorted > 0)', index(angulos_sorted > 0)'];
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

% LFP raster
ae = 3;

% Alineación a eventos
aligned = selectTrials(e, 'alignEvent', alignEvents{ae}, 'delnotfound',1);
maxang = [angulos_der_sorted(end-10:end,2); angulos_izq(end-10:end,2)];    
end_median = median([aligned.events(maxang).(endEvents{ae}{end})]);

% Rotaciones a la derecha
tstart = [aligned.events(angulos_der_sorted(:,2)).(alignEvents{ae})]-1;
tend = [aligned.events(angulos_der_sorted(:,2)).(endEvents{ae}{end})];
tend = tend + median(tend) + 0.3;
for r = 1:size(angulos_der_sorted,1)
   lfp_left = (r*10)+double(aligned.events(angulos_der_sorted(r,2)).lfp(channel,:))*0.01;
   lfptime = aligned.events(angulos_der_sorted(r,2)).lfpTime;
   timeindx = lfptime >= tstart(r) & lfptime <= tend(r);
   plot(lfptime(timeindx == 1), lfp_left(timeindx == 1), 'color', [0.5,0.5,0.5]); hold on
end

% Rotaciones a la izquierda
tstart = [aligned.events(angulos_izq(:,2)).(alignEvents{ae})]-1;
tend = [aligned.events(angulos_izq(:,2)).(endEvents{ae}{end})];
tend = tend + median(tend) + 0.3;
r = r + 1;
for l = 1:size(angulos_izq,1)
   lfp_left = (r*10)+double(aligned.events(angulos_izq(l,2)).lfp(channel,:))*0.01;
   lfptime = aligned.events(angulos_izq(l,2)).lfpTime;
   timeindx = lfptime >= tstart(l) & lfptime <= tend(l);
   plot(lfptime(timeindx == 1), lfp_left(timeindx == 1), 'color', [0.5,0.5,0.5]); 
   r = r + 1;
end

[start_xmarkers, start_ymarkers] = getmarkers(aligned.events, sorted_trials, alignEvents{ae});
[end_xmarkers, end_ymarkers] = getmarkers(aligned.events, sorted_trials, 'robMovFin');
plot(start_xmarkers, start_ymarkers*10, '.r')
plot(end_xmarkers, end_ymarkers*10, '.g')
set(gca,'xlim', [-1, end_median + 0.3])
axis square
    