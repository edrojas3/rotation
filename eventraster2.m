addpath(genpath('C:\Users\eduardo\Dropbox\rotacion'))

%% Initial settings
mono = 0; % 1 = dewey, 0 = césar
scan = 1; % raster exploratorio

if mono;
    monofiles = dir ('C:\Users\eduardo\Google Drive\Exp mono\d16*.nev');
    figdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\dfigs\noOrder_rasters';
else
    monofiles = dir ('C:\Users\eduardo\Google Drive\Exp mono\c160831*.nev');
    figdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\cfigs\noOrder_rasters';
end
    
%%
for m = 1:length(monofiles)
    %% Datos iniciales    
    id = strtok(monofiles(m).name,'.');
%     id = 'd1604081123';
%     spikeid = 'spike11';
    
    nevData = ['C:\Users\eduardo\Google Drive\Exp mono\',id,'.nev'];
    ns1File = ['C:\Users\eduardo\Google Drive\Exp mono\', id, '.ns1'];
    
    NEV = openNEV (nevData, 'nosave');
    spikes_exist = 1;
    if isempty(NEV.Data.Spikes.TimeStamp);
        spikes_exist = 0;
    end
    if spikes_exist
    % obtener los datos de cada ensayo a partir del archivo nev
        e = blackRock2event(nevData,ns1File);
        spikeid = fieldnames(e.spikes);
        
        % Raster para cada spike
        for s = 1:length(spikeid)
            if scan; % raster exploratorio (sin ordenar) para depurar ensayos ruidosos
                sortedTrials = 1:length(e.trial);
                quickraster(e, spikeid{s},'manosFijasFin')
%                 raster2_test(e,spikeid{s},'manosFijasFin',sortedTrials)

                set(gca, 'xlim',[-8,8])
                ylim = get(gca, 'ylim');
                title([id,' ', spikeid{s}, ' n=',num2str(ylim(2)) ])
            end

            figname = [figdir,id, spikeid{s}, '.png'];
            saveas(gca, figname)
            close all
        end
    end
    
end

%%
[n, txt] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\cdb.xls', 1, 'A2:E480');
for i = 1:size(n,1)
   txt{i,3} = n(i,1);
   txt{i,4} = n(i,2);
end
database = txt;
%%
load('C:\Users\eduardo\Documents\proyectos\rotacion\database.mat')
%%

for ntrial = 295:size(database,1)
  
    id = database{ntrial,1};
    
    if isnan(str2double(id(end)));
        nevid = id(1:end-1);
    else
        nevid = id;
    end
    spikeid = database{ntrial,2};
    totaln = database{ntrial,3};
    fullsession = cell2mat(database(ntrial,4));
    
    e = getSessionStruct(nevid);
    
    if fullsession;
        selection = 1:length(e.trial);
    else        
        selection = database{ntrial,5};
        slicing = getSlicing(totaln, selection);
        e = eslice(e,slicing);
    end
    
    sorted_trials = sortTrials(e);
    
    if mono;
        figdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\dfigs\';
    else
        figdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\cfigs\';
    end
    
    alignEvent = 'manosFijasFin';
    figname = [figdir,alignEvent,'\',id, spikeid, '.png'];
%     if ~(exist(figname, 'file'));
        raster2_test(e, spikeid, alignEvent,sorted_trials)
        saveas(gca, figname)
%     end
    
    alignEvent = 'touchIni';
    figname = [figdir,alignEvent,'\',id, spikeid, '.png'];
%     if ~(exist(figname, 'file'));
        raster2_test(e, spikeid, alignEvent,sorted_trials)
        saveas(gca, figname)
%     end
     
    alignEvent = 'movIni';
    figname = [figdir,alignEvent,'\',id, spikeid, '.png'];
%    if ~(exist(figname, 'file'));
        raster2_test(e, spikeid, alignEvent,sorted_trials)
        saveas(gca, figname)
%    end
    
    alignEvent = 'targOn';
    figname = [figdir,alignEvent,'\',id, spikeid, '.png'];
%     if ~(exist(figname, 'file'));
        raster2_test(e, spikeid, alignEvent,sorted_trials)
        saveas(gca, figname)
%     end
    
    close all
end

