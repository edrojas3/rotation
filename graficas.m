matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\frates';
matfiles = dir([matdir, '\*.mat']);
close all
figure
set(gcf, 'windowstyle', 'docked')
hold on
gspace = [0,2,4,6,8,10,12,14];
samples = -0.3:0.05:1.3;

for f = 1:length(matfiles)
    load([matdir,'\',matfiles(f).name])
    for p = 1:8
    plot(samples+gspace(p),nanmean(cell2mat(frates(1:6,p))),'r')
    plot(samples+gspace(p),nanmean(cell2mat(frates(7:12,p))),'b')
    end
   
end

      
set(gca,'xlim',[-0.3,16])
set(gca,'ygrid','on','xtick',[])

%%
labels = {'Wait',...
          'Touch Cue',...
          'Reach',...
          'Contact',...
          'Stimulus Start',...
          'Stimulus End',...
          'Reach Back',....
          'Targets On'};
ylim = get(gca,'ylim');
for l = 1:length(gspace)
     line([gspace(l),gspace(l)], [ylim(1),ylim(2)], 'color','k', 'linewidth',2)
     text(gspace(l)-0.1,ylim(2)+5,labels{l})
end