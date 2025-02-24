function h = itslive_imagesc(region,variable,options)
% itslive_imagesc plots ITS_LIVE data in regionally projected map coordinates.
% 
%% Syntax
% 
%  itslive_imagesc(region)
%  itslive_imagesc(region,variable) 
%  itslive_imagesc(...,'alpha',alpha) 
%  itslive_imagesc(...,filepath=path)
%  h = itslive_imagesc(...)
% 
%% Description 
% 
% itslive_imagesc(region) plots ITS_LIVE ice speed as an imagesc object for 
% the specified ITS_LIVE mosaic region. For a map of regions, type
% itslive_regions. 
% 
% itslive_imagesc(region,variable) plots any ITS_LIVE variable such as 'v', 'vx','vy', 
% 'vx_error', 'landice', etc. If a figure is open and axes are current before
% calling itslive_imagesc, only enough data are loaded to fill the extents
% of the current axes. If no axes are current before calling itslive_imagesc, 
% the entire region is loaded and plotted. Note: Plotting an entire large
% region such as Antarctica might take a long time.
% 
% itslive_imagesc(...,'alpha',alpha) sets the transparency to a value 
% between 0 (totally transparent) and 1 (totally opaque). Default value is 1, 
% (except for NaNs, which are always set to 0). 
%
% itslive_imagesc(...,filepath=path) specifies a directory where the velocity
% mosaic data reside. 
% 
% h = itslive_imagesc(...) returns a handle h of the image object. 
% 
%% Example 1: All of Greenland 
% Make a map of Greenland's velocity: 
% 
% figure
% itslive_imagesc(5)
% set(gca,'colorscale','log') 
% clim([1 10e3])
% 
%% Example 2: Pine Island Glacier, Antarctica 
% Zoom in to a small region of interest (do this before calling itslive_imagesc
% so it will only load the necessary data), plot a background MODIS Mosaic
% of Antarctica image, and then overlay a semitransparent ice speed layer, 
% and finish it off with quiver arrows. 
%
% mapzoomps('pine island glacier') 
% modismoaps('contrast','low')
% itslive_imagesc(19,'v','alpha',0.8) 
% set(gca,'colorscale','log') 
% clim([1 3000])
% 
%% More Examples
% 
% For more examples, see the documentation at:
% https://github.com/chadagreene/ITS_LIVE.
% 
%% Citing this data
% If you use ITS_LIVE v2 velocity data, please cite:  
%
% Gardner, A. S., Greene, C. A., Kennedy, J. H., Fahnestock, M. A., Liukis, 
% M., López, L. A., Lei, Y., Scambos, T. A., and Dehecq, A.: ITS_LIVE global 
% glacier velocity data in near real time, EGUsphere [preprint], 
% https://doi.org/10.5194/egusphere-2025-392, 2025. 
%
%% Author Info
% Chad A. Greene wrote this in May of 2019, rewritten Nov 2024 for
% the release of ITS_LIVE version 2. 
%
% See also: itslive_quiver and itslive_data. 

%% Parse inputs: 

arguments 
   region {mustBeMember(region,[1:12 14 17:19])}
   variable {mustBeText} = 'v'
   options.alpha (1,1) {mustBeInRange(options.alpha,0,1)} = 1
   options.filepath {mustBeText} = ""
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
   [Z,x,y] = itslive_data(region,variable, filepath=options.filepath); 
   landice = itslive_data(region,'landice', filepath=options.filepath); 
else
   [Z,x,y] = itslive_data(region,variable,...
       xlim = ax(1:2),...
       ylim = ax(3:4),...
       filepath = options.filepath); 
   landice = itslive_data(region,'landice',...
       xlim = ax(1:2),...
       ylim = ax(3:4),...
       filepath = options.filepath); 
end 

%% Plot things: 

hold on
h = imagesc(x,y,Z); 

% Set transparency: 
h.AlphaData = options.alpha * (isfinite(Z) & landice);

axis xy
daspect([1 1 1]) 

%% Clean up: 

if nargout==0 
   clear h
end
end

