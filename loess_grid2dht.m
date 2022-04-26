    function [Xi,Yi,Zi, Ei] = loess_grid2dht(x,y,z,t, xi,yi,ti, lx,ly,lt);
% [Xi,Yi,Zi, Ei] = loess_grid2dht(x,y,z,t, xi,yi,ti lx,ly,lt);
%
% take advantage of some optimization steps in order to interpolate random data
%
% Input
%   x,y,z,t the data
%   xi, yi, ti the grid locations and time in x,y
%   lx,ly,lt the smoothing scales
%
% Output
%   Xi, Yi, the grid location matrices
%   Zi, the interpolated surface
%   Ei, the error estimates
%
% Note, interpolation model is quadratic
model_order = 2;

% first subsample the data
% subsample spacing set so that loess filter will not alias
% the filter will alias variation if dx is too large, so sample at dx=lx/4, or smaller
DXsub = [lx, ly, lt]/16;
[Xbin, zbin, sbin, nbin] = subsample_data([x, y, t],z,DXsub);

[Xi,Yi] = meshgrid(xi(:),yi(:));	Ti=repmat(ti,size(Xi));

[zr, rmse]=loess_interp(Xbin,zbin, sbin,[Xi(:),Yi(:),Ti(:)],[lx,ly,lt],model_order);

% reconstruct the subsampled grid
Zi = reshape(zr,length(yi),length(xi));
Ei = reshape(rmse,length(yi),length(xi));
