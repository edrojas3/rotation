function [p_izq,R, A] = psicofisica(idlist,matdir)
A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = sort([-A,A]);

R = cell(1,length(A));

for f = 1:length(idlist)
    load([matdir,filesep,idlist{f}])
    session_angs = [e.trial.anguloRotacion];
    session_angs = round(session_angs*10) / 10;
    for angulo = 1:length(A)
        selected_angle = session_angs == A(angulo);
        respuesta = [e.trial(selected_angle).respuesta]';
        R{1,angulo} = [R{1,angulo}; respuesta];
    end
end

%% Calcular la probabilidad de contestar izquierda
p_izq = zeros(1,length(A));

for r = 1:length(R)
   n1 = length(R{1,r}) ;
   izq_resps1 = R{1,r} == 1;
   p_izq(1,r) = sum(izq_resps1)/n1;
end

%%
if nargout == 0
    clf
    logaxis=[-log(abs(A(1:6)))+5,log(A(7:end))+10];
    colord = [4/255,118/255,217/255];
    colorc = [243/255,74/255,83/255];

    plot(logaxis,p_izq(2,:),'-o','color',colorc,'markerfacecolor',colorc,'linewidth',2); hold on
    plot(logaxis,p_izq(1,:),'-o','color',colord,'markerfacecolor',colord,'linewidth',2);  hold on
    legend('Monkey C', 'Monkey D','location', 'southeast')
    % set(gca,'box','off','xscale','log','yscale','log')
    set(gca,'box','off','xtick',logaxis,'xticklabel',A)
    xlabel('Stimulus Amplitude (degrees of rotation)')
    ylabel('Probability of Answering Left')
end