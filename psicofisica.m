% Psicofísica
clc
clear all
% Obtener la respuesta del mono
matdir = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings'];
files = dir([matdir,'\*.mat']);
A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = sort([-A,A]);

R = cell(2,length(A));

for f = 1:length(files)
    load([matdir,'\',files(f).name])
    mono = files(f).name(1);
    session_angs = [e.trial.anguloRotacion];
    session_angs = round(session_angs*10) / 10;
    for angulo = 1:length(A)
        selected_angle = session_angs == A(angulo);
        respuesta = [e.trial(selected_angle).respuesta]';
        if mono == 'd';
            R{1,angulo} = [R{1,angulo}; respuesta];
        else
            R{2,angulo} = [R{2,angulo}; respuesta];
        end
        
    end
end

%% Calcular la probabilidad de contestar izquierda
p_izq = zeros(2,length(A));

for r = 1:length(R)
   n1 = length(R{1,r}) ;
   n2 = length(R{2,r}) ;
   izq_resps1 = R{1,r} == 1;
   izq_resps2 = R{2,r} == 1;
   p_izq(1,r) = sum(izq_resps1)/n1;
   p_izq(2,r) = sum(izq_resps2)/n2;
end

%%
clf
logaxis=[-log(abs(A(1:6))),log(A(7:end))];
colord = [4/255,118/255,217/255];
colorc = [243/255,74/255,83/255];

plot(logaxis,p_izq(2,:),'-o','color',colorc,'markerfacecolor',colorc,'linewidth',2); hold on
plot(logaxis,p_izq(1,:),'-o','color',colord,'markerfacecolor',colord,'linewidth',2);  hold on
legend('Monkey C', 'Monkey D','location', 'southeast')
set(gca,'box','off','xscale','log','yscale','log')
xlabel('Stimulus Amplitude (degrees of rotation)')
ylabel('Probability of Answering Left')