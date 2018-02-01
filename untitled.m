files = dir('*c.mat');
pathresults = '~/Documents/proyectos/rotacion/matfiles/results_cesar/';
for i = 1:length(files)
    load(files(i).name)
    clc
    
    if size(results,2) < 11;
        continue
    else
        ai = unique(results(:,4));
        ar = unique(results(:,1))
        v = unique(results(:,9))
        t = unique(results(:,8))
        
        if ~(length(t) == 1)
            continue
        end
        
        %stims = struct('ar', ar, 'v', v, 't', t)
        
        c = input('tarea?:','s');
        
        switch c
            case 'r'
                copyfile(files(i).name, [pathresults, 'anguloFijo'])
            case 'v'
                copyfile(files(i).name, [pathresults, 'velFija'])
            case 't'
                copyfile(files(i).name, [pathresults, 'tiempoFijo'])
            case 'd'
                continue
        end
            
        
        
    end
    
        
        
    
end



%%
f = dir('~/Documents/proyectos/rotacion/matfiles/results_cesar/velFija/*.mat');

for i = 1:length(f);
   f(i).name 
   load(f(i).name) 
   psyFit(results, 'arotacion')
   
   pause
   clf
end 

%%

cfiles = '~/Documents/proyectos/rotacion/matfiles/results_cesar/';
dfiles = '~/Documents/proyectos/rotacion/matfiles/results_dewey/';

task = 'velFija';
datos = '14-Jul-2015-5d';
color = 'b';
load([dfiles, task, '/', datos])
d_velFija = psyFit(results, 'arotacion', 'c', color);

datos = '01-Aug-2015-6d';
color = 'r';
load([dfiles, task, '/', datos])
c_velFija = psyFit(results, 'arotacion', 'c', color);

x1 = d_velFija.numResp./d_velFija.numEnsayos;
x2 = c_velFija.numResp./c_velFija.numEnsayos;

[h, p, ks2stat] = kstest2(x1,x2);

velFija = struct('d_data', d_velFija,...
                'c_data', c_velFija,...
                'ksStat', [h, p, ks2stat]);

%%

task = 'anguloFijo';
datos = '21-May-2015-5d';
color = 'b';
load([dfiles, task, '/', datos])
d_anguloFijo = psyFit(results, 'velocidad', 'c', color);

datos = '23-May-2015-1d';
color = 'r';
load([dfiles, task, '/', datos])
c_anguloFijo = psyFit(results, 'velocidad', 'c', color);

x1 = d_anguloFijo.numResp./d_anguloFijo.numEnsayos;
x2 = c_anguloFijo.numResp./c_anguloFijo.numEnsayos;

[h, p, ks2stat] = kstest2(x1,x2);

anguloFijo = struct('d_data', d_anguloFijo,...
                'c_data', c_anguloFijo,...
                'ksStat', [h, p, ks2stat]);

%%
task = 'tiempoFijo';
datos = '03-Jun-2015-2d';
color = 'b';
load([dfiles, task, '/', datos])
d_tiempoFijo = psyFit(results, 'arotacion', 'c', color);

datos = '07-Aug-2015-1c';
color = 'r';
load([cfiles, task, '/', datos])
c_tiempoFijo = psyFit(results, 'arotacion', 'c', color);

x1 = d_tiempoFijo.numResp./d_tiempoFijo.numEnsayos;
x2 = c_tiempoFijo.numResp./c_tiempoFijo.numEnsayos;

[h, p, ks2stat] = kstest2(x1,x2);

tiempoFijo = struct('d_data', d_tiempoFijo,...
                'c_data', c_tiempoFijo,...
                'ksStat', [h, p, ks2stat]);