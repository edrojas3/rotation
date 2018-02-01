function x_scaled = scale01(x,varargin)

if length(varargin) < 2;
    dim = 1;
end

x = double(x);

if dim == 2 || size(x,1) == 1;
    x = x';
end

x_scaled = nan(size(x));
for i = 1:size(x,2)
    x_min = min(x(:,i));
    x_max = max(x(:,i));
    x_range = x_max - x_min;
    x_scaled(:,i) = (x(:,i) - x_min)  / x_range;
end