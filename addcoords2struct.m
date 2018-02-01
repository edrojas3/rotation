matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
matfiles = dir([matdir, '\*.mat']);

coordenadas_prev = [0,0,0];
contacto_prev = [0,0,0];
orientacion_prev = 'ap';
corteza_pr0ev = 0;
%%
for f = 1:length(matfiles);
    load([matdir, '\',matfiles(f).name]);
    e
    
    coordenadas = input('coordenadas: ');
    if isempty(coordenadas); 
        coordenadas = coordenadas_prev;
        contacto = contacto_prev;
        orientacion = orientacion_prev;
        corteza = corteza_prev;
    else
        contacto = input('contacto: ');
        orientacion = input('orientacion: ','s');
        corteza = input('corteza: ');
    end
    
    e.canulas.coordenadas = coordenadas;
    e.canulas.contacto = contacto;
    e.canulas.orientacion = orientacion;

    e.electrodos.corteza = corteza;
    e.electrodos.profundidad = input('profundidad electrodos: ');

    save([matdir, '\',matfiles(f).name], 'e')
    
    coordenadas_prev = coordenadas;
    contacto_prev = contacto;
    orientacion_prev = orientacion;
    corteza_prev = corteza;
end


% spikeid = fieldnames(e.spikes);
%    for s = 1:length(spikeid)
%       e.electrodos.(spikeid{s}) = input([spikeid{s}, ' profundidad: ']) ;
%    end