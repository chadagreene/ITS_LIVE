function [lat_or_x,lon_or_y,d,v,t,h] = itslive_flowline(lati_or_xi,loni_or_yi,varargin)
% itslive_flowline calculates ice flowlines using itslive mosaic velocity data. 
%
%% Syntax 
% 
%  [lat,lon] = itslive_flowline(lati,loni)
%  [x,y] = itslive_flowline(xi,yi)
%  [lat_or_x,lon_or_y,d,v,t,h] = itslive_flowline(...)
%  [...] = itslive_flowline(...,'gl') 
%  [...] = itslive_flowline(...,'region',region)
%  [...,h] = itslive_flowline(...,'plot',LineProperty,LineValue,...) 
%  
%% Description 
% 
% [lat,lon] = itslive_flowline(lati,loni) calculates flow path(s) from seed locations
% given by geographic coordinate(s) lati,loni. If multiple starting points 
% are specified, output lat and lon will be cell arrays. 
% 
% [x,y] = itslive_flowline(xi,yi) as above, but if input coordinates are south polar 
% stereographic meters, outputs will also be in ps71 meters. 
% 
% [lat_or_x,lon_or_y,d,v,t] = itslive_flowline(...) returns corresponding speed v (m/yr), time t (yr), and 
% distance d (km) vectors for each flow line. Time and distance are measured from the starting
% location(s).
% 
% [...] = itslive_flowline(...,'gl') 
%
% [...] = itslive_flowline(...,'region',region) specifies a region as 'ALA', 'ANT', 
% 'CAN', 'GRE', 'HMA', 'ICE', 'PAT', or 'SRA'. Default region is 'ANT'. 
% 
% [...,h] = itslive_flowline(...,'plot',LineProperty,LineValue,...) 
% 
%% Example 1: 
% Make a single flowline down Pine Island Glacier: 
% 
% [lat,lon,d,v] = itslive_flowline(-75.56,-96.95);

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

%% Error checks: 

warning 'I am pretty sure I have not finished writing this function yet, but it might work.'
narginchk(2,Inf)
assert(isequal(size(lati_or_xi),size(loni_or_yi)),'Input coordinates must have matching dimensions.') 

%% Input pasing: 

if islatlon(lati_or_xi,loni_or_yi)
   geo_in = true; 
   [xi,yi] = ll2ps(lati_or_xi,loni_or_yi); 
else
   geo_in = false; 
   xi = lati_or_xi; 
   yi = loni_or_yi; 
end

plot_flowlines = false; 
tmp = strcmpi(varargin,'plot'); 
if any(tmp)
   plot_flowlines = true; 
   varargin = varargin(~tmp); 
end

glref = false; 
tmp = strcmpi(varargin,'gl'); 
if any(tmp)
   glref = true; 
   varargin = varargin(~tmp); 
end

tmp = strncmpi(varargin,'region',3); 
if any(tmp) 
   region = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1)=1; 
   varargin = varargin(~tmp); 
else
   region = 'ANT'; % antarctica by default
end

%% Load data

[vx,x,y] = itslive_data('vx',xi,yi,'buffer',1000,'region',region); 
vy = itslive_data('vy',xi,yi,'buffer',1000,'region',region); 

%% Compute streamlines: 

% Backward motion, then forward motion: 
XY_minus = cellfun(@flipud,stream2(x,y,-vx,-vy,xi,yi,[0.1 1e5]),'UniformOutput',false); 
XY_plus = stream2(x,y,vx,vy,xi,yi,[0.1 1e5]); 

% Preallocate cell grid for coordinates:
lat_or_x = cell(size(XY_plus)); 
lon_or_y = lat_or_x; 

% For each seed location, make a polar stereographic path of uniform spacing:  
for k = 1:numel(lat_or_x)
   xtmp = [XY_minus{k}(:,1);XY_plus{k}(2:end,1)]; 
   ytmp = [XY_minus{k}(:,2);XY_plus{k}(2:end,2)]; 
   isf = hypot(interp2(x,y,vx,xtmp,ytmp),interp2(x,y,vy,xtmp,ytmp))>0.5; % This makes sure only finite values are kept, and it doesn't get into the crazy shit that happens with tiny speeds close to basin boundaries. 
   
   [lat_or_x{k},lon_or_y{k}] = pspath(xtmp(isf),ytmp(isf),100,'method','pchip'); % 100 m spacing
end
  
if nargout>2
   % Distance traveled: 
   d = cell(size(XY_plus)); 
   for k = 1:numel(d)
      d{k} = pathdistps(lat_or_x{k},lon_or_y{k},'km'); 
   end
   
   % If the grounding line is the reference for distance traveled: 
   if glref
      for k=1:numel(d)
         % Find the last grounded index: 
         idx = find(isgrounded(lat_or_x{k},lon_or_y{k}),1,'last');
         d{k} = d{k} - d{k}(idx); 
      end
   end
   
   if nargout>3
      v = cell(size(XY_plus));
      for k = 1:numel(d)
         v{k} = hypot(interp2(x,y,vx,lat_or_x{k},lon_or_y{k}),interp2(x,y,vx,lat_or_x{k},lon_or_y{k}));
      end
      
      % Convert if only a single grid point was entered: 
      if isscalar(xi)
         v = cell2mat(v); 
      end
      
      if isscalar(xi)
         d = cell2mat(d); 
         t = cumsum([0;diff(d)]./v); 
      else
         t = cell(size(XY_plus)); 
         for k=1:numel(d)
            t{k} = cumsum([0;diff(d{k})]./v{k}); 
         end
      end
   end
   
      
end



%% Package up the outputs: 


if nargout>1 & geo_in
   for k = 1:numel(lat_or_x)
      [lat_or_x{k},lon_or_y{k}] = ps2ll(lat_or_x{k},lon_or_y{k}); 
   end
end

% Convert if only a single grid point was entered: 
if isscalar(xi)
   lat_or_x = cell2mat(lat_or_x); 
   lon_or_y = cell2mat(lon_or_y); 
end
   


%% Plot? 


% X = cellfun(@(a) a(:,1),XY,'UniformOutput',false); 
% Y = cellfun(@(a) a(:,2),XY,'UniformOutput',false); 

if plot_flowlines
    h = plot(cell2nancat(lat_or_x),cell2nancat(lon_or_y),varargin{:}); 
end

end



function B = cell2nancat(A) 
%cell2nancat concatenates elements of a cell into a NaN-separated vector. 
% 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG), January 2016. 
% http://www.chadagreene.com 
% 
% See also: cell2mat, nan, and cat. 

%% Input checks:

narginchk(1,1) 
assert(iscell(A),'Input error: Input must be a cell array.')

%% Perform mathematics and whatnot: 

% Append a NaN to each array inside A: 
Anan = cellfun(@(x) [x;NaN(size(x,2))],A,'un',0);

% Columnate: 
B = cell2mat(Anan(:));

end
