l=load('l523.txt');
u=load('u523.txt');
%**************************************************
l_x=l(:,1:2);   % Spatial location for land data
l_z=l(:,3);     % Vertical estimates for land data
l_sigma_z=repmat(0.02,size(l_z)) ; % uncertainty of vertical estimates of land data (0.016)

%************************************************************

u_x=u(:,1:2);   % Spatial location for uav data
u_z=u(:,3);     % Vertical estimates for uav data
u_sigma_z=repmat(.1,size(u_z));     % uncertainty of vertical estimates of uav data

%***************************************************************

lx=[5 5];                           % length scales associated with spatial location
model_order=2;                      % model order: 1 (planar surface), 2 (quadratic surface)
[u_X,u_Y]=meshgrid(min(u_x(:,1)):5:max(u_x(:,1)),min(u_x(:,2)):5:max(u_x(:,2)));  
                                     % prepare data for interpolation,data file
xi=[u_X(:) u_Y(:)];

%******************************************************************
% interpolate UAV surface
[u_zi,u_rmse]=loess_interp(u_x,u_z,u_sigma_z,xi,lx,model_order); % loess interpolation
u_Z=reshape(u_zi,size(u_X));
u_Z=loess_rmse_mask(u_Z,u_rmse,.2);  % Clean output based on estimated uncertainty
figure;
surf(u_X,u_Y,u_Z) 
hold on
plot3(l_x(:,1),l_x(:,2),l_z,'r*')

%**********************************************************************
% Cross validation
% interpolate uav data at the land data point locations

[UAV_zi_land,UAV_rmse_land]=loess_interp(u_x,u_z,u_sigma_z,l_x,lx,model_order);  % loess interpolation
validation_error=UAV_zi_land-l_z;
validation_rmse=sqrt(nansum(validation_error.^2));
figure;
plot(validation_error,'r-')
title('UAV DATA VALIDATION ERROR GRAPH')
xlabel('CO-ORDINATE NUMBERS')
ylabel('VALIDATION ERROR')








