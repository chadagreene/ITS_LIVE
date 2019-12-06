function [hdot,hspan,herr] = itslive_tsplot(t,v,err,varargin)
% itslive_tsplot plots a time series of displacement measurements and their
% associated errors. 
% 
%% Syntax
% 
%  itslive_tsplot(t,v,err) 
%  itslive_tsplot(...,Name,Value,...) 
%  itslive_tsplot(...,'datenum') 
%  itslive_tsplot(...,'thresh',errorthreshold) 
%  itslive_tsplot(...,'inliers') 
%  [hdot,hspan,herr] = itslive_tsplot(...)
% 
%% Description 
% 
% itslive_tsplot(t,v,err) plots a velocity time series given by times t, 
% velocities v, and corresponding error estimates err. Times t must be in 
% datenum format (number of days since New Years of year 0) and the dimensions
% Nx2. Velocities v and errors err must be Nx1. 
% 
% itslive_tsplot(...,Name,Value,...) specifies line or marker properties such
% as 'markercolor' or 'linecolor'. You may find that setting properties in this
% way is tough, because 'linewidth' affects both the horizontal and vertical 
% linewidths, so if that's the case, consider manually setting properties 
% after plotting, like hbar.LineWidth = 2. 
% 
% itslive_tsplot(...,'datenum') plots the time series with the x axis in 
% datenum format. By default, the input times which must be in datenum, are 
% converted to datetime format, because datetime is generally more user-friendly 
% for plotting. However, datetime has a few limitations, so in some cases 
% you may prefer to plot in datenum, and follow up the call to itslive_tsplot 
% with something like datetick('x','keeplimits'). 
% 
% itslive_tsplot(...,'thresh',errorthreshold) limits plotting to only values
% whose error is less than or equal to a specified threshold. For example,
% use 'thresh',50 to plot only measurements whose formal velocity error
% estimate is less than 50 m/yr; 
% 
% itslive_tsplot(...,'inliers') uses itslive_interannual to remove interannual
% variability, identifies outliers as everything more  than two standard 
% deviations of the residuals away from the interannual mean, and plots only
% the data that are not outliers. 
% 
% [hdot,hspan,herr] = itslive_tsplot(...) returns handles of the center dot, 
% the horizontal bars that span the time of each measurement, and the vertical
% error bar. 
% 
%% Examples: 
%
% v = itslive_interp(441952.50,-860512.50,'years',1985:2018);
% v_err = itslive_interp('v_err',441952.50,-860512.50,'years',1985:2018);
% t = itslive_interp('date',441952.50,-860512.50,'years',1985:2018)+itslive_interp('dt',441952.50,-860512.50,'years',1985:2018)*[-1/2 1/2];
% 
% itslive_tsplot(t,v,err) 
% 
% itslive_tsplot(t,vx,vx_err,'linecolor',rgb('light red'),...
%  'markercolor',rgb('dark red'),'datenum')
% 
%% Author Info
% This function was written by Chad A. Greene, May 2019. 
% 
% See also: itslive_data and itslive_interp. 

%% Error checks: 

narginchk(3,Inf) 
assert(size(t,2)==2,'Times t must by Nx2, indicating start and end date of each displacement measurement.') 
assert(isequal(size(t,1),numel(v),numel(err)),'Dimensions of v and err must be the same and they must match the number of rows in t.') 

%% Input parsing: 

% First, set the defaults: 
plot_datetime = true; 
LineColor = [0.58 0.82 0.99]; % light blue
MarkerColor = [0 0.01 0.36];  % dark blue
InputErrorThreshold = false;  % plot all data by default
discardoutliers = false; 

% Now, let's see if the user wants to change any defaults: 
tmp = strcmpi(varargin,'datenum'); 
if any(tmp) 
   plot_datetime = false; 
   varargin = varargin(~tmp); 
end

tmp = strncmpi(varargin,'threshold',5); 
if any(tmp) 
   InputErrorThreshold = true; 
   ThresholdValue = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
end

tmp = strcmpi(varargin,'linecolor'); 
if any(tmp) 
   LineColor = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
end

tmp = strcmpi(varargin,'markercolor'); 
if any(tmp) 
   MarkerColor = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
end

tmp = strcmpi(varargin,'inliers'); 
if any(tmp) 
   discardoutliers = true; 
   varargin = varargin(~tmp); 
end

%% Massage the data: 

% Make for damn sure v and err are columnated: 
v = v(:); 
err = err(:); 

if discardoutliers
   
   % Use only finite data: 
   isf = isfinite(v) & isfinite(err); 
   t = t(isf,:); 
   v = v(isf); 
   err = err(isf); 
   
   % Remove interannual signal:
   v_int = itslive_interannual(t,v,err); 
   v_resid = v-v_int; 
   
   % Find and destroy outliers: 
   outliers = abs(v_resid)>2*std(v_resid); 
   t = t(~outliers,:); 
   v = v(~outliers); 
   err = err(~outliers); 
end

if InputErrorThreshold
   good = err<=ThresholdValue; 
   v = v(good); 
   t = t(good,:); 
   err = err(good); 
end

t = double(t); 
tm = mean(t,2); 

if plot_datetime
   t = datetime(t,'convertfrom','datenum'); 
   tm = datetime(tm,'convertfrom','datenum'); 
end

%% Plot:

herr = plot([tm tm]',[v+err v-err]','color',LineColor,varargin{:}); 
hold on
hspan = plot(t',[v v]','color',LineColor,varargin{:}); 
hdot = plot(tm,v,'.','color',MarkerColor,varargin{:}); 

%% Clean up: 

if nargout==0 
   clear h*
end

end