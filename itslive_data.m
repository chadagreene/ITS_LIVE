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
%  [Z,x,y] = itslive_data(...) 
%  [Z,Lat,Lon] = itslive_data(...,'geo')
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
% Z = itslive_data(...,'region',region) specifies a region as 'ALA', 'ANT', 
% 'CAN', 'GRE', 'HMA', 'ICE', 'PAT', or 'SRA'. Default region is 'ANT'. 
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
%% Example 4: Greenland
% Plot the speed of Greenland's ice. 
% 
% [v,x,y] = itslive_data('v','region','GRE'); 
% 
% figure
% imagescn(x,y,v) % (or imagesc; axis xy and accept colored nans)
% greenland('color',0.5*[1 1 1]) % outline of greenland coast 
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
   
   % Which ice sheet? (Default is already set to Antarctica)
   tmp = strncmpi(varargin,'region',3); 
   if any(tmp)
      region = varargin{find(tmp)+1}; 
   end
   
   % Check for subset based on input coordinates: 
   if isnumeric(varargin{1}) 
      subset = true; 
      lati_or_xi = varargin{1}; 
      loni_or_yi = varargin{2}; 
      
      % Are inputs georeferenced coordinates or projected meters?
      if islatlon(lati_or_xi,loni_or_yi)
         switch lower(region) 
            case {'ala','can','gre','ice','sra'}
               if exist('ll2psn.m','file')==2
                  [xi,yi] = ll2psn(lati_or_xi,loni_or_yi); 
               else
                  assert(exist('projcrs.m','file')==2,'The ALA,CAN,GRE,ICE, and SRA projections require either: (Arctic Mapping Tools, which is free on File Exchange) OR (Matlab 2020b or later AND Matlab''s Mapping Toolbox).') 
                  proj = projcrs(3413,'authority','EPSG'); 
                  [xi,yi] = projfwd(proj,lati_or_xi,loni_or_yi); 
               end
            case 'ant'
               assert(exist('ll2ps.m','file')==2,'Cannot find ll2ps, which is an essential function in Antarctic Mapping Tools.')
               [xi,yi] = ll2ps(lati_or_xi,loni_or_yi); % The ll2ps function is in the Antarctic Mapping Tools package.
            case 'hma'
               assert(exist('projcrs.m','file')==2,'Sorry, the HMA projection requires Matlab 2020b or later AND the Mapping Toolbox. I, too, wish things could be different.') 
               proj = projcrs(102027,'authority','ESRI'); 
               [xi,yi] = projfwd(proj,lati_or_xi,loni_or_yi); 
            case 'pat'
               assert(exist('projcrs.m','file')==2,'Sorry, the PAT projection requires Matlab 2020b or later AND the Mapping Toolbox. I, too, wish things could be different.') 
               proj = projcrs(32718,'authority','EPSG'); 
               [xi,yi] = projfwd(proj,lati_or_xi,loni_or_yi); 
            otherwise
               error('Unsupported region. So far only ANT and HMA are supported, but email me and I will be happy to add support for other regions.')
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

filename = [upper(region),'_G0240_0000.nc']; 

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
      
      switch lower(region) 
         case 'ant'
            [Lat_or_x,Lon_or_y] = ps2ll(X,Y); 
         case 'pat'
            proj = projcrs(32718,'authority','EPSG'); 
            [Lat_or_x,Lon_or_y] = projinv(proj,X,Y); 
         case 'hma'
            proj = projcrs(102027,'authority','ESRI'); 
            [Lat_or_x,Lon_or_y] = projinv(proj,X,Y); 
         otherwise
            if exist('psn2ll.m','file')==2
               [Lat_or_x,Lon_or_y] = psn2ll(X,Y); 
            else
               assert(exist('projcrs.m','file')==2,'The ALA,CAN,GRE,ICE, and SRA projections require either: (Arctic Mapping Tools, which is free on File Exchange) OR (Matlab 2020b or later AND Matlab''s Mapping Toolbox).') 
               proj = projcrs(3413,'authority','EPSG'); 
               [Lat_or_x,Lon_or_y] = projinv(proj,X,Y); 
            end
      end
   end
end
     

end

