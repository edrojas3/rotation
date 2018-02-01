files = dir('*.mat');
tic
for f = 2:length(files)
    load(files(f).name)
    frates_new = cell(2,8);
    reorder = 6:-1:1;
    for i = 1:8;
        left = [];
        right = [];
        for c = 1:12
            if c < 7;
                right = [right;frates{reorder(c),i}];
            else
                left = [left;frates{c,i}];
            end      
        end
        frates_new{2,i} = right;
        frates_new{1,i} = left;
    end

    clear frates
    frates = frates_new;
    save(files(f).name, 'frates')
    
end
toc
%%
close all
% clear all
fdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\frates';
% files = dir([fdir, '\*.mat']);
frdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\frates';
rastdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\rasters\alleventraster_goodRobMoves';
files = dir([rastdir, '\*.png']);
% savedir
alignEvent = 'movIni';
prefL = {};
prefR = {};
prefM = {};
% cog = {};
for f = 584:length(files)
%     if f == 301; break; end
    
    id = files(f).name(1:end-4);
    if exist([fdir, '\', id, '.mat'], 'file');
        load([fdir, '\', id])
    else
        continue
    end
    
    if exist([rastdir,'\', id, '.png'],'file');
        r = imread([rastdir, '\', id, '.png']);
        image(r);
        axis square
    end
    timeSec = frates.timeSec;
    
    
    left_mean = frates.(alignEvent).left.mean;
    left_norm = frates.(alignEvent).left.norm;
    left_norm2lb = frates.(alignEvent).left.norm2lb;
    right_mean = frates.(alignEvent).right.mean;
    right_norm = frates.(alignEvent).right.norm;
    right_norm2lb = frates.(alignEvent).right.norm2lb;
    lat_index = frates.(alignEvent).lat_index;
    
    figure
    subplot(2,2,1)
    plot(timeSec,left_mean, 'b', 'marker', '.'); hold on
    plot(timeSec,right_mean, 'r', 'marker', '.')
    set(gca, 'xlim', [timeSec(1), timeSec(end)])
    title(files(f).name(1:end-4))
    xlabel('Times (s)'), ylabel('Mean firing rate')
    axis square
    
    subplot(2,2,2)
    plot(timeSec, lat_index, '.w', 'linewidth', 3)
    line([-0.3, 0.65], [0,0])
    xlabel('Times (s)'), ylabel('Lateralization Index')
    axis square
    set(gca, 'color',[0.5,0.5,0.5], 'xlim', [-0.305,0.65], 'ylim', [-1,1])
    
    subplot(2,2,3)
    plot(timeSec,left_norm, 'b', 'marker', '.'); hold on
    plot(timeSec,right_norm, 'r', 'marker', '.')
    line([timeSec(1), timeSec(end)], [2.3, 2.3], 'color', 'k')
    line([timeSec(1), timeSec(end)], [-2.3, -2.3], 'color', 'k')
    set(gca, 'xlim', [timeSec(1), timeSec(end)])
    xlabel('Times (s)'), ylabel('z-val')
    axis square
    
    subplot(2,2,4)
    plot(timeSec,left_norm2lb, 'b', 'marker', '.'); hold on
    plot(timeSec,right_norm2lb, 'r', 'marker', '.')
    line([timeSec(1), timeSec(end)], [2.3, 2.3], 'color', 'k')
    line([timeSec(1), timeSec(end)], [-2.3, -2.3], 'color', 'k')
    set(gca, 'xlim', [timeSec(1), timeSec(end)])
    xlabel('Times (s)'), ylabel('z-val')
    axis square
    shg
    
    classif = input('clasificacion: ');
    if classif == 0;
        savedir = [frdir, '\none'];
    elseif classif == 1;
%         prefL = {prefL; files(f).name(1:end-4)};
        respdir = input('Actividad: ');
        if respdir == 1
            savedir = [frdir, '\left\inhibe'];
        else
            savedir = [frdir, '\left\excita'];
        end
        cognitive = input('Cognitiva: ');
        if cognitive; cog = [cog; id]; end
            
    elseif classif == 2;
%         prefR = {prefR; files(f).name(1:end-4)};
        respdir = input('Actividad: ');
        if respdir == 1
            savedir = [frdir, '\right\inhibe'];
        else
            savedir = [frdir, '\right\excita'];
        end
        cognitive = input('Cognitiva: ');
        if cognitive; cog = [cog; id]; end
        
    elseif classif == 3;
%         prefM = {prefM; files(f).name(1:end-4)};
        respdir = input('Actividad: ');
        if respdir == 1
            savedir = [frdir, '\both\inhibe'];
        else
            savedir = [frdir, '\both\excita'];
        end
    elseif classif == 4;
%         prefM = {prefM; files(f).name(1:end-4)};
        savedir = [frdir, '\motor'];
    elseif classif == 5;
        respdir = input('Actividad: ');
        if respdir == 1;
            savedir = [frdir, '\stimselective\left'];
        elseif respdir == 2;
            savedir = [frdir, '\stimselective\right'];
        else
            savedir = [frdir, '\stimselective\both'];
        end
        savedir = [frdir, '\stimselective'];
        cognitive = input('Cognitiva: ');
        if cognitive; cog = {cog; id}; end
        
    elseif classif == 6;
        respdir = input('Actividad: ');
        if respdir == 1
            savedir = [frdir, '\tactile\inhibe'];
        else
            savedir = [frdir, '\tactile\excita'];
        end
               
    elseif classif == 7;
        savedir = [frdir, '\dunno'];
        
    elseif classif == 8;
        savedir = [frdir, '\ofinterest'];
    end
    savename = [savedir, '\', files(f).name(1:end-4),'.png'];
    saveas(gcf, savename)
    
    close all
end