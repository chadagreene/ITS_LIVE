function [hdot,hspan,herr] = itslive_tsplot(t,v,err,varargin)
% itslive_tsplot plots a time series of displacement measurements and their
% associated errors. 
% 
%% Syntax
% 
%  itslive_tsplot(t,v,err) 
%  itslive_tsplot(...,Name,Value,...) 
%  itslive_tsplot(...,'datenum') 
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
% [hdot,hspan,herr] = itslive_tsplot(...) returns handles of the center dot, 
% the horizontal bars that span the time of each measurement, and the vertical
% error bar. 
% 
%% Examples: 
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

% Now, let's see if the user wants to change any defaults: 
tmp = strcmpi(varargin,'datenum'); 
if any(tmp) 
   plot_datetime = false; 
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

%% Massage the data: 

% Make for damn sure v and err are columnated: 
v = v(:); 
err = err(:); 

t = double(t); 
tm = mean(t,2); 

if plot_datetime
   t = datetime(t,'convertfrom','datenum'); 
   tm = datetime(tm,'convertfrom','datenum'); 
end

%% Plot:

herr = plot([tm tm]',[v+err/2 v-err/2]','color',LineColor,varargin{:}); 
hold on
hspan = plot(t',[v v]','color',LineColor,varargin{:}); 
hdot = plot(tm,v,'.','color',MarkerColor,varargin{:}); 

%% Clean up: 

if nargout==0 
   clear h*
end

end