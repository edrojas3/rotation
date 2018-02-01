function [xmarkers, ymarkers] = getmarkers(events,sorted, varargin)
% Obtiene los marcadores de los eventos de la tarea.
%
% USO: [xmarkers, ymarkers] = getmarkers(events,sorted, varargin)
%
%  Entradas
%  events: campo de estructura tipo aligned.events donde vienen alineados
%  los tiempos de los eventos.
% sorted: vector con los indices de los ensayos ordenados
% varargin: string de los eventos de los que quieres obtener los marcadores

sortedTrials = events(sorted);


xmarkers = zeros(length(sortedTrials), length(varargin));
for i = 1:length(sortedTrials);

    for k = 1:length(varargin)
%        if isempty(sortedTrials(i).robMovIni); 
%            xmarkers(i,k) = nan;
%        else
            xmarkers(i,k) = sortedTrials(i).(varargin{k});
%        end
    end

ymarkers = 1:length(sortedTrials);
ymarkers = ymarkers';
    
end

