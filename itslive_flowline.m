function [lat_or_x,lon_or_y,d,v] = itslive_flowline(region,lati_or_xi,loni_or_yi,spacing)
% itslive_flowline calculates ice flowlines using itslive mosaic velocity data. 
% 
% Note: This function takes a few seconds to run. 
%% Syntax 
% 
%  [x,y] = itslive_flowline(region,xi,yi)
%  [lat,lon] = itslive_flowline(region,lati,loni)
%  [...] = itslive_flowline(...,spacing)
%  [...,...,d,v] = itslive_flowline(...)
%  
%% Description 
% 
% [x,y] = itslive_flowline(region,xi,yi) calculates flow path(s) from seed 
% locations given in projected map coordinates xi,yi. If multiple starting  
% points are specified, output xi and yi will be cell arrays. Input region
% is a number from 1 to 19 corresponding to the mosaic region. For a map of
% ITS_LIVE regions, type itslive_regions. Flowlines are calculated upstream
% and downstream of seed location(s). 
% 
% [lat,lon] = itslive_flowline(region,lati,loni) as above, but if inputs are
% geographic coordinates, outputs are too. 
% 
% [...,...,d,v] = itslive_flowline(...) also returns distance d in meters 
% along the flowline. Negative numbers are upstream of the seed location
% and positive numbers are downstream. If four outputs are requested, the
% velocity v (m/yr) is the linearly interpolated velocity along the
% flowline(s). 
% 
% [...] = itslive_flowline(...,spacing) specifies spacing along the flowline
% in meters. Default spacing is 10 m. 
% 
%% Example 1: 
% Make a single flowline down Pine Island Glacier: 
% 
% [lat,lon,d,v] = itslive_flowline(19,-75.56,-96.95);
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
% This function was written by Chad A. Greene of NASA/JPL, November 2024. 

%% Error checks: 

narginchk(3,4)
assert(isscalar(region), 'Region must be a number between 1 and 19.')
assert(ismember(region, [1:12 14 17:19]), 'Region must be a number between 1 and 19.')
assert(isequal(size(lati_or_xi),size(loni_or_yi)),'Input coordinates must have matching dimensions.') 

if nargin<4
    spacing = 10; % m along-path spacing by default
else 
    assert(isscalar(spacing),"Error: Flowline spacing must be a scalar value.")
end

%% Coordinate transformations

if islatlon(lati_or_xi,loni_or_yi)
    assert(license('test','map_toolbox'), "Sorry, inputting geo coordinates into itslive_interp requires MATLAB's Mapping Toolbox. Try transforming the coordinates yourself (via ll2psn for polar regions, ll2ps for Antarctica, or check MATLAB's File Exchange for UTM converters for other regions.), then enter xi,yi instead of lati,loni into itslive_interp.")
    [xi,yi] = geo2itslive(region, lati_or_xi,loni_or_yi); 
    geo_in = true; 
else
    xi = lati_or_xi; 
    yi = loni_or_yi; 
    geo_in = false; 
end

%% Load data

buffer = 1000; % km buffer on all sides of data should be enough to get the entirety of any glacier flowline.  

[vx,x,y] = itslive_data(region,     'vx','xlim',xi,'ylim',yi,'buffer',buffer); 
vy       = itslive_data(region,     'vy','xlim',xi,'ylim',yi,'buffer',buffer); 
V        = itslive_data(region,      'v','xlim',xi,'ylim',yi,'buffer',buffer); 
landice  = itslive_data(region,'landice','xlim',xi,'ylim',yi,'buffer',buffer); 
count    = itslive_data(region,  'count','xlim',xi,'ylim',yi,'buffer',buffer); 
v_error  = itslive_data(region,'v_error','xlim',xi,'ylim',yi,'buffer',buffer); 

% Eliminate slow-moving, non-ice, and low-confidence data: 
bad = V<10 | count<100 | v_error>(100 + 0.1*V) | ~landice; 
vx(bad) = nan; 
vy(bad) = nan; 

%% Compute streamlines: 

% Backward motion, then forward motion: 
XY_minus = cellfun(@flipud,stream2(x,y,-vx,-vy,xi,yi,[0.2 1e6]),'UniformOutput',false); 
XY_plus = stream2(x,y,vx,vy,xi,yi,[0.2 1e6]); 

XY_minus = reshape(XY_minus,size(xi)); 
XY_plus = reshape(XY_plus,size(xi)); 

% Preallocate cell grid for coordinates:
x_flowlines = cell(size(XY_plus)); 
y_flowlines = x_flowlines; 
d = x_flowlines; 

% For each seed location, make a path of uniform spacing:  
for k = 1:numel(x_flowlines)
   xtmp = [XY_minus{k}(:,1);XY_plus{k}(2:end,1)]; 
   ytmp = [XY_minus{k}(:,2);XY_plus{k}(2:end,2)]; 
   isf = hypot(interp2(x,y,vx,xtmp,ytmp),interp2(x,y,vy,xtmp,ytmp))>0.5; % This makes sure only finite values are kept, and it doesn't get into the crazy shit that happens with tiny speeds close to basin boundaries. 
   
   % Overly complicated indexing to keep track of the starting point: 
   ind = (1:numel(xtmp))'; 
   ind(1:numel(XY_minus{k}(:,1))) = 0; 
   ind(~isf) = []; 
   f = find(ind>0,1,'first'); 
   f = max([f-1 1]); 

   % Calculate distance along the path given by input coordinates:  
   dtmp = cumsum(hypot([0;diff(xtmp(isf))],[0;diff(ytmp(isf))])); 
   dtmp = dtmp - dtmp(f); % references distance to the starting point.

   % Interpolate xi and yi values individually to common spacing along the path: 
   if any(isf)
       d{k} = dtmp(1):spacing:dtmp(end); 
       x_flowlines{k} = interp1(dtmp,xtmp(isf),d{k},'pchip'); 
       y_flowlines{k} = interp1(dtmp,ytmp(isf),d{k},'pchip'); 
   end

end
  
if nargout>3
    v = cell(size(XY_plus));
    for k = 1:numel(d)
        v{k} = interp2(x,y,V,x_flowlines{k},y_flowlines{k});
    end
    
    % Convert if only a single grid point was entered: 
    if isscalar(xi)
        v = cell2mat(v); 
    end
  
end
   
%% Package up the outputs: 

% Change variable names: 
lat_or_x = x_flowlines; 
lon_or_y = y_flowlines; 

% And convert to geo coordinates if geo were inputs: 
if geo_in
    for k = 1:numel(x_flowlines)
        [lat_or_x{k},lon_or_y{k}] = itslive2geo(region, x_flowlines{k},y_flowlines{k}); 
    end
end

% Convert if only a single grid point was entered: 
if isscalar(xi)
   lat_or_x = cell2mat(lat_or_x); 
   lon_or_y = cell2mat(lon_or_y); 
   d = cell2mat(d); 
end

%% Plot? 

% if plot_flowlines
%     h = plot(cell2nancat(lat_or_x),cell2nancat(lon_or_y),varargin{:}); 
% end

end



function tf = islatlon(lat,lon)
% islatlon determines whether lat,lon is likely to represent geographical
% coordinates. 
% 
%% Citing Antarctic Mapping Tools
% This function was developed for Antarctic Mapping Tools for Matlab (AMT). If AMT is useful for you,
% please cite our paper: 
% 
% Greene, C. A., Gwyther, D. E., & Blankenship, D. D. Antarctic Mapping Tools for Matlab. 
% Computers & Geosciences. 104 (2017) pp.151-157. 
% http://dx.doi.org/10.1016/j.cageo.2016.08.003
% 
% @article{amt,
%   title={{Antarctic Mapping Tools for \textsc{Matlab}}},
%   author={Greene, Chad A and Gwyther, David E and Blankenship, Donald D},
%   journal={Computers \& Geosciences},
%   year={2017},
%   volume={104},
%   pages={151--157},
%   publisher={Elsevier}, 
%   doi={10.1016/j.cageo.2016.08.003}, 
%   url={http://www.sciencedirect.com/science/article/pii/S0098300416302163}
% }
%   
%% Syntax
% 
% tf = islatlon(lat,lon) returns true if all values in lat are numeric
% between -90 and 90 inclusive, and all values in lon are numeric between 
% -180 and 360 inclusive. 
% 
%% Example 1: A single location
% 
% islatlon(110,30)
%    = 0
% 
% because 110 is outside the bounds of latitude values. 
% 
%% Example 2: A grid
% 
% [lon,lat] = meshgrid(-180:180,90:-1:-90); 
% 
% islatlon(lat,lon)
%    = 1 
% 
% because all values in lat are between -90 and 90, and all values in lon
% are between -180 and 360.  What if it's really, really close? What if
% just one value violates these rules? 
% 
% lon(1) = -180.002; 
% 
% islatlon(lat,lon)
%    = 0
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG). http://www.chadagreene.com. 
% March 30, 2015. 
% 
% See also wrapTo180, wrapTo360, projfwd, and projinv.  

% Make sure there are two inputs: 
narginchk(2,2)

% Set default output: 
tf = true; 

%% If *any* inputs don't look like lat,lon, assume none of them are lat,lon. 

if ~isnumeric(lat)
    tf = false; 
    return
end

if ~isnumeric(lon)
    tf = false; 
    return
end
if any(abs(lat(:))>90)
    tf = false; 
    return
end

if any(lon(:)>360)
    tf = false; 
    return
end    

if any(lon(:)<-180)
    tf = false; 
end

end