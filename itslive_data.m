function [Z,Lat_or_x,Lon_or_y] = itslive_data(region,variable,options) 
% itslive_data loads ITS_LIVE velocity data. 
% 
%% Syntax 
% 
%  Z = itslive_data(region, variable)
%  Z = itslive_data(..., xlim=xlim, ylim=ylim)
%  Z = itslive_data(..., latlim=latlim, lonlim=lonlim)
%  Z = itslive_data(..., buffer=buffer_km)
%  Z = itslive_data(..., year=years)
%  Z = itslive_data(..., filepath=path)
%  [Z,x,y] = itslive_data(...) 
%  [Z,Lat,Lon] = itslive_data(...,geoout=true)
% 
%% Description 
% 
% Z = itslive_data(region, variable) loads any gridded variable in the
% ITS_LIVE v2 summary velocity mosaics for a specified region. The region
% is a number between 1 (Alaska) and 19 (Antarctica). To view a map of the
% regions, type itslive_regions. By default, the summary (0000) mosaics are
% plotted. The input variable can be "v", "vx", "v_error", etc. 
%  
% Z = itslive_data(..., xlim=xlim, ylim=ylim) only loads data within 
% specified map limits. With this syntax, xlim and ylim can be two-element
% arrays indicating the minimum and maximum spatial extents of interest, or
% you can enter many scattered points and the function will automatically
% calculate the minimum and maximum values of the x and y limits. 
%  
% Z = itslive_data(..., latlim=latlim, lonlim=lonlim) similar to the xlim,
% ylim above, but here geo coordinates are entered (Requires MATLAB's
% Mapping Toolbox). 
%  
% Z = itslive_data(..., buffer=buffer_km) adds an extra buffer around the
% limits specified by xlim,ylim or latlim,lonlim. The input buffer_km can
% be a scalar value to add a specified buffer on all sides of the input
% points, or can be a two-element array in the form [buffer_km_x buffer_km_y]. 
%  
% Z = itslive_data(..., year=years) specifies desired years for annual
% mosaics. If years are not specified, only the summary mosaic (0000) is
% loaded. If multiple years are specified, the output Z is a data cube
% whose third dimension corresponds to each specified year. 
% 
% Z = itslive_data(..., filepath=path) specifies a directory where the velocity
% mosaic data reside. 
%  
% [Z,x,y] = itslive_data(...) also returns map coordinates x,y when three
% outputs are requested. 
%  
% [Z,Lat,Lon] = itslive_data(...,geoout=true) returns 2D grids Lat,Lon of
% geographic coordinates corresponding to each pixel in Z. (Requires
% MATLAB's Mapping Toolbox). Note that for large grids such as all of
% Antarctica at full resolution, this option might take a significant
% amount of time to compute. 
% 
%% Example 1: Iceland
% Plot a summary mosaic of Iceland: 
% 
%  [v,x,y] = itslive_data(6, 'v');
% 
%  figure
%  h = imagesc(x,y,v); 
%  h.AlphaData = isfinite(v); % Makes missing data transparent. 
%  axis xy image              % orients and scales properly 
%  set(gca,'colorscale','log') 
%  clim([1 1e3])              % sets color axis limits
% 
%% Example 2: Pine Island Glacier, Antarctica
% Load all the data in the Pine Island Glacier basin. PIG is in Antarctica, 
% so we specify region 19. (This example uses Antarctic Mapping Tools.) 
%  
%  [lat,lon] = basin_data('imbie refined','pine island'); 
%  [v,x,y] = itslive_data(19, 'v', latlim=lat, lonlim=lon); 
%  
%  figure 
%  h = imagesc(x,y,v);
%  h.AlphaData = isfinite(v);
%  hold on
%  plotps(lat,lon,'k')      % AMT function 
%  set(gca,'colorscale','log') 
%  clim([1 2e3])              
%  
%% Example 3: More Pine Island Glacier, Antarctica
% Same as above, but this time add a 25 km buffer on all sides and only
% for the year 2019: 
%  
%  [lat,lon] = basin_data('imbie refined','pine island'); % AMT function 
%  [v,x,y] = itslive_data(19, 'v', latlim=lat, lonlim=lon, buffer=25, year=2019); 
%  
%  figure 
%  h = imagesc(x,y,v);
%  h.AlphaData = isfinite(v);   
%  hold on
%  plotps(lat,lon,'k')     % AMT function
%  set(gca,'colorscale','log') 
%  clim([1 2e3])    
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
% This function was written by Chad A. Greene, April 6, 2019. 
% Updated for ITS_LIVE version 2 in November 2024. 
% 
% See also itslive_regions and itslive_interp. 

%% Input parsing 

arguments
    region {mustBeMember(region,[1:12 14 17:19])}
    variable {mustBeText}
    options.xlim (:,:) {mustBeNumeric} = [-Inf Inf]
    options.ylim (:,:) {mustBeNumeric} = [-Inf Inf]
    options.latlim (:,:) {mustBeNumeric} = [-Inf Inf]
    options.lonlim (:,:) {mustBeNumeric} = [-Inf Inf]
    options.buffer (:,2) {mustBeNumeric} = 0
    options.year (:,1) {mustBeNumeric} = 0000
    options.filepath {mustBeText} = ""
    options.geoout {mustBeA(options.geoout,"logical")} = false
end

%% Parse spatial subsetting input preferences: 

subset = false; % by default

% If either xlim or ylim are declared, make sure they're both declared: 
if or(isfinite(options.xlim(1)) , isfinite(options.ylim(1)))
    assert(and(isfinite(options.xlim(1)) , isfinite(options.ylim(1))), "If xlim or ylim are declared, both must be declared.")
    subset = true; 
    xi = options.xlim;
    yi = options.ylim;   
end

% If either latlim or lonlim are declared, make sure they're both declared: 
if or(isfinite(options.latlim(1)) , isfinite(options.lonlim(1)))
    assert(and(isfinite(options.latlim(1)) , isfinite(options.lonlim(1))), "If latlim or lonlim are declared, both must be declared.")
    subset = true; 
    [xi, yi] = geo2itslive(region, options.latlim, options.lonlim); 
end

% If xlim or latlim are declared, make sure that only one is declared: 
if subset
    assert(xor(isfinite(options.xlim(1)) , isfinite(options.latlim(1))), "Spatial subsetting limits can be declared in map coordinates or geo coordinates, but not both.")
end

if ~isequal(options.buffer, 0)
    switch numel(options.buffer)
        case 1
            extrakm = options.buffer .* [1 1]; 
        case 2
            extrakm = options.buffer; 
        otherwise
            error("Buffer value must be either a scalar or a two-element array.")
    end
end

%% Define filename: 

filename = ['ITS_LIVE_velocity_120m_RGI',num2str(region,'%02.f'),'A_',num2str(options.year(1),'%04.f'),'_v02.nc']; 
assert(exist(fullfile(options.filepath,filename),'file')==2,['Error: cannot find ',filename,'.']) 

finfo = ncinfo(fullfile(options.filepath,filename)); 
varNames = {finfo.Variables.Name};
if ~any(strcmpi(varNames,variable))
   disp(['Error: Cannot find the specified variable ',variable,'. It should be one of these:'])
   disp(varNames')
   return
end

%% Load data 

% If user only wants vectors, give 'em to 'em and exit the function: 
if ismember(lower(variable),{'x','y'})
   Z = ncread(fullfile(options.filepath,filename),variable); 
   return
end

x = ncread(fullfile(options.filepath,filename),'x'); 
y = ncread(fullfile(options.filepath,filename),'y'); 

if subset
   
    % A crude manual fix for when a single xi,yi lies between pixels: 
    if isscalar(xi)
          extrakm = [max([extrakm(1) 1]) max([extrakm(2) 1])]; 
    end
    
    % Get xlimits (xl) and ylimits (yl) of input coordinates + buffer:
    xl = [min(xi(:))-extrakm(1)*1000 max(xi(:))+extrakm(1)*1000];
    yl = [min(yi(:))-extrakm(2)*1000 max(yi(:))+extrakm(2)*1000];
    
    % Region of rows and columns of pixels to read: 
    ci = find((y>=yl(1)) & (y<=yl(2)));
    ri = find((x>=xl(1)) & (x<=xl(2)));
else
    ci = 1:length(y); 
    ri = 1:length(x); 
end

% Load data: 
Z = NaN(numel(ci),numel(ri),numel(options.year)); 
for k = 1:numel(options.year) 
    fn = fullfile(options.filepath,['ITS_LIVE_velocity_120m_RGI',num2str(region,'%02.f'),'A_',num2str(options.year(k),'%04.f'),'_v02.nc']); 
    Z(:,:,k) = permute(ncread(fn,variable,[ri(1) ci(1)],[length(ri) length(ci)]),[2 1 3]);
end

if ismember(lower(variable),{'sensor_flag','floatingice','landice'})
   Z = logical(Z); 
else
   % % Take care of NaNs: should automatically be taken care of by ncread.
   Z = double(Z); 
end

%% Final adjustments for the export: 

% Give user coordinates if more than one output argument: 
if nargout>1
    if options.geoout
        % Grid the points so we can get lat,lon coordinates of each grid point:  
        [X, Y] = meshgrid(x(ri), y(ci));
        [Lat_or_x, Lon_or_y] = itslive2geo(region, X, Y); 
    else
        Lat_or_x = x(ri); 
        Lon_or_y = y(ci); 
   end
end

end