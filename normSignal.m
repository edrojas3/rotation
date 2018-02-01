function x_norm = normSignal(x, varargin)

dim = getArgumentValue('dim',1,varargin{:});
normvector = getArgumentValue('normvector', 1:300, varargin{:});

x = double(x);

if dim == 2 || size(x,1) == 1;
    x = x';
end

x_norm= nan(size(x));
for s = 1:size(x,2)
   x_norm(:,s) = (x(:,s) - mean(x(normvector,s))) / std(x(normvector,s));
end

if dim == 2 || size(x,1) == 1;
    x_norm = x_norm';
end