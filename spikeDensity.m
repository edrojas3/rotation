function spkd = spikeDensity(spiketimes, varargin)
% 
% USE: 
% spkd = spikeDensity(spiketimes)
% spkd = spikeDensity(spiketimes, 'bins', binvector, 'sigma', sigma, 'edges',edges)
%
% Inputs:
% spiketimes: vector with action potential times
% bins: vector to bin the spike times (default = -.3:.001:.299)
% sigma: standard deviation of the gaussian kernel (default = .015)
% edges: 2 elements vector to obtain the x points of the kernel (default = -3*st. dev. to 3*st. dev)
%
% Output:
% spkd: spike density function of the spiketimes
bins = getArgumentValue('bins',-.3:.001:.299,varargin{:});
sigma = getArgumentValue('sigma',.015,varargin{:});
edges = getArgumentValue('edges', [-3,3]);

% Spike density function
binned=hist(spiketimes,bins);
edges = edges(1)*sigma :.001: edges(2)*sigma; %Time ranges form -3*st. dev. to 3*st. dev.
kernel = normpdf(edges,0,sigma); %Evaluate the Gaussian kernel
kernel = kernel*.001; %Multiply by bin width
spkd = conv(binned,kernel); %Convolve spike data with the kernel
center = ceil(length(edges)/2); %Find the index of the kernel center
spkd = spkd(center:length(bins) + center-1); %Trim out middle portion



