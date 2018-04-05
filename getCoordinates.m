function coordinateList = getCoordinates(idlist, matdir)

coordenadas =[];
for f = 1:length(idlist)
    id = idlist{f}(1:11);
    load([matdir,filesep,id])  
    canulas = repmat(e.canulas.coordenadas(1:2),3,1);
    electrodos = [(e.electrodos.profundidad - e.electrodos.corteza)/ 1000]';
    coordenadas = [coordenadas; canulas,electrodos];
end


x = []; y = []; z = [];
for f = 1:length(idlist)
   id = idlist{f}(1:11);
   spikeid = idlist{f}(12:end);
   channel = str2num(spikeid(end-1));
   switch channel
       case 3
           channel = 2;
       case 5
           channel = 3;
   end
   unit = str2num(spikeid(end));
   
   load([matdir,filesep,id])
   
   x(f) = e.canulas.coordenadas(1);
   y(f) = e.canulas.coordenadas(2);
   
   calib2zero = e.electrodos.profundidad - e.electrodos.corteza;
   z(f) = calib2zero(channel)/1000;
   
%    coordenadas [x,y,z]
end
    
    
coordinateList = [x',y',z'];

if nargout == 0;
    clf
    plot3(coordinateList(:,1),coordinateList(:,2),coordinateList(:,3), '.k'); hold on
    xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
    set(gca,'zdir','reverse')
    grid on
    axis square
end