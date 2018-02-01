function [r,fr,frd,rc] = showGraphs(id)

frates = 'C:\Users\eduardo\Documents\proyectos\rotacion\figs\analysispngs\frates';
fratesD = 'C:\Users\eduardo\Documents\proyectos\rotacion\figs\analysispngs\fratesDetrend';
rocindex = 'C:\Users\eduardo\Documents\proyectos\rotacion\figs\analysispngs\rocindex';

r = showRaster(id);
fr = imread([frates,'\',id,'.png']);
frd = imread([fratesD,'\',id,'.png']);
rc = imread([rocindex,'\',id,'.png']);

if nargout == 0;
   figure 
   imshow(r) 
   figure
   imshow(fr)
   figure
   imshow(frd)
   figure
   imshow(rc) 
end
