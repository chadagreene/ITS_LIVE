function zi = itslive_interp(region,variable,lati_or_xi,loni_or_yi,options)
% itslive_interp interpolates ITS_LIVE velocity data to specified points. 
% 
%% Syntax
% 
%  zi = itslive_interp(region,variable,xi,yi)
%  zi = itslive_interp(region,variable,lati,loni)
%  zi = itslive_interp(..., method=InterpMethod)
%  zi = itslive_interp(..., year=years)
%  v_along = = itslive_interp(region,'along',...)
%  v_across = = itslive_interp(region,'across',...)
% 
%% Description 
% 
% zi = itslive_interp(region,variable,xi,yi) interpolates ITS_LIVE mosaic
% data for the specified region and variable, at the projected map
% coordinates xi, yi. The region is a number from 1 to 19 (type
% itslive_regions for a map). The variable can be 'v', 'vx', 'v_error', or
% any gridded variable in the ITS_LIVE v2 mosaics. Coordinates xi,yi
% correspond to the map units (m) in the projection of the specified
% region. 
% 
% zi = itslive_interp(region,variable,lati,loni) as above, but using
% geographic coordinates. 
% 
% zi = itslive_interp(..., method=InterpMethod) specifies an interpolation 
% method. Interpolation is linear by default, except for variables 'landice', 
% and 'floatingice', which are nearest neighbor. 
% 
% zi = itslive_interp(...,'year',years) specifies years of velocity
% mosaics. Default is 0000, which corresponds to summary mosaics. 
% 
% v_across = itslive_interp(region, 'across',...) calculates the 
% across-track velocity for a path such as a grounding line lati,loni or xi,yi. 
% This is designed for calculating the flow across a flux gate. 
% 
% v_along = itslive_interp(region, 'along',...) the complement 
% to the across track component.  
% 
%% Example 1 
% Byrd glacier grounding line:
% 
% year = 2014:2022; 
% v = itslive_interp(19, 'v',-80.38,158.75,'year',year); 
% v_error = itslive_interp(19, 'v_error',-80.38,158.75,'year',year); 
% 
% figure
% errorbar(year,v,v_error) 
% xlim([2013 2023])
% ylabel('Annual velocity (m yr^{-1})')
% title 'Byrd Glacier, Antarctica'
% 
%% Example 2
% Multiple locations along Malaspina Gl, Alaska, and multiple years. 
% 
% % Define locations and years of interest: 
% lat = [60.08343 60.02582 59.92546 59.83722]; 
% lon = [-140.46707 -140.57831 -140.72388 -140.80765]; 
% years = 2014:2022; 
%
% v = itslive_interp(1, 'v', lat, lon, year=years); 
% v_error = itslive_interp(1, 'v_error', lat, lon, year=years); 
% 
% figure
% errorbar(years,v, v_error)
% title 'Malaspina Glacier, Alaska'
% xlim([2013 2023])
% ylabel('Annual velocity (m yr^{-1})')
% 
%% More Examples
% 
% For more examples, see the documentation at:
% https://github.com/chadagreene/ITS_LIVE.
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
% See also itslive_data. 

%% Input parsing 

arguments
    region {mustBeMember(region,[1:12 14 17:19])}
    variable {mustBeText}
    lati_or_xi {mustBeNumeric}
    loni_or_yi {mustBeNumeric}
    options.method {mustBeText} = "linear"
    options.year (:,1) {mustBeNumeric} = 0000
    options.filepath {mustBeText} = ""
end

assert(isequal(size(lati_or_xi),size(loni_or_yi)),'Error: Input query points must have matching dimensions.') 

if ismember(lower(variable),{'along','across'})
   FluxGate = true; 
else
   FluxGate = false; 
end

%% Coordinate transformations

if islatlon(lati_or_xi,loni_or_yi)
    assert(license('test','map_toolbox'), "Sorry, inputting geo coordinates into itslive_interp requires MATLAB's Mapping Toolbox. Try transforming the coordinates yourself (via ll2psn for polar regions, ll2ps for Antarctica, or check MATLAB's File Exchange for UTM converters for other regions.), then enter xi,yi instead of lati,loni into itslive_interp.")
    [xi,yi] = geo2itslive(region, lati_or_xi,loni_or_yi); 
else
    xi = lati_or_xi; 
    yi = loni_or_yi; 
end

%% Load data: 

if FluxGate
    [vx,x,y] = itslive_data(region, 'vx'   , xlim=xi, ylim=yi, buffer=1, year=options.year, filepath=options.filepath); 
    vy       = itslive_data(region, 'vy'   , xlim=xi, ylim=yi, buffer=1, year=options.year, filepath=options.filepath); 
else 
    [Z,x,y]  = itslive_data(region,variable, xlim=xi, ylim=yi, buffer=1, year=options.year, filepath=options.filepath); 
end

%% Interpolate: 

if FluxGate
   
   % Preallocate: 
   vxi = NaN(size(xi,1),size(xi,2),size(vx,3)); 
   vyi = vxi; 

   % Interpolate: 
   for k = 1:size(vx,3)
      vxi(:,:,k) = interp2(x,y,vx(:,:,k),xi,yi,options.method); 
      vyi(:,:,k) = interp2(x,y,vy(:,:,k),xi,yi,options.method); 
   end
   
else
   
   if islogical(Z)
      
      % Preallocate:
      zi = false(size(xi,1),size(xi,2),size(Z,3)); 

      for k=1:size(Z,3)
         zi(:,:,k) = interp2(x,y,Z(:,:,k),xi,yi,'nearest',0); 
      end
   else
      
      % Preallocate:
      zi = NaN(size(xi,1),size(xi,2),size(Z,3)); 

      % Interpolate: 
      for k = 1:size(Z,3)
         zi(:,:,k) = interp2(x,y,Z(:,:,k),xi,yi,options.method); 
      end
   end
end


%% Convert to along/across track components:

if FluxGate
   
   % Calculate along-track angles
   if isrow(x)
      di = [0,cumsum(hypot(diff(xi),diff(yi)))]; % Cumulative sum of distances 
   else
      di = [0;cumsum(hypot(diff(xi),diff(yi)))];
   end
   fx = gradient(xi,di); 
   fy = gradient(yi,di);
   theta = atan2(fy,fx);          

   % Convert x and y components to cross-track component: 
   v_along = vxi.*cos(theta) + vyi.*sin(theta);       
   v_across = vxi.*sin(theta) - vyi.*cos(theta); 

   switch lower(variable)
      case 'along'
         zi = squeeze(v_along); 
      case 'across'
         zi = squeeze(v_across);
      otherwise
         error(['unrecognized variable ',variable])
   end

end

%% 

if isequal([size(zi,1) size(zi,1)],[1 1])
   zi = squeeze(zi); 
end

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