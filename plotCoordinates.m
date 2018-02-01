close all; clear all; clc

% files with coordinates
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\registros';
matfiles = dir([matdir, '\*.mat']);

% Coordinates per monkey
C = [];
D = [];
A = [];
for f = 1:length(matfiles)
    load([matdir, '\',matfiles(f).name])

    canulas = repmat(e.canulas.coordenadas(1:2),3,1);
    electrodos = [e.electrodos.profundidad - e.electrodos.corteza]'/1000;
    A = [A;canulas,electrodos];
    if matfiles(f).name(1) == 'c';
        C = [C; canulas, electrodos];
    else
        D = [D; canulas, electrodos];
    end
end
clf
plot3(C(:,1), C(:,2), C(:,3), 'b.'); hold on
plot3(D(:,1), D(:,2), D(:,3), 'r.')
xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
set(gca,'zdir','reverse')
legend('César','Dewey')
title('Recording locations per monkey')
grid on

%% Coordinates of neurons with rotation preference

% list of preference neurons and ids
load 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\preferenceList'

% ids of preference neurons
lp = find(preference == 1);
rp = find(preference == -1);
pids = ids([lp,rp]);
pindex = [ones(1,length(lp)), -1*ones(1,length(rp))];

L = [];
R = [];
for pp = 1:length(pids)
  fname = pids{pp}(1:11);
   load([matdir,'\',fname])
   % coordinates of the recording session
   canulas = repmat(e.canulas.coordenadas(1:2),3,1);
   electrodos = [e.electrodos.profundidad - e.electrodos.corteza]'/1000;
   % select channel with the neuron 
   channel = str2num(pids{pp}(end-1));
   if     channel==1;   ch=1;
   elseif channel==3;   ch=2;
   elseif channel==5;   ch=3;
   end
   % create matrices with coordinate
   if pindex(pp) == 1
       L = [L;canulas(ch,:),electrodos(ch)];
   else
       R = [R;canulas(ch,:),electrodos(ch)];
   end
end
%%
figure
r = -.08 + (.16)*rand(size(A));
Ar = A+r;
r = -.08 + (.16)*rand(size(L));
Lr = L+r;
r = -.08 + (.16)*rand(size(R));
Rr = R+r;
ms = 10;
plot3(Ar(:,1),Ar(:,2),Ar(:,3),'.', 'color',[0.5,0.5,0.5],'markersize',ms); hold on
plot3(Lr(:,1),L(:,2),L(:,3),'.b','markersize',ms+10)
plot3(Rr(:,1),R(:,2),R(:,3),'.r','markersize',ms+10)
xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
set(gca,'zdir','reverse')
legend('Non preference','Left preference', 'Right preference')
title('Recording locations of neurons with rotation preference')
grid on
