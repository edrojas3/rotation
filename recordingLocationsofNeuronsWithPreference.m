clear all; close all; clc
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
matfiles = dir([matdir,'\*.mat']);
preffiles = dir('C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns\*.png');
load('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\classification_struct.mat')

leftindex = classif.stimulus.pref == 1;
rightindex = classif.stimulus.pref == -1;
leftfiles = preffiles(leftindex == 1);
rightfiles = preffiles(rightindex == 1);

coordenadas =[];
for f = 1:length(matfiles)
    id = matfiles(f).name(1:11);
    load([matdir,'\',id])  
    canulas = repmat(e.canulas.coordenadas(1:2),3,1);
    electrodos = [(e.electrodos.profundidad - e.electrodos.corteza)/ 1000]';
    coordenadas = [coordenadas; canulas,electrodos];
end


x = []; y = []; z = [];
for f = 1:length(leftfiles)
   id = leftfiles(f).name(1:11);
   spikeid = leftfiles(f).name(12:18);
   channel = str2num(spikeid(end-1));
   switch channel
       case 3
           channel = 2;
       case 5
           channel = 3;
   end
   unit = str2num(spikeid(end));
   
   load([matdir,'\',id])
   
   x(f) = e.canulas.coordenadas(1);
   y(f) = e.canulas.coordenadas(2);
   
   calib2zero = e.electrodos.profundidad - e.electrodos.corteza;
   z(f) = calib2zero(channel)/1000;
   
%    coordenadas [x,y,z]
end
    
    
leftcoord = [x',y',z'];
x = []; y = []; z = [];
for f = 1:length(rightfiles)
   id = rightfiles(f).name(1:11);
   spikeid = rightfiles(f).name(12:18);
   channel = str2num(spikeid(end-1));
   switch channel
       case 3
           channel = 2;
       case 5
           channel = 3;
   end
   unit = str2num(spikeid(end));
   
   load([matdir,'\',id])
   
   x(f) = e.canulas.coordenadas(1);
   y(f) = e.canulas.coordenadas(2);
   
   calib2zero = e.electrodos.profundidad - e.electrodos.corteza;
   z(f) = calib2zero(channel)/1000;
   
%    coordenadas [x,y,z]
end

rightcoord = [x',y',z'];
%%
clf
subplot(1,2,1)
plot3(coordenadas(:,1),coordenadas(:,2),coordenadas(:,3), '.k'); hold on
xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
set(gca,'zdir','reverse')
grid on
axis square

subplot(1,2,2)
plot3(leftcoord(:,1), leftcoord(:,2), leftcoord(:,3), 'b.'); hold on
plot3(rightcoord(:,1), rightcoord(:,2), rightcoord(:,3), 'r.'); 
xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
set(gca,'zdir','reverse')
grid on
axis square