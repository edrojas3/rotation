clc
clear all
close all

tipo = 2;
sesgo = [0.5,0.5];
%tipo: tipo de sesgo a utilizar
        % 0 - sin sesgo
        % 1 - sesgo por lado segun desempeno
        % 2 - sesgo manual por lado, agregar vector sesgo 
            %ejemplo: sesgo = [0.3 0.7] donde el 30% corresponde a negativo
            %y 70% a positivo
        % 3 - sesgo de categoria
        % 4 - lista de pares
        % 5 - sesgo por desempeno por lado
        % 6 - sesgo manual corregido

digital1 = 1; digital2 = 1;
%% Determina cantidad de recompensa y el nombre del archivo a guardar
ml=input('Reward max in ml '); %Cantidad de agua a dar maxima
rewardSteps=6;%input('Reward steps '); %Cantidad de agua a dar
mono = input('Quien es?', 's');
experimento = input('Tipo de experimento (1-Velocidad,2-Angulo,3-Tiempo) ');
% Genera ensayos de prueba
if ml == 99
    ml = 0.3;
    programa = 'test';
    archivoExistente = 'test';
else
%--- Determina si existe un archivo del mismo d�a ----
    %y asigna nombre al archivo del d�a
    terminar = 0;
    i = 1;
    while terminar == 0
        ii = num2str(i);
        archivoExistente = [date,'-',ii,mono,'.mat'];
        i = i + 1;
        evalin('base', ['exist ',archivoExistente, ';'])
        if ans == 0 %#ok<NOANS>
            terminar = 1;
        end
    end
    programa = mfilename('fullpath');
    archivoExistente %#ok<*NOPTS>
    clear i terminar ii ans
end
mlList = linspace(0.03,ml,rewardSteps); rewardCount = 1;
%%
init6
%showRobot5(robot,999); %manda el robot a inic (lejos del mono)
%showRobot3(robot,998); %cerca del mono

%% ANGULOS A PRESENTAR
switch experimento
    case 1
        if mono == 'c'
            posiblesAngulosI = [0,-4,4]; %angulos iniciales
            posiblesAngulosF = [0.5,-0.5,1.5,-1.5,6,-6,-12,12];%[0.6,-0.6,2,-2,6,-6,12,-12];%,4,-4,8,-8,16,-16];
            anguloTargets = [0 45 -45 60 -60 90 -90 -135 135 -180 180];%
            vels = [800];
            posiblesTiempos = calcTiempo(unique(abs(posiblesAngulosF)),vels);
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
            %tipo = 4;
        elseif mono == 'd'
            posiblesAngulosI = [0,-4,4]; %angulos iniciales
%           posiblesAngulosF =  [-6,6,2,-2,10,-10,3,-3];
           % posiblesAngulosF = [0.3,-0.29,-0.71,-0.3,0.7,-0.7,4,-4,-8,8,7.9,11.9,12,-12]
            posiblesAngulosF = [0.3,-0.3,0.8,-0.8,2,-2,6,-6,12,-12]; %[-0.3,0.3,-0.8,0.8,2,-2,-4,4,-10,10];
            anguloTargets = [0 45 -45 60 -60 90 -90 -135 135 -180 180];%
            vels = [800];
            posiblesTiempos = calcTiempo(unique(abs(posiblesAngulosF)),vels);
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
            %tipo = 4;
        else
            error('Mono incorrecto');
        end
    case 2
        % Set de angulos iniciales y finales (i.e. rotacion)
        if mono == 'c'
            posiblesAngulosI = [-4, 0, 4]; %angulos iniciales
            posiblesAngulosF = [-2,2];%[-8, 8, -2, 2,32,-32];%, -1, -2, -4]; %[-50 50 16 -16 0];
            anguloTargets = [0 45 -45 90 -90 -135 135 -180 180]; %[0 -45 45 90 -90 -135 135 -180 180 0]%-90 90 -100 100 -110 110];% [-180, -135, -90,-45, -30 ,30, 45,90, 135, 180];
            vels = [calculoVelocidad(max(posiblesAngulosF),2), 500, 1000, 2500];
            %vels = [500,1000,2500];
            posiblesTiempos = calcTiempo(unique(abs(posiblesAngulosF)),vels);
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
        elseif mono == 'd'
            posiblesAngulosI = [-4, 0, 4]; %angulos iniciales
            posiblesAngulosF = [-4,4];%[-8, 8, -2, 2,32,-32];%, -1, -2, -4]; %[-50 50 16 -16 0];
            anguloTargets = [0 45 -45 90 -90 -135 135 -180 180]; %[0 -45 45 90 -90 -135 135 -180 180 0]%-90 90 -100 100 -110 110];% [-180, -135, -90,-45, -30 ,30, 45,90, 135, 180];
            vels = [calculoVelocidad(max(posiblesAngulosF),2), 500, 1000, 2500];
            posiblesTiempos = calcTiempo(unique(abs(posiblesAngulosF)),vels);
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
        else
            error('Mono incorrecto');
        end
    case 3
        if mono == 'd'
            posiblesAngulosI = [-8,-4,4,8]; %angulos iniciales
            posiblesAngulosF = [-8,-4,-2,2,4,8,-16,16];%[-8, 8, -2, 2,32,-32];%, -1, -2, -4]; %[-50 50 16 -16 0];
            anguloTargets = [0 45 -45 90 -90 -135 135 -180 180]; %[0 -45 45 90 -90 -135 135 -180 180 0]%-90 90 -100 100 -110 110];% [-180, -135, -90,-45, -30 ,30, 45,90, 135, 180];
            posiblesTiempos = 1.1;
            angulos = (unique(abs(posiblesAngulosF)));
            vels = calculoVelocidad(angulos,posiblesTiempos)
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
        else
            posiblesAngulosI = [-8,-4,4,8]; %angulos iniciales
            posiblesAngulosF = [-2,2,-3,3,-8,8,-16,16];%[-8, 8, -2, 2,32,-32];%, -1, -2, -4]; %[-50 50 16 -16 0];
            anguloTargets = [0 45 -45 90 -90 -135 135 -180 180]; %[0 -45 45 90 -90 -135 135 -180 180 0]%-90 90 -100 100 -110 110];% [-180, -135, -90,-45, -30 ,30, 45,90, 135, 180];
            posiblesTiempos = 1.1;
            angulos = (unique(abs(posiblesAngulosF)));
            vels = calculoVelocidad(angulos,posiblesTiempos)
            sesgoCat = [];
            pesoRecompensa = [0.5,0.5];
        end
    otherwise
        error('Numero de experimento incorrecto')
end

% Define el tiempo con el que se va a mover el objeto.


%%
posiblesAngulosI = sort(posiblesAngulosI);
posiblesAngulosF = sort(posiblesAngulosF);
posiblesTiempos = sort(posiblesTiempos);

% Define pares de estímulos y su categoría
pares = getParesPosibles(posiblesAngulosI,posiblesAngulosF);
for c = 1:size(pares,1)
   pares(c,3)  = categorization2(pares(c,1),pares(c,2));
end

categorias = unique(sort(pares(:,3)));
if length(sesgoCat) < length(categorias)
    warning('sesgoCat overwritten');
    sesgoCat = ones(1,length(categorias));
end


results = zeros(1,11); % Inicia la matriz de los resultados

% Otras variables que en algun momento se utilizan... o no... ¿?
previosCorrectos =  [-1 1];

%inicializacion de variables necesarias
ensayo = 1; anguloInicial = 0; anguloNuevo = 0; askNext = 0; nextAng = 0; rewardtime = 0; catPointer = 1; paresDisponibles = pares; %lista de pares disponibles
paresDisponiblesOut = paresDisponibles;
posicionesFinales = unique(pares(:,1) + pares(:,2));
posicionesFinales = posicionesFinales';
probIzqIni = zeros(size(posiblesAngulosI));
probIzqRot = zeros(size(posiblesAngulosF));
probIzqFin = zeros(size(posicionesFinales));
nIzqRot = zeros(size(posiblesAngulosF));
cIzqRot = zeros(size(posiblesAngulosF));
newStims = 1;
ensayoAbortado = 0;
grafLim1 = 1, grafLim2 = 1; % Ensayo a partir del cual se va a graficar el desempeno. 
category = 1;
vel =1;
%% Figura y handles de las graficas para desmplegar desempeno en linea 

% Abrir figura para desplegar desempeño
f = figure(1); 
set(gcf, 'KeyPressFcn', 'keypress', 'position', [75 1 1846 994]);

%% Graf 1 subplot(231) probabilidad de contestar izquierda

% Plot
graf1 = subplot(241) 

% Setup general
set(gca, 'ylim', [-0.09 1.01],...
    'xlim',[min(posiblesAngulosF)-1,max(posiblesAngulosF)+1],...
'xtick',unique(posiblesAngulosF));

% Despliega set de estimulos del ensayo actual
titleG1 = title(['inicial: ', num2str(anguloInicial), ' rotacion: ', num2str(anguloNuevo), ' final: ' num2str(anguloInicial + anguloNuevo)])
hold on

% Probabilidad de contestar izquierda dependiendo del angulo de rotacion
plotRot = plot(posiblesAngulosF, probIzqRot, 'ob',...
    'markerfacecolor','b',...
    'markeredgecolor','c',...
    'markersize',10);

% Probabilidad de contestar izquierda dependiendo del angulo inicial
plotIni = plot(posiblesAngulosI,probIzqIni, 'or',...
    'markerfacecolor','r');

% Probabilidad de contestar izquierda dependiendo de la posicion final
plotFin = plot(posicionesFinales, probIzqFin,'og',...
    'markerfacecolor','g');

%legend('Angulo Rotado','Angulo Inicial', 'Posicion final','location','southeast');

% Textos que indican el numero de presentaciones y respuestas correctas por
% cada angulo de rotacion
txtsG1 = zeros(size(posiblesAngulosF));
for i = 1:length(posiblesAngulosF)
    txtsG1(i) = text(posiblesAngulosF(i)+1.5,probIzqRot(i),... % posicion xy
        [num2str(cIzqRot(i)),'/',num2str(nIzqRot(i))],... % texto a desplegar
        'HorizontalAlignment','center',...
        'fontsize',8); % Alineacion del texto
end
xlabel('Angulo')
ylabel('Probabilidad de contestar azul (+)')

%% Graf 2 subplot(232) desempeno por tipo de ensayo

%Plot
graf2 = subplot(242)%sin setup inicial

% Variables de inicio
% Datos: d = prob de contestar bien, n = num de ensayos, c = num de correctos
d = zeros(size(categorias));
n = zeros(size(categorias));
c = zeros(size(categorias));

% Guarda en celdas las etiquetas de las categorias que se van a usar durante la tares
leyendasGraf2 = categoryLegends(categorias); 

% Setup general
set(gca,'xticklabel',leyendasGraf2,...
    'ylim', [0 1],...
    'xlim',[0 length(categorias)+1],...
    'xtick', [1:length(categorias)]) % Pone etiquetas descriptivas por tipo de ensayo en lugar de numero

hold on

plotCat = bar(1:length(categorias),d); % grafica

% Textos que indican el numero de veces que se ha presentado cada categoria
% y el numero de respuestas correctas
xpoints = get(graf2,'xtick'); % donde los va a escribir

txtsG2 = zeros(size(xpoints));
for i = 1:length(xpoints) % loop para escribir el texto 'correctos/num de ensayos'
    if iseven(i); % intercala posicion de texto para que no se encime y sea legible.
        yposition = 0.3;
    else
        yposition = 0.1; 
    end
   txtsG2(i) = text(xpoints(i)-0.1, yposition, ['\bf', num2str(c(i)) '/' num2str(n(i))],'color','r'); 
end

% Despliega la categoria del ensayo actual
titleG2 = title('abc')
ylabel('Probabilidad de contestar correctamente')

%% Graf 3 subplot(223) Desempeno por cada velocidad
graf3 = subplot(243)
% Variables de inicio
probVelMean = zeros(size(vels));
probVelDer = zeros(size(vels));
probVelIzq = zeros(size(vels));

% Plot

% Despliega la velocidad del ensayo actual
titleG3 = title(num2str(0));
hold on

% Limites de los ejes
set(gca,'ylim',[0,1]);

% desempeno promedio
velMean = plot(vels.*(1/92),probVelMean,'-or',...
    'markerfacecolor','r',...
    'markersize',8);

% Desempeno por rotaciones a la izquierda
velIzq = plot(vels.*(1/92),probVelMean,'-ob',...
    'markerfacecolor','b',...
    'markersize',8);

% Desempeno por rotaciones a la derecha
velDer = plot(vels.*(1/92),probVelDer,'-oy',...
    'markerfacecolor','y',...
    'markeredgecolor', 'k',...
    'markersize',8);

xlabel('Velocidad �/s')
ylabel('Probabilidad de contestar correctamente')

%% Graf 4 subplot(234) desempeno por duracion del estimulo
% Plot
graf4 = subplot(244)
% Despliega la velocidad del ensayo actual
titleG4 = title(num2str(0));
hold on

probTMean = zeros(size(posiblesTiempos));
probTDer = zeros(size(posiblesTiempos));
probTIzq = zeros(size(posiblesTiempos));

% Limites de los ejes
set(gca,'ylim',[0,1]);

% desempeno promedio
tMean = plot(posiblesTiempos,probTMean,'-or',...
    'markerfacecolor','r',...
    'markersize',8);

% Desempeno por rotaciones a la izquierda
tDer = plot(posiblesTiempos,probTDer,'-oy',...
    'markerfacecolor','y',...
    'markeredgecolor','k',...
    'markersize',8);

% Desempeno por rotaciones a la derecha
tIzq = plot(posiblesTiempos,probTIzq,'-ob',...
    'markerfacecolor','b',...
    'markeredgecolor', 'k',...
    'markersize',8);

xlabel('Duracion del estimulo (s)')
ylabel('Probabilidad de contestar correctamente')
%% Graf 5 subplot(235) Datos generales
%SI SE CAMBIA AQUI, TAMBIEN CAMBIAR updateG5
graf5 = subplot(245);
titleG5 = title(['Ensayos completados:', num2str(0)]);
hold on
ejeY = [0,1];
% Limites de los ejes
set(gca,'ylim',[ejeY(1)-0.1,ejeY(2)+0.1]);
set(gca,'xlim',[0,1]);
set(gca, 'XColor', [0.5,0.5,0.5])
set(gca, 'YColor', [0.5,0.5,0.5])

infoG5 = {};
infoG5{1} = 'Angulo inicial: ';
infoG5{2} = 'Rotacion: ';
infoG5{3} = 'Categoria: ';
infoG5{4} = 'Velocidad: ';
infoG5{5} = 'Sesgo: ';
infoG5{6} = 'Siguiente angulo: ';
infoG5{7} = 'Siguiente velocidad: ';
infoG5{8} = 'Recompensa: ';
infoG5{9} = 'Sesgos cat'
infoG5{10} = 'Sesgos cat'
infoG5{11} = 'Tipo de sesgo: '
infoG5{12} = 'Graf desde: '
ypoints = fliplr(linspace(ejeY(1),ejeY(2),length(infoG5)));
txtsG5 = zeros(1,length(infoG5));
for i = 1:length(infoG5) % loop para escribir el texto 'correctos/num de ensayos'
   txtsG5(i) = text(0.1, ypoints(i), infoG5{i},'color','k', 'FontSize', 8); 
end
%% Graf 6 subplot(236) Linea temporal

graf6 = subplot(246);
titleG6 = title(num2str(0));
hold on

% Limites de los ejes
velsSigno = (sort([vels,vels.*-1])).*(1/92);
set(gca,'ylim',[velsSigno(1)-1,velsSigno(end)+1]);

% desempeno promedio

plotsG6 = zeros(1,length(velsSigno));
for i = 1:length(velsSigno)
    if velsSigno(i) < 0
        plotG6c(i) = plot(0,velsSigno(i), 'oy', 'MarkerFaceColor', 'y');
        plotG6i(i) = plot(0,velsSigno(i), '*y');
    else
        plotG6c(i) = plot(0,velsSigno(i), 'ob', 'MarkerFaceColor', 'b');
        plotG6i(i) = plot(0,velsSigno(i), '*b');
    end
end
% Si fuera necesario un legend adicional --------------------
% for i = 1:length(plotG6)
%     legendG6{i} = num2str(round(velsSigno(i).*10)./10);
% end
% legend(legendG6,'location','southeast');
% --------------------------------------------------------------
set(gca, 'Color', 'k')
xlabel('Ensayo')
ylabel('Velocidad �/s')
%% Grafica 7: 
graf3 = subplot(247);
desempPorPar = getDesempenoPorPar2b(results,pares);
desempPorPar(:,6) = round(desempPorPar(:,4)*100);


set(gca,'xlim',[min(posiblesAngulosI)-2, max(posiblesAngulosI)+2],...
    'ylim',[min(posiblesAngulosF)-1, max(posiblesAngulosF)+1],...
    'xtick',linspace(min(posiblesAngulosI),max(posiblesAngulosI),length(posiblesAngulosI)),...
    'ytick',linspace(min(posiblesAngulosF),max(posiblesAngulosF),length(posiblesAngulosF)),...
    'xticklabel',posiblesAngulosI,...
    'yticklabel',posiblesAngulosF);
line([0 0], [min(posiblesAngulosF),max(posiblesAngulosF)]);
line([min(posiblesAngulosI),max(posiblesAngulosI)],[0,0]);
xcoord = get(gca,'xtick');
ycoord = get(gca,'ytick');
coordenadas = getParesPosibles(xcoord,ycoord);

for i = 1:size(desempPorPar,1);
    txtsG7(i) = text(coordenadas(i,1),coordenadas(i,2),num2str(desempPorPar(i,6)),'FontSize',7);                
end

par = 1;

ylabel('Angulo final')
xlabel('Angulo inicial')
%% Grafica 8
graf8 = subplot(248);
titleG8 = title(num2str(0));
hold on

% Limites de los ejes
angulosSignos = (sort([posiblesAngulosF]));
set(gca,'ylim',[angulosSignos(1)-1,angulosSignos(end)+1]);

% desempeno promedio
plotsG6 = zeros(1,length(angulosSignos));
for i = 1:length(angulosSignos)
    if angulosSignos(i) < 0
        plotG8c(i) = plot(0,angulosSignos(i), 'oy', 'MarkerFaceColor', 'y');
        plotG8i(i) = plot(0,angulosSignos(i), '*y');
    else
        plotG8c(i) = plot(0,angulosSignos(i), 'ob', 'MarkerFaceColor', 'b');
        plotG8i(i) = plot(0,angulosSignos(i), '*b');
    end
end
set(gca, 'Color', 'k')
xlabel('Ensayo')
ylabel('Velocidad �/s')
%% graficas

tightfig
pause(0.5)
set(gcf, 'position', [75 1 1846 994]);

%% Control de eventos de la tarea

tic
while true
    x = 0;
    y = 0;
    voltaje(x,y,ao);
    valor = ranalog(ai);
    switch valor
        case -1
            if ensayo>1; % Por cuestiones de orden de aparicion y reinicio de las variables, se ignoran los abortos hasta que no se complete por lo menos un ensayo.
               ensayoAbortado = 1; %Reinicio de la variable que indica que el ensayo se aborto. Se cambia a 0 cuando se completa un ensayo.
            end
               
            if newStims; % Si el ensayo anterior se completo, se seleccionan estimulos; si el ensayo se aborto se repiten los mismos. 
                set(txtsG7(par),'color','k') %devuelve a negro el par
                %eleccion manual de velocidad a traves de keypress
                if experimento == 3
                    [anguloInicial, anguloNuevo, category, vel] = defStims5(results,pares,vels,tipo,sesgo,sesgoCat,posiblesTiempos);
                else
                    if tipo == 4
                        [paresDisponiblesOut, parSel] = getPar(pares,paresDisponibles)
                        anguloInicial = parSel(1);
                        anguloNuevo = parSel(2);
                        category = parSel(3);
                        vel = vels;
                    else
                        if askNext == 0 
                            [anguloInicial, anguloNuevo, category, vel] = defStims4(results,pares,vels,tipo,sesgo,sesgoCat);
                        else
                            [anguloInicial, anguloNuevo, category, ~] = defStims4(results,pares,vels,tipo,sesgo,sesgoCat);
                            if experimento == 1
                                posAngulos = sort(unique(abs(posiblesAngulosF)));
                                anguloNuevo = posAngulos(askNext);
                            else
                                vel = vels(askNext);
                            end
                            askNext = 0;
                        end
                    end
                end
                %eleccion manual de angulo a traves de keypress
                if nextAng ~= 0 
                    anguloNuevo = abs(anguloNuevo) * nextAng;
                    category = categorization2(anguloInicial,anguloNuevo);  %correcion de category
                    nextAng = 0;
                end
                tiempo = calcTiempo(anguloNuevo,vel); %calculo del tiempo correspondiente
            end
            
            set(titleG1,'string',['inicial: ', num2str(anguloInicial), ' rotacion: ', num2str(anguloNuevo), ' final: ' num2str(anguloInicial + anguloNuevo)])
            stringCategoria = categoryLegends(category);
            set(titleG2,'string',stringCategoria{1});
            set(titleG3,'string',num2str(vel*(1/92)));
            set(titleG4,'string',['sesgo neg = ',num2str(sesgo(1)), ' sesgo pos = ', num2str(sesgo(2))]);
            par = find(pares(:,1) == anguloInicial & pares(:,2) == anguloNuevo); %obtencion de par para marcar en plot 7
            set(txtsG7(par),'color','r') %marca en rojo para plot7
            updateG5 %actualiza G5
            sendToBlackRock(dioBlackRock,anguloInicial,'angle') %sends data to BLACKROCK

            rotateRobot3(robot,anguloInicial,10000);

            while valor == -1
                valor = ranalog(ai);
                pause(0.001);
            end

        case 1 %girar obj
            'Girar obj'
            
            sendToBlackRock(dioBlackRock,anguloNuevo,'angle') %sends data to BLACKROCK
            
            sendToBlackRock(dioBlackRock,vel,'vel'); %sends data to BLACKROCK
            
            putsample(ao,[4,4])
            rotateRobot3(robot,anguloInicial+anguloNuevo, vel);
            delayfinal = rand*.2+.4;
            pause(delayfinal)
            putsample(ao,[-4,-4])
            pause(0.2)
                       
            x = 0;
            y = 0;
            voltaje(x,y,ao);
            
            if sign(anguloNuevo) == -1
                %changestate2(dio,0);
                changestateAO(ao2,0);
                digital2 = 0;
            elseif sign(anguloNuevo) == 1
                %changestate2(dio,1);
                changestateAO(ao2,1);
                digital2 = 1;
            else
                warning('Signo incorrecto');
                changestateAO(ao2,1);
                digital2 = 1;
                anguloNuevo = pares(1,2);
                anguloNuevo = pares(1,1);
                category = pares(1,3);
                vel = vels(1);
            end
            
            angTarget = randsample(anguloTargets,1);
            sendToBlackRock(dioBlackRock,angTarget,'angle');
            [x1,y1,x2,y2] = deg2cartTable(angTarget,6); %genera las coordenadas del target
            putsample(ao,[-x1,-y1]); %envia las coordenadas a Expo

            while valor == 1 
                valor = ranalog(ai);
                pause(0.001);
            end
            x = 0;
            y = 0;
            voltaje(x,y,ao);
            
        case 2 % Leer y mandar coordenadas
            pause(0.005);
            valor = ranalog(ai);
            if valor ~= 2
                
            else
                
                terminar2 = 2;

                changestate(dio,1);
                while (ranalog(ai) == 2)
                    disp('entra')
                    WaitSecs(0.001);
                    %'Recibiendo -0'
                    %Verifica constantemente si se emiti� la respuesta
                    %Si la respuesta fue emitida, se emiten x y
                    if ranalog(ai) == 2
                        [abortar,x,y] = getanswer14(0,ai); %lee la posicion del mouse
                    end
                    voltaje(x,y,ao); %envia el voltaje a Expo
                    sendToBlackRock(dioBlackRock,x,'vel');
                    pause(0.001)
                    sendToBlackRock(dioBlackRock,y,'vel');

                end
                if digital1
                    digital1 = 0;
                    changestate(dio,0);
                end
            end
            
        case 3 %recompensa, guarda y grafica
        %% Recibe respuesta y da recompensa
            respuesta = 0;
            while respuesta == 0
                respuesta = ranalog2(ai);
                pause(0.001);
                valor = ranalog(ai);
                if valor == 0
                    break
                end
            end
            
            mulReward = calcularReward2(anguloNuevo,pesoRecompensa);
            
            if respuesta == sign(anguloNuevo) %si la respuesta fue correcta, da recompensa y agrega un contador a los correctos
                rewardtime=  mulReward*ml*0.36*3*2;
                reward(dio,rewardtime);
            end
            previosCorrectos(2) = previosCorrectos(1);
            previosCorrectos(1) = respuesta;
           
            sendToBlackRock(dioBlackRock,respuesta,'response');
            
            %Guarda algunos datos usados para los calculos posteriores
            results(ensayo,1) = anguloNuevo; %angulo que se presento
            results(ensayo,2) = respuesta; %respuesta 
            results(ensayo,3) = respuesta == sign(anguloNuevo); %acierto o error de la respuesta
            results(ensayo,4) = anguloInicial; %angulo en que se encontraba el objeto al inicio del ensayo
            results(ensayo,5) = angTarget;
            results(ensayo,8) = tiempo;
            results(ensayo,9) = vel;
            results(ensayo,10) = category;
            results(ensayo,11) = anguloInicial+anguloNuevo;
            
            %% Ensayo de inicio de las graficas.
            
            % grafLim1 es el numero de ensayo apartir del cual se va agraficar el desempelno.
            % grafLim1 se puede modificar mientras se entrena al mono. Ver la funcion keypress que
            % utiliza la figura.
            %
            % Al presionar las siguientes teclas grafLim1 se modifica:
            % q = grafLim1 -1; 
            % w = grafLim1 +1;
            % e = grafLim1 = ensayo; Selecciona el ensayo actual como el inicio de la grafica. 
            % E = grafLim1 = 1; Regresa el inicio al primer ensayo.
            
            % Por si picas de mas los botones... ha pasado.
%             if grafLim1 < 1;
%                 grafLim1 = 1;
%             elseif grafLim1 > size(results,1);
%                 grafLim1 = size(results,1);
%             end
            
            % Se grafica limResults en lugar de results. limResults es la
            % matriz de resultados delimitada por grafLim1.
            limResults = results(grafLim1:end,:);
            
            %% Grafica 1: Probabilidad de contestar izquierda
            
            %Probabilidad de contestar izquierda en funcion del
            %angulo de inicio
            
            for i=1:length(posiblesAngulosI)
               signoResp = limResults(limResults(:,4) == posiblesAngulosI(i),2);
               izqResp = signoResp == 1;
               probIzqIni(i) = mean(izqResp);
            end
            probIzqIni(isnan(probIzqIni)) = 0;

            %Probabilidad de contestar izquierda en funcion de
            %la rotacion
            for i=1:length(posiblesAngulosF)
               signoResp = limResults(limResults(:,1) == posiblesAngulosF(i),2);
               izqResp = signoResp == 1;
               probIzqRot(i) = mean(izqResp);
               nIzqRot(i) = length(izqResp);
               corrCol = limResults(limResults(:,1)==posiblesAngulosF(i),3);
               cIzqRot(i) =sum(corrCol);
            end
            probIzqRot(isnan(probIzqRot)) = 0;
            
            %Probabilidad de contestar izquierda en funcion de
            %la posicion final
            for i=1:length(posicionesFinales)
                signoResp = limResults(limResults(:,11)==posicionesFinales(i),2);
                izqResp = signoResp == 1;
                probIzqFin(i) = mean(izqResp);
            end
            probIzqFin(isnan(probIzqFin)) = 0;
            
            % Plots
            set(plotIni,'ydata',probIzqIni)
            set(plotRot,'ydata',probIzqRot)
            set(plotFin,'ydata',probIzqFin) 
            
            % Textos: corrects/n
            for i = 1:length(txtsG1) % loop para escribir el texto 'correctos/num de ensayos'
                posicion = get(txtsG1(i),'position');
                posicion  = [posicion(1), probIzqRot(i), 0];
                set(txtsG1(i),'string',[num2str(cIzqRot(i)) '/' num2str(nIzqRot(i))],...
                   'position', posicion);
            end
 
            %% Grafica 2
            
            %hold on
%             category = categorization(anguloInicial,anguloNuevo);
%             categories(category) = categories(category) + 1;
%             
            categories(ensayo) = categorization2(anguloInicial,anguloNuevo); %#ok<*SAGROW>
            categoryTypes = unique(categories);
            performanceByCategory = [];
            
            for i=1:length(categorias)
               catResults = limResults(limResults(:,10) == categorias(i), 3);
               desempCategoria(i) = mean(catResults);
                n(i) = length(catResults);
                c(i) = sum(catResults);
            end
            
            set(plotCat,'ydata',desempCategoria);
            
            for i = 1:length(txtsG2) % loop para escribir el texto 'correctos/num de ensayos'
                set(txtsG2(i),'string', [num2str(c(i)) '/' num2str(n(i))]) 
            end
            
           %% Grafica 3
            
            % media
            for i = 1:length(vels);
               velocidad = limResults(limResults(:,9) == vels(i),3);
               probVelMean(i) = mean(velocidad);
            end
            probVelMean(isnan(probVelMean)) = 0;
            
            % rotacion a la izquierda
            for i = 1:length(vels);
               velocidad = limResults(limResults(:,9) == vels(i),:);
               izq = velocidad(velocidad(:,1) > 0, 3);
               probVelIzq(i) = mean(izq);
            end
            probVelIzq(isnan(probVelIzq)) = 0;
            
            % Desempeño con rotación a la derecha
            for i = 1:length(vels);
               velocidad =limResults(limResults(:,9) == vels(i),:);
               der = velocidad(velocidad(:,1) < 0, 3);
               probVelDer(i) = mean(der);
            end
            probVelDer(isnan(probVelDer)) = 0;
            
            set(velMean,'ydata',probVelMean);
            set(velIzq,'ydata',probVelIzq);
            set(velDer,'ydata',probVelDer);
            
             %% Grafica 4 tiempo
           for i = 1:length(posiblesTiempos)
                tiempoMIdx = find(round(limResults(:,8).*1000) == round(posiblesTiempos(i).*1000));
                probTMean(i) = mean(limResults(tiempoMIdx,3));
            end
             probTMean(isnan(probTMean)) = 0;
             
             % rotacion a la izquierda
            for i = 1:length(posiblesTiempos);
               tiempoIdx = round(limResults(:,8).*1000) == round(posiblesTiempos(i).*1000);
               izq = (limResults(:,1) > 0);
               filtro = find(tiempoIdx.*izq);
               probTIzq(i) = mean(limResults(filtro,3));
            end
            probTIzq(isnan(probTIzq)) = 0;
            
                         % rotacion a la izquierda
            for i = 1:length(posiblesTiempos);
               tiempoIdx = round(limResults(:,8).*1000) == round(posiblesTiempos(i).*1000);
               der = (limResults(:,1) < 0);
               filtro = find(tiempoIdx.*der);
               probTDer(i) = mean(limResults(filtro,3));
            end
            probTDer(isnan(probTIzq)) = 0;
             
            % actualizacion de grafica
            set(tMean,'ydata',probTMean);
            set(tIzq,'ydata',probTIzq);
            set(tDer,'ydata',probTDer);
%%                       

            %% Grafica 5
            set(titleG5, 'string', ['Ensayos completados:', num2str(ensayo)]);
            %% Grafica 6
            ventana = 50;
            for i = 1:length(velsSigno)
                ensayoTmp = find(sign(results(:,1)).*results(:,9) == velsSigno(i)*92);
                ensayoC = 0;
                ensayoI = 0;
                for j = 1:length(ensayoTmp)
                    if results(ensayoTmp(j),3)
                        ensayoC = [ensayoC,ensayoTmp(j)];
                    else
                        ensayoI = [ensayoI,ensayoTmp(j)];
                    end
                end
                set(plotG6c(i), 'ydata', velsSigno(i).*ones(1,length(ensayoC)), 'xdata', ensayoC);
                set(plotG6i(i), 'ydata', velsSigno(i).*ones(1,length(ensayoI)), 'xdata', ensayoI);   
            end
            %zooms on axis
            if length(results(:,9)) > ventana
                axis(graf6,[length(results(:,9))-ventana,length(results(:,9))+1,min(velsSigno)-1,max(velsSigno)+1]);
            else
                axis(graf6,[0,length(results(:,9))+1,min(velsSigno)-1,max(velsSigno)+1])
            end
            %% Grafica 7
            desempPorPar = getDesempenoPorPar2b(limResults,pares);
            desempPorPar(:,4) = round(desempPorPar(:,4)*100);

            for i = 1:length(txtsG7);
                set(txtsG7(i),'string',[num2str(round((desempPorPar(i,5).*desempPorPar(i,4))./100)),'/',num2str(desempPorPar(i,5))]);                
            end
             %% Grafica 8
            ventana = 50;
            for i = 1:length(angulosSignos)
                ensayoTmp = find(results(:,1) == angulosSignos(i));
                ensayoC = 0;
                ensayoI = 0;
                for j = 1:length(ensayoTmp)
                    if results(ensayoTmp(j),3)
                        ensayoC = [ensayoC,ensayoTmp(j)];
                    else
                        ensayoI = [ensayoI,ensayoTmp(j)];
                    end
                end
                set(plotG8c(i), 'ydata', angulosSignos(i).*ones(1,length(ensayoC)), 'xdata', ensayoC);
                set(plotG8i(i), 'ydata', angulosSignos(i).*ones(1,length(ensayoI)), 'xdata', ensayoI);   
            end
            %zooms on axis
            if length(results(:,9)) > ventana
                axis(graf8,[length(results(:,1))-ventana,length(results(:,1))+1,min(angulosSignos)-1,max(angulosSignos)+1]);
            else
                axis(graf8,[0,length(results(:,1))+1,min(angulosSignos)-1,max(angulosSignos)+1])
            end
            %% Guardado
            voltStamp = getsample(ai);
            voltStamp = voltStamp(2);
            results(ensayo,1) = anguloNuevo; %angulo que se presento
            results(ensayo,2) = respuesta; %respuesta 
            results(ensayo,3) = respuesta == sign(anguloNuevo); %acierto o error de la respuesta
            results(ensayo,4) = anguloInicial; %angulo en que se encontraba el objeto al inicio del ensayo
            results(ensayo,5) = angTarget;
            results(ensayo,6) = voltStamp;
            results(ensayo,7) = toc;
            results(ensayo,8) = tiempo;
            results(ensayo,9) = vel;
            results(ensayo,10) = categorization2(anguloInicial,anguloNuevo);
            
            save(archivoExistente,'results','programa', 'experimento')
            
            paresDisponibles = paresDisponiblesOut;
            %%
           ensayo = ensayo + 1;
           ensayoAbortado = 0;
            x = 0; y = 0; voltaje(x,y,ao); %reinicia el voltaje
           
            while valor == 3 
                pause(0.01);
                valor = ranalog(ai);
            end
            
        case 0
            if ensayoAbortado;
               newStims = 0; 
            else
               newStims = 1;
            end
            
           
            %Volver a leer
            %Cambio salida digital1 a 0
            if digital1
                digital1 = 0;
                changestate(dio,0);
            end
            
        otherwise
            valor;
            %error('Wrong analog reading');
    end
    x = 0;
    y = 0;
    voltaje(x,y,ao);
    pause(0.001);
end
