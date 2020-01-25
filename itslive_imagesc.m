function h = itslive_imagesc(variable,varargin)
% itslive_imagesc plots itslive data on polar stereographic projection map. 
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
%% Citing this data
% If this function is helpful for you, please cite
% 
% Gardner, A. S., M. A. Fahnestock, and T. A. Scambos, 2019 [update to time 
% of data download]: ITS_LIVE Regional Glacier and Ice Sheet Surface Velocities.
% Data archived at National Snow and Ice Data Center; doi:10.5067/6II6VW8LLWJ7.
%
% Gardner, A. S., G. Moholdt, T. Scambos, M. Fahnstock, S. Ligtenberg, M. van
% den Broeke, and J. Nilsson, 2018: Increased West Antarctic and unchanged 
% East Antarctic ice discharge over the last 7 years, _Cryosphere,_ 12(2): 
% 21?547, doi:10.5194/tc-12-521-2018.
%
% Greene, C. A., Gwyther, D. E., & Blankenship, D. D. Antarctic Mapping Tools  
% for Matlab. Computers & Geosciences. 104 (2017) pp.151-157. 
% http://dx.doi.org/10.1016/j.cageo.2016.08.003
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

