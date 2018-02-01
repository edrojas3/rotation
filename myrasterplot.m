function [] = myrasterplot(e, spike_id, alignEvent, sorted_trials, xlim)

id = strread(e.ArchivoNEV, '%s','delimiter','.');

% Settings de los marcadores
cool = linspace(0,1,4);
hot = linspace(0,1,8);
markersize = 6;linewidth = 5;

% Alineación a un evento
aligned = selectTrials(e,'alignEvent',alignEvent);
    
% rasterplot

% for s = 1:length(spike_id)

     rasterplot({aligned.spikes(sorted_trials).(spike_id)},'color','k');

    % Marcas de los eventos
    [xm, ym] = getmarkers(aligned.events,sorted_trials,...
                                           'manosFijasIni',...  1
                                           'manosFijasFin',...  2
                                           'waitCueIni',...     3
                                           'waitCueFin',...     4
                                           'touchIni',...       5
                                           'movIni',...         6
                                           'movFin',...         7
                                           'touchFin',...       8
                                           'touchCueIni',...    9
                                           'touchCueFin',...    10
                                           'waitRespIni',...    11
                                           'waitRespFin',...    12
                                           'targOn',...         13
                                           'targOff');          %14

  
    line(xm(:,3), ym,'linestyle','none','linewidth',linewidth,'color',[0,cool(1),1],'marker','.','markersize',markersize);
    line(xm(:,1), ym,'linestyle','none','linewidth',linewidth,'color',[0,cool(2),1],'marker','.','markersize',markersize);
    line(xm(:,9), ym,'linestyle','none','linewidth',linewidth,'color',[0,cool(3),1],'marker','.','markersize',markersize);
    line(xm(:,2), ym,'linestyle','none','linewidth',linewidth,'color',[0,cool(4),1],'marker','.','markersize',markersize);
    line(xm(:,5), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(1),0],'marker','.','markersize',markersize);
    line(xm(:,6), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(2),0],'marker','.','markersize',markersize);
    line(xm(:,7), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(3),0],'marker','.','markersize',markersize);
    line(xm(:,10), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(4),0],'marker','.','markersize',markersize);
    line(xm(:,8), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(5),0],'marker','.','markersize',markersize);
    line(xm(:,13), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(6),0],'marker','.','markersize',markersize);
    %line(xm(:,12), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(7),0],'marker','.','markersize',markersize);
    line(xm(:,14), ym,'linestyle','none','linewidth',linewidth,'color',[1,hot(8),0],'marker','.','markersize',markersize);
    
   

    
    set(gca,'xlim',xlim,'ylim',[1,length(ym)+1],'color','w')
    
% end
