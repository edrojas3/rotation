fdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\rasters\allrasters';
files = dir([fdir, '\*.png']);

id_list = {};
for f = 1:length(files)-1;
   
   id1 =  strsplit(files(f).name, '_');
   id1 = id1{1};
   if isnan( str2double( id1(end) )  )
       id1 = id1(1:end-1);
   end
   
   id2 = strsplit(files(f+1).name, '_');
   id2 = id2{1};
   if isnan( str2double( id2(end) )  )
       id2 = id2(1:end-1);
   end
   
   if strcmp(id1, id2) 
       continue
   else
       id_list = [id_list; id1];
   end
end

%%
destiny = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
cesar = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\cesar';
dewey = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\dewey';

for i = 1:length(id_list);
   id = id_list{i};
   
    if id(1) == 'c';
       source = [cesar, '\', id, '.mat'];
    else
       source = [dewey, '\', id, '.mat'];
    end
    
    copyfile(source, destiny)
end

%%
clearvars -except id_list
id = 'c1609011623';
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
% matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\cesar';
for f = 1:length(id_list)
    id = id_list{f};
    load([matdir, '\', id])
    for n = 1:length(e.trial);
        signal = double(e.trial(n).robSignal);
        signal = filtsignal(signal, 15, 70);
        ts = e.trial(n).robTimeSec;

        cmdini = e.trial(n).cmdStim;
        cmdfin = e.trial(n).stimFin;
        movini = e.trial(n).movIni;
        movfin = e.trial(n).movFin;

        tsini = cmdini < ts & ts < movini;
        ini = find(tsini == 1);
        if isempty(ini);
            startlim = [1,300];
        else
            startlim  = [ini(1), ini(end)];
        end

        tsend = movfin < ts & ts < cmdfin;
        fin = find(tsend == 1);
        if isempty(fin);
            endlim = [700, 1000];
        else
            endlim = [fin(1), fin(end)];
        end
        
        try 
            mark = getRobMarkers(signal, 'startlim', startlim, 'endlim', endlim);
        catch err
            e.trial(n).robMarkIni = movini;
            e.trial(n).robMarkfin = movfin;
            save([matdir, '\', id], 'e')
            continue
        end
        
        mark = [ts(mark(1)), ts(mark(2))];
        e.trial(n).robMarkIni = mark(1);
        e.trial(n).robMarkfin = mark(2);
% 
%         cmdline = [cmdini, cmdfin; cmdini, cmdfin];
%         movline = [movini, movfin; movini, movfin];

    %     markline = [ts(mark(1)), ts(mark(2)); ts(mark(1)), ts(mark(2))];
    %     startdiff(n) = movini - cmdini;
    %     enddiff(n) = cmdfin - movfin;
    %     mark1diff(n) = mark(1) - cmdini;
    %     mark2diff(n) = cmdfin - mark(2);

%         plot(ts, signal)
% %         set(gca, 'xlim', [ts(1), ts(end)])
%         ylim = get(gca,'ylim');
%         line(cmdline, ylim, 'color','k')
%         line(movline, ylim, 'color', 'r')
%         line(markline, ylim, 'color', 'g' )
%         title(num2str(e.trial(n).anguloRotacion))
       
    end
%     save([matdir, '\', id], 'e')
end


%%
clear all
clc
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
files = dir([matdir, '\*.mat']);
nandetect = [];
for f = 1:length(files)
   load([matdir, '\', files(f).name]) 
   marks = [[e.trial.robMarkIni], [e.trial.robMarkfin]];
   if any(isnan(marks));
       nandetect = [nandetect,f];
   end
   
end

%%
for nd = 1:length(nandetect)
    
end



