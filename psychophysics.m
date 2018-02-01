function [logaxis, pLeft] = psychophysics(matdir)
% Gets the performance of all the files within a directory (matdir) to plot
% the psychophysics curve separated by monkey.

files = dir([matdir,'\*.mat']);
A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = sort([-A,A]);
R = cell(2,length(A));

% Pooling monkeys' choices
for f = 1:length(files)
    load([matdir,'\',files(f).name])
    monkey = files(f).name(1);
    session_angs = [e.trial.rotationAngle];
    session_angs = round(session_angs*10) / 10;
    for angle = 1:length(A)
        selected_angle = session_angs == A(angle);
        choice = [e.trial(selected_angle).choice]';
        if monkey == 'd';
            R{1,angle} = [R{1,angle}; choice];
        else
            R{2,angle} = [R{2,angle}; choice];
        end
        
    end
end

%% Probability of answering 'left'
pLeft = zeros(2,length(A));

for r = 1:length(R)
   n1 = length(R{1,r}) ;
   n2 = length(R{2,r}) ;
   left_resps1 = R{1,r} == 1;
   left_resps2 = R{2,r} == 1;
   pLeft(1,r) = sum(left_resps1)/n1;
   pLeft(2,r) = sum(left_resps2)/n2;
end

%% Plot 
clf
logaxis=[-log(abs(A(1:6))),log(A(7:end))];
colord = [4/255,118/255,217/255];
colorc = [243/255,74/255,83/255];

plot(logaxis,pLeft(2,:),'-o','color',colorc,'markerfacecolor',colorc,'linewidth',2); hold on
plot(logaxis,pLeft(1,:),'-o','color',colord,'markerfacecolor',colord,'linewidth',2);  hold on
legend('Monkey C', 'Monkey D','location', 'southeast')
set(gca,'box','off','xscale','log','yscale','log')
xlabel('Stimulus Amplitude (degrees of rotation)')
ylabel('Probability of Answering Left')