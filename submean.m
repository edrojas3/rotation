function x_sub = submean(x, varargin)

dim = getArgumentValue('dim',1,varargin{:});
meanvector = getArgumentValue('normvector', 1:300, varargin{:});

x = double(x);

if dim == 2 || size(x,1) == 1;
    x = x';
end

x_sub= nan(size(x));
for s = 1:size(x,2)
   x_sub(:,s) = x(:,s) - mean(x(meanvector,s));
end

if dim == 2 || size(x,1) == 1;
    x_sub = x_sub';
end