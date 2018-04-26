function coordinateList = getCoordinates(idlist, matdir)
% Gets a matrix of x (medio-lateral), y (antero-posterior), and z (dorso-ventral) coordinates of the recording sites.
%
% USAGE: coordinateList = (idlist, matdir)
%
% INPUTS
% idlist: is a cell array list (ex. {'c1606071636', 'd1605291014', ...}) or struct (as given by 'dir' function) of
% the matfile names of the recording sessions. In this case all the
% recording sites for every file will be included in the output matrix.
% The cell array can specify spikes ex. {'c1606071636spike13',
% 'd1605291014spike11', ...}. In this case only the specified units will be
% included in the output matrix.
%
% matdir: is the path where the matfiles are located. All the files must be
% in the same directory.
%
% OUTPUTS
% coordinateList: is a matrix with the coordinates in milimeters. For the
% z axis the zero was set at the distance of cortex entrance. 
% **If no output argument is specified, the function will make a 3d plot of
% the recording sites.**

% Transform struct array to cell array
if isstruct(idlist);
    idlist = {idlist.name};
end

% Check if there are spikeids
if length(idlist{1})<18;
    spikes = 0;
else
    spikes = 1;
end


x = []; y = []; z = [];
for f = 1:length(idlist)
    id = idlist{f}(1:11);
    load([matdir,filesep,id])

    if spikes;
        spikeid = idlist{f}(12:18);
        channel = str2double(spikeid(end-1));
        switch channel
           case 3
               channel = 2;
           case 5
               channel = 3;
        end
        x = [x;e.canulas.coordenadas(1)];
        y = [y;e.canulas.coordenadas(2)];
        calib2zero = (e.electrodos.profundidad - e.electrodos.corteza)/1000;
        z = [z;calib2zero(channel)];
    
    else
        x = [x;repmat(e.canulas.coordenadas(1),3,1)];
        y = [y;repmat(e.canulas.coordenadas(2),3,1)];
        calib2zero = (e.electrodos.profundidad - e.electrodos.corteza)/1000;
        z = [z;calib2zero'];
   end
end
    
    
coordinateList = [x,y,z];

if nargout == 0;
    clf
    plot3(coordinateList(:,1),coordinateList(:,2),coordinateList(:,3), '.k'); hold on
    xlabel('lateral-medial'); ylabel('anterior-posterior'); zlabel('depth')
    set(gca,'zdir','reverse')
    grid on
    axis square
end