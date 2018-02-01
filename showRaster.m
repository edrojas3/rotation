function raster = showRaster(id,varargin)
filedir = getArgumentValue('file','C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns',varargin{:});
if exist([filedir, '\', id,'.png'],'file')
    raster = imread([filedir, '\', id,'.png']);
    if nargout == 0;
        imshow(raster);
    end
end