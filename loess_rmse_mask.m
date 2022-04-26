function [Z_clean]=loess_rmse_mask(Z,rmse,threshold)

Err=reshape(rmse,size(Z));
ind=abs(rmse)>threshold;
Z_clean=Z;
Z_clean(ind)=nan;

