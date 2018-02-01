addpath(genpath('C:\Users\eduardo\Dropbox\rotacion'))
%% Datos iniciales
id = 'd1605030904';


nevData = ['C:\Users\eduardo\Google Drive\Exp mono\',id,'.nev'];
ns1File = ['C:\Users\eduardo\Google Drive\Exp mono\', id, '.ns2'];

% nevData = ['/home/eduardo/Dropbox/rotacion/nevfiles/', id, '.nev'];
% ns1File = ['/home/eduardo/Dropbox/rotacion/nsfiles/', id, '.ns2'];


% obtener los datos de cada ensayo a partir del archivo nev
e = blackRock2event(nevData,ns1File);

% Raster
%%
fullRunRaster(e)

%%
