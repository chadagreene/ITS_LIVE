function h = itslive_imagesc(variable,varargin)
% itslive_map plots itslive data on polar stereographic projection map. 
% 
%% Syntax
% 
%  itslive_imagesc
%  itslive_imagesc(variable) 
%  itslive_imagesc(variable,'alpha',alpha) 
%  h = itslive_imagesc(...)
% 
%% Description 
% 
% itslive_imagesc plots ITS_LIVE ice speed as an imagesc object. 
% 
% itslive_imagesc(variable) plots any ITS_LIVE variable such as 'v', 'vx','vy', 
% 'vx_err', 'vy_err', 'v_err', 'date', 'dt', 'count', 'chip_size_max', 
% 'ocean', 'rock', or 'ice'. If a figure is open and axes are current before
% calling itslive_imagesc, only enough data are loaded to fill the extents
% of the current axes. If no axes are current before calling itslive_imagesc, 
% the whole continent is loaded and plotted. Note: Plotting the full continent
% might take a few seconds...
% 
% itslive_imagesc(variable,'alpha',alpha) sets the transparency to a value 
% of 0 (totally transparent) to 1 (totally opaque). Default value is 1. 
% 
% h = itslive_imagesc(...) returns a handle h of the image object. 
% 
%% Examples: 
%
% mapzoomps('pine island glacier') 
% modismoaps('contrast','low')
% itslive_imagesc('v','alpha',0.8) 
% itslive_quiver
% 
%% Author Info
% Chad A. Greene wrote this in May of 2019. 
%
% See also: itslive_quiver and itslive_data. 

%% Parse inputs: 

narginchk(0,3)

if nargin==0
   variable = 'v'; 
end

tmp = strcmpi(varargin,'alpha'); 
if any(tmp)
   alpha = varargin{find(tmp)+1}; 
   assert(alpha>=0 & alpha<=1,'Alpha must be a scalar between 0 and 1') 
else
   alpha = 1; 
end

%% Check the presence of a current axes: 

ax = axis; 
if isequal(ax,[0 1 0 1]) 
   NewMap = true; 
else 
   NewMap = false; 
end

%% Load data: 

if NewMap
   [Z,x,y] = itslive_data(variable,'xy'); 
else
   [Z,x,y] = itslive_data(variable,ax(1:2),ax(3:4),'xy'); 
end 

%% Plot things: 

hold on
h = imagesc(x,y,Z); 

% Set transparency: 
h.AlphaData = alpha*isfinite(Z);

axis xy
daspect([1 1 1]) 

%% Clean up: 

if nargout==0 
   clear h
end
end

