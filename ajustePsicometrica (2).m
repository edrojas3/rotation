%% Grafica Todas las graficas
clear all
lineWidth = 2; %line of the adjustment
lineWidth2 = 1; %line of the marker
MarkerSize = 8; %size of the marker
addpath('C:\Users\Raul\Google Drive\Exp\Exp mono')
dewey = '09-Apr-2015-1d.mat';
cesar = '20-May-2015-2c.mat'; 
vel = '25-May-2015-3d.mat'
files = {};
files{1} = 'exp01.mat';
files{2} = 'exp02.mat';
files{3} = 'exp03.mat'
colores = {{[207/255 0 91/255]},{[0.25 0.3 1]},{[0.94 0.56 0.08]}};
logplot = 0;

for ii = 1:length(files)
    file = files{ii}
    load(file)
    %
    tam = size(results);
    close all
    figure
    subplot(1,3,1)
    hold all
    [posiblesAngulosF,perfAng,NumPos,OutOfNum] = calcAbsPerformance(results(:,1),results(:,3));
    %[~,~,posiblesAngulosI,perfI] = calcPerformanceBySide2(results(:,1),results(:,3),results(:,4));
    %[~,~,posicionesFinales,perfPos] = calcPerformanceBySide2(results(:,1),results(:,3),results(:,4)+results(:,1));
    if length(posiblesAngulosF) > 1        
        PF = @PAL_Weibull;
        paramsFree = [1 1 1 1]; paramsValues = [5, 1.2, 0.5, 0.05]; stimLevels = (posiblesAngulosF)';
        [paramsValues,LL,exitflag] = PAL_PFML_Fit(stimLevels, NumPos,OutOfNum, paramsValues, paramsFree, PF);
        stimLevels = stimLevels(1):0.1:stimLevels(end);
        outcomes = PAL_Weibull(paramsValues,stimLevels);
    else
        stimLevels = (posiblesAngulosF)'; outcomes = perfAng;
    end
    if logplot
        plot(log(posiblesAngulosF),perfAng, 'o', 'Color', colores{1}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(log(stimLevels),outcomes, '-', 'Color', colores{1}{1}, 'MarkerFaceColor', colores{1}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([log(0),log(20),0.5,1])
    else
        plot(posiblesAngulosF,perfAng, 'o', 'Color', colores{1}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(stimLevels,outcomes, '-', 'Color', colores{1}{1}, 'MarkerFaceColor', colores{1}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([0,20,0.5,1])
    end
    %plot(posiblesAngulosI,perfI, '-or', 'MarkerFaceColor', 'r');
    %plot(posicionesFinales,perfPos, 'g.')
    
    xlabel('Angulo (grados)', 'FontSize', 13)
    ylabel('Probabilidad de acierto', 'FontSize', 13)
    %legend('Movimiento', 'Angulo Inicial', 'Location', 'southeast')
    title('Ángulo', 'FontSize', 13)
    set(gca, 'Ytick', 0.5:0.1:1, 'FontSize', 13)
    %saveas(gcf,'dAngulo.png')
    %saveas(gcf,[num2str(ii), 'Angulo.png'])

    %
    subplot(1,3,2)
    hold
    velSigno = results(:,9) .* sign(results(:,1));

    [velocidades,perfVel,NumPos,OutOfNum] = calcAbsPerformance(velSigno,results(:,3));
    velocidades = velocidades.*(1/92); %conversion tomando en cuenta la funcion calculoVelocidad
    if length(velocidades) > 1        
        PF = @PAL_Weibull;
        paramsFree = [1 1 1 1]; paramsValues = [5, 1.2, 0.5, 0.05]; stimLevels = (velocidades)';
        [paramsValues,LL,exitflag] = PAL_PFML_Fit(stimLevels, NumPos,OutOfNum, paramsValues, paramsFree, PF);
        stimLevels = stimLevels(1):0.1:stimLevels(end);
        outcomes = PAL_Weibull(paramsValues,stimLevels);
    else
        stimLevels = (velocidades)'; outcomes = perfVel;
    end
    
    if logplot
        plot(log(velocidades),perfVel, 'o', 'Color', colores{2}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(log(stimLevels),outcomes, '-', 'Color', colores{2}{1}, 'MarkerFaceColor', colores{2}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([log(0),log(30),0.5,1])
    else
        plot(velocidades,perfVel, 'o', 'Color', colores{2}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(stimLevels,outcomes, '-', 'Color', colores{2}{1}, 'MarkerFaceColor', colores{2}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([0,30,0.5,1])
    end
    xlabel('Velocidad (°/s)', 'FontSize', 13)
    ylabel('Probabilidad de acierto', 'FontSize', 13)
    %legend('Movimiento', 'Angulo Inicial', 'Location', 'southeast')
    title('Velocidad', 'FontSize', 13)
    set(gca, 'Ytick', 0.5:0.1:1, 'FontSize', 13)
    %saveas(gcf,[num2str(ii), 'Velocidad.png'])
    %saveas(gcf,'dVelocidad.png')
    %
    subplot(1,3,3)
    hold on
    
    
    for i = 1:tam(2)
        results(i,8) = calcTiempo(results(i,1),results(i,9));
    end
    [tiempos,perfTiempo,NumPos,OutOfNum] = calcAbsPerformance(results(:,8),results(:,3));
    if 0%length(tiempos) > 1        
        PF = @PAL_Weibull;
        paramsFree = [1 1 1 1]; paramsValues = [0.15, 1.2, 0.5, 0.05]; stimLevels = (tiempos)';
        [paramsValues,LL,exitflag] = PAL_PFML_Fit(stimLevels, NumPos,OutOfNum, paramsValues, paramsFree, PF);
        stimLevels = stimLevels(1):0.1:stimLevels(end);
        outcomes = PAL_Weibull(paramsValues,stimLevels);
    else
        stimLevels = (tiempos)'; outcomes = perfTiempo;
    end
    
    if logplot
        plot(log(tiempos),perfTiempo, 'o', 'Color', colores{3}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(log(stimLevels),outcomes, '-', 'Color', colores{3}{1}, 'MarkerFaceColor', colores{3}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([log(0),log(2),0.5,1])
    else
        plot(tiempos,perfTiempo, 'o', 'Color', colores{3}{1}, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth2, 'MarkerSize', MarkerSize);
        plot(stimLevels,outcomes, '-', 'Color', colores{3}{1}, 'MarkerFaceColor', colores{3}{1}, 'LineWidth', lineWidth, 'MarkerSize', MarkerSize)
        axis([0,2,0.5,1])
    end
    xlabel('Tiempo s', 'FontSize', 13)
    ylabel('Probabilidad de acierto', 'FontSize', 13)
    %legend('Movimiento', 'Angulo Inicial', 'Location', 'southeast')
    title('Tiempo', 'FontSize', 13)
    set(gca, 'Ytick', 0.5:0.1:1, 'FontSize', 13)
   %set(gca, 'Color',[0 0 0], 'YColor', [1 1 1], 'XColor', [1 1 1])
    set(gcf,'Position',[21,378,1565,420])
    saveas(gcf,[num2str(ii), 'final.png'])
    pause()
end