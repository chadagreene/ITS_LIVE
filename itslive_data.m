function [Z,Lat_or_x,Lon_or_y] = itslive_data(variable,varargin) 
% itslive_data loads ITS-LIVE velocity data. 
% 
%% Syntax 
% 
%  Z = itslive_data(variable)
%  Z = itslive_data(variable,lati,loni)
%  Z = itslive_data(variable,xi,yi) 
%  Z = itslive_data(...,'buffer',extrakm)
%  Z = itslive_data(...,'year',years) 
%  Z = itslive_data(...,'path',filepath) 
%  Z = itslive_data(...,'region',region) 
%  [Z,Lat,Lon] = itslive_data(...)
%  [Z,x,y] = itslive_data(...,'xy') 
% 
%% Description 
% 
% Z = itslive_data(variable) loads an ITS_LIVE variable such as 'v', 'vx',
% 'vy', 'vx_err', 'vy_err', 'v_err', 'date', 'dt', 'count', 'chip_size_max', 
% 'ocean', 'rock', or 'ice'.
% 
% Z = itslive_data(variable,lati,loni) loads only enough ITS_LIVE data to fully
% encompass the extents of lati,loni. 
% 
% Z = itslive_data(variable,xi,yi) as above, but for ps71 meters xi,yi. 
% 
% Z = itslive_data(...,'buffer',extrakm) adds an extra buffer around the 
% point(s) of interest. For example, Z = itslive_data('v',-77.85,166.67,'buffer',15) 
% will load approximately a 30 km by 30 km grid with McMurdo Station in the middle. 
% That is, a 15 km buffer on each side of the input coordinates. Use a two-element
% buffer value such as [xbuf ybuf] to specify different buffer widths in the polar
% sterographic x and y directions. 
% 
% Z = itslive_data(...,'year',years) specifies the year(s) of interest. By default
% the error-weighted mean of all years is returned. 
% 
% Z = itslive_data(...,'path',filepath) specifies a filepath to the mosaic data. 
% 
% Z = itslive_data(...,'region',region) specifies a region. Currently, only
% 'ANT' is supported.
% 
% [Z,x,y] = itslive_data(...) returns arrays of x,y coordinates in meters. The 
% coordinates cooresponding to each grid cell in Z can then be obtained by 
% [X,Y] = meshgrid(x,y).
% 
% [Z,Lat,Lon] = itslive_data(...,'geo') returns a Lat,Lon grid. Turns the 
% x,y arrays into meshgrids and converts to geo coordinates via the ps2ll function. 
% 
%% Example 1: 
% Load all velocity data: 
% 
% [v,x,y] = itslive_data('v'); 
% 
% imagescn(x,y,v) % A CDT function (can use imagesc instead) 
% axis image  
% 
%% Example 2:
% Load all the data in the Pine Island Glacier basin: 
% 
% [lat,lon] = basin_data('imbie refined','pine island'); % AMT function 
% [v,x,y] = itslive_data('v',lat,lon); 
% 
% imagescn(x,y,v)      % CDT function (can use pcolor or imagesc instead)
% hold on
% plotps(lat,lon)      % AMT function to plot in polar stereographic
% cmocean amp          % CDT function for colormap
%% Example 3: 
% Same as above, but this time use the x,y extents of the polar stereographic
% map, and add a 5 km buffer on all sides. Also specify the filepath, and load
% data from 2018: 
% 
% [vx,x2,y2] = itslive_data('vx',xlim,ylim,'path','/Users/cgreene/Documents/MATLAB/data','buffer',5,'year',2018); 
% vy = itslive_data('vy',xlim,ylim,'path','/Users/cgreene/Documents/MATLAB/data','buffer',5,'year',2018); 
% 
% quiversc(x2,y2,vx,vy); % CDT function 
% 
%% Author Info
% This function was written by Chad A. Greene, April 6, 2019. 
% 
% See also itslive_interp. 

%% Initial error checks: 

narginchk(1,Inf)
assert(~isnumeric(variable),'Error: variable must be a string, e.g. ''bed'', ''surface'', ''mask'', etc') 

%% Set defaults: 
% NOTE: To update the dataset filename manually, change the filename in the 
% switch statement in the "Define filename" section that appears around line 
% 160 below.

subset = false;  % use whole data set (not a regional subset) by default 
extrakm = 0;     % zero buffer by default
xyout = true;    % give x,y arrays grid by default
region = 'ANT'; 
annual = false;  % give the overall mosaic by default
filepath = [];   % just find whichever data file matches the name by default. 

%% Parse inputs: 

if nargin>1
   
   % Check for subset based on input coordinates: 
   if isnumeric(varargin{1}) 
      subset = true; 
      lati_or_xi = varargin{1}; 
      loni_or_yi = varargin{2}; 
      
      % Are inputs georeferenced coordinates or polar stereographic?
      if islatlon(lati_or_xi,loni_or_yi)
         % Check hemisphere: 
         if any(lati_or_xi(:)>0)
            [xi,yi] = ll2psn(lati_or_xi,loni_or_yi); % The ll2psn function is part of Arctic Mapping Tools package, the lesser known sibling of Antarctic Mapping Tools. 
         else
            [xi,yi] = ll2ps(lati_or_xi,loni_or_yi); % The ll2ps function is in the Antarctic Mapping Tools package.
         end
      else 
         xi = lati_or_xi;
         yi = loni_or_yi;    
      end

      % Add a buffer around the edges of the data:
      tmp = strncmpi(varargin,'buffer',3); 
      if any(tmp)
         extrakm = varargin{find(tmp)+1}; 
         assert(numel(extrakm)<3,'Error: buffer must be one or two elements, in kilometers.') 
      end
   end

   % Is the user requesting x and y outputs instead of default lat,lon grid? 
   if any(strcmpi(varargin,'geo')) 
      xyout = false; 
   end

   % Which ice sheet? (Default is already set to Antarctica unless input coordinates have negative latitudes) 
   if any(strncmpi(varargin,'region',3))
      error('Cannot specify region: Only Antarctica is supported right now.')   
   end
   
   tmp = strncmpi(varargin,'years',4); 
   if any(tmp)
      years = varargin{find(tmp)+1}; 
      annual = true; 
   end
   
   tmp = strcmpi(varargin,'path'); 
   if any(tmp)
      filepath = varargin{find(tmp)+1}; 
   end
   
end

%% Define filename: 
% DEFINE DATASET FILENAMES HERE! 

switch lower(region) 
      
   case 'ant'
      filename = 'ANT_G0240_0000.nc'; 
      
   otherwise
      error('Unrecognized ice sheet and I have no clue how we got here.') 
end

assert(exist(fullfile(filepath,filename),'file')==2,['Error: cannot find ',filename,'.']) 

finfo = ncinfo(fullfile(filepath,filename)); 
varNames = {finfo.Variables.Name};
if ~any(strcmpi(varNames,variable))
   disp(['Error: Cannot find the specified variable ',variable,'. It should be one of these:'])
   disp(varNames')
   return
end

%% Load data 

% If user only wants vectors, give 'em to 'em and exit the function: 
if ismember(lower(variable),{'x','y'})
   Z = ncread(fullfile(filepath,filename),variable); 
   return
end

x = ncread(fullfile(filepath,filename),'x'); 
y = ncread(fullfile(filepath,filename),'y'); 

if subset
   
   if isscalar(extrakm)
      extrakm = [extrakm extrakm]; 
   end
   
    % A crude manual fix for when a single xi,yi lies between pixels: 
    if isscalar(xi)
          extrakm = [max([extrakm(1) 1]) max([extrakm(2) 1])]; 
    end
    
    % Get xlimits (xl) and ylimits (yl) of input coordinates + buffer:
    xl = [min(xi(:))-extrakm(1)*1000 max(xi(:))+extrakm(1)*1000];
    yl = [min(yi(:))-extrakm(2)*1000 max(yi(:))+extrakm(2)*1000];
    
    % Region of rows and columns of pixels to read: 
    ci=find((y>=yl(1))&(y<=yl(2)));
    ri=find((x>=xl(1))&(x<=xl(2)));
else
    ci = 1:length(y); 
    ri = 1:length(x); 
end

% Load data: 
if annual
   Z = NaN(length(ci),length(ri),length(years)); 
   for k = 1:length(years) 
      fn = fullfile(filepath,filename); 
      fn(end-6:end-3) = num2str(years(k)); 
      Z(:,:,k) = flipud(rot90(ncread(fn,variable,[ri(1) ci(1)],[length(ri) length(ci)])));
   end
else
   Z = flipud(rot90(ncread(fullfile(filepath,filename),variable,[ri(1) ci(1)],[length(ri) length(ci)])));
end 

if ismember(lower(variable),{'rock','ocean','ice'})
   Z = logical(Z); 
else
   % Take care of NaNs: 
   Z(Z==-32767) = NaN; 
end

%% Final adjustments for the export: 

% Give user coordinates if more than one output argument: 
if nargout>1
   if xyout
      Lat_or_x = x(ri); 
      Lon_or_y = y(ci); 
   else
      
      % Meshgridding a whole continent of high res data might make the computer stop working, so warn the user for large datasets 
      if (length(ri)*length(ci))>1e7
         answer = questdlg('Warning: Gridding the geo coordinates of an area this large could slow your computer to a crawl. You may prefer to cancel and try again using the ''xy'' option. Do you wish to cancel?',...
            'Memory Warning',...
            'Go for it anyway','Cancel','Cancel'); 
         if strcmp(answer,'Cancel')
            return
         end
      end
         
      % Grid the points so we can get lat,lon coordinates of each grid point:  
      [X,Y] = meshgrid(x(ri),y(ci));
      
      [Lat_or_x,Lon_or_y] = ps2ll(X,Y); 
   end
end
     

end