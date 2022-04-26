% MULTIBEAM AND UAV DATA LOADING
data=load('uav_multi.txt'); 
figure;
plot3(data(:,1),data(:,2),data(:,3),'.');grid on
%********************************************************************************
combined_x=data(:,1:2);                  % Spatial location
combined_z=data(:,3);                    % Vertical estimates
combined_sigma_z=repmat(.1,size(combined_z));     % uncertainty of vertical estimates
%combined_lx=[5 5];                    % length scales associated with spatial location
model_order=2;                  % model order: 1 (planar surface), 2 (quadratic surface)
[combined_X,combined_Y]=meshgrid(min(combined_x(:,1)):1:max(combined_x(:,1)),min(combined_x(:,2)):1:max(combined_x(:,2)));    % prepare data for interpolation
%grid prepared at 1 m step
%*****************************************************************************************************
[Xi,Yi,Zi,Ei] = loess_grid2dh_all_scales(data(:,1),data(:,2),data(:,3),combined_X,combined_Y,[5 10 20 50],0.15,1);
%********************************************************************************************************
arcgridwrite('a_surface2021(1).asc',Xi(1,:),Yi(:,1),Zi,'precision',3);
arcgridwrite('a_uncertainty2021(1).asc',Xi(1,:),Yi(:,1),Ei,'precision',3);