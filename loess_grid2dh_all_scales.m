function [Xi,Yi,Zi,Ei,Si] = loess_grid2dh_all_scales(x,y,z,xi,yi,scales,err_level,show_plot)

model_order=2;

%[Xi,Yi] = meshgrid(xi(:),yi(:));
Xi=xi; Yi=yi;
Zi=repmat(nan,size(Xi));	Ei=Zi;	Si=Zi;

for i=1:length(scales)
	lx=scales(i);	ly=scales(i);
	ind=find(isnan(Zi));

	% first subsample the data
	% subsample spacing set so that loess filter will not alias
	% the filter will alias variation if dx is too large, so sample at dx=lx/4, or smaller

	DXsub = [lx, ly]/8;
	[Xbin, zbin, sbin, nbin] = subsample_data([x, y],z,DXsub);

	% the filter will fully remove features shorter than lx/2 (quadratic model)
	% if this is the nyquist wavenumber, then we need to sample at dx=lx/4
	dxi = lx/4;
	dyi = ly/4;
	xr=(xi(1)-dxi):dxi:(xi(end)+dxi);
	yr=(yi(1)-dyi):dyi:(yi(end)+dyi);
	[Xr, Yr] = meshgrid(xr,yr);

	% check that subsample is not over sampling
    if(length(Xr(:))<length(ind))

		% interpolate
		[zr, rmse] = loess_interp(Xbin,zbin, sbin, [Xr(:),Yr(:)],[lx,ly], model_order);
		zr(rmse>err_level)=nan;	rmse(rmse>err_level)=nan;

		% reconstruct the subsampled grid
		Zi_temp = reshape(zr,length(yr),length(xr));
		Ei_temp = reshape(rmse,length(yr),length(xr));

		% now, do fast linear interpolation to get to desired grid
		Zi_temp = interp2(Xr,Yr,Zi_temp,Xi,Yi);
		Ei_temp = interp2(Xr,Yr,Ei_temp,Xi,Yi);
		Zi(ind)=Zi_temp(ind);	clear Zi_temp;
		Ei(ind)=Ei_temp(ind);	clear Ei_temp;
		Si(ind)=repmat(lx,size(ind));

    else
		[zr, rmse] = loess_interp(Xbin,zbin, sbin, [Xi(ind),Yi(ind)],[lx,ly], model_order);
		zr(rmse>err_level)=nan;	rmse(rmse>err_level)=nan;
		Zi(ind)=zr;
		Ei(ind)=rmse;
		Si(ind)=repmat(lx,size(ind));

    end
end

if show_plot
	figure;surf(Xi,Yi,Zi);
    axis([min(xi(:)) max(xi(:)) min(yi(:)) max(yi(:)) floor(min(Zi(:))) ceil(max(Zi(:)))]);
	shading interp;caxis([floor(min(Zi(:))) ceil(max(Zi(:)))]);colorbar;view(2);
	drawnow;pause(1);
end
