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
% Z = itslive_data(...,'region',region) specifies a region as ALA, ANT, 
% CAN, GRE, HMA, ICE, PAT, or SRA. So far I know the ANT option works, but 
% all other regions are currently in beta, so let me know if you experience 
% any problems. ANT is the default region. 
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
               assert(exist('projcrs.m','file')==2,'Sorry, the ALA,CAN,GRE,ICE, and SRA projections require Matlab 2020b or later AND the Mapping Toolbox. However, this can easily be rewritten to rely on Arctic Mapping Tools ll2psn function instead.') 
               proj = projcrs(3413,'authority','EPSG'); 
               [xi,yi] = projfwd(proj,lati_or_xi,loni_or_yi); 
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
         otherwise
            [Lat_or_x,Lon_or_y] = projinv(proj,X,Y); 
      end
   end
end
     

end


function [x,y,f]=ll2utm(varargin)
%LL2UTM Lat/Lon to UTM coordinates precise conversion.
%	[X,Y]=LL2UTM2(LAT,LON) or LL2UTM([LAT,LON]) converts coordinates 
%	LAT,LON (in degrees) to UTM X and Y (in meters). Default datum is WGS84.
%
%	LAT and LON can be scalars, vectors or matrix. Outputs X and Y will
%	have the same size as inputs.
%
%	LL2UTM(...,DATUM) uses specific DATUM for conversion. DATUM can be one
%	of the following char strings:
%		'wgs84': World Geodetic System 1984 (default)
%		'nad27': North American Datum 1927
%		'clk66': Clarke 1866
%		'nad83': North American Datum 1983
%		'grs80': Geodetic Reference System 1980
%		'int24': International 1924 / Hayford 1909
%	or DATUM can be a 2-element vector [A,F] where A is semimajor axis (in
%	meters)	and F is flattening of the user-defined ellipsoid.
%
%	LL2UTM(...,ZONE) forces the UTM ZONE (scalar integer or same size as
%   LAT and LON) instead of automatic set.
%
%	[X,Y,ZONE]=LL2UTM(...) returns also the computed UTM ZONE (negative
%	value for southern hemisphere points).
%
%
%	XY=LL2UTM(...) or without any output argument returns a 2-column 
%	matrix [X,Y].
%
%	Note:
%		- LL2UTM does not perform cross-datum conversion.
%		- precision is near a millimeter.
%
%
%	Reference:
%		I.G.N., Projection cartographique Mercator Transverse: Algorithmes,
%		   Notes Techniques NT/G 76, janvier 1995.
%
%	Acknowledgments: Mathieu, Frederic Christen.
%
%
%	Author: Francois Beauducel, <beauducel@ipgp.fr>
%	Created: 2003-12-02
%	Updated: 2015-01-29


%	Copyright (c) 2001-2015, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without 
%	modification, are permitted provided that the following conditions are 
%	met:
%
%	   * Redistributions of source code must retain the above copyright 
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright 
%	     notice, this list of conditions and the following disclaimer in 
%	     the documentation and/or other materials provided with the distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%	POSSIBILITY OF SUCH DAMAGE.

% Available datums
datums = [ ...
	{ 'wgs84', 6378137.0, 298.257223563 };
	{ 'nad83', 6378137.0, 298.257222101 };
	{ 'grs80', 6378137.0, 298.257222101 };
	{ 'nad27', 6378206.4, 294.978698214 };
	{ 'int24', 6378388.0, 297.000000000 };
	{ 'clk66', 6378206.4, 294.978698214 };
];

% constants
D0 = 180/pi;	% conversion rad to deg
K0 = 0.9996;	% UTM scale factor
X0 = 500000;	% UTM false East (m)

% defaults
datum = 'wgs84';
zone = [];

if nargin < 1
	error('Not enough input arguments.')
end

if nargin > 1 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && all(size(varargin{1})==size(varargin{2}))
	lat = varargin{1};
	lon = varargin{2};
	v = 2;
elseif isnumeric(varargin{1}) && size(varargin{1},2) == 2
	lat = varargin{1}(:,1);
	lon = varargin{1}(:,2);
	v = 1;
else
	error('Single input argument must be a 2-column matrix [LAT,LON].')
end

if all([numel(lat),numel(lon)] > 1) && any(size(lat) ~= size(lon))
	error('LAT and LON must be the same size or scalars.')
end

for n = (v+1):nargin
	% LL2UTM(...,DATUM)
	if ischar(varargin{n}) || (isnumeric(varargin{n}) && numel(varargin{n})==2)
		datum = varargin{n};
	% LL2UTM(...,ZONE)
	elseif isnumeric(varargin{n}) && (isscalar(varargin{n}) || all(size(varargin{n})==size(lat)))
			zone = round(varargin{n});
	else
		error('Unknown argument #%d. See documentation.',n)
	end
end

if ischar(datum)
	% LL2UTM(...,DATUM) with DATUM as char
	if ~any(strcmpi(datum,datums(:,1)))
		error('Unkown DATUM name "%s"',datum);
	end
	k = find(strcmpi(datum,datums(:,1)));
	A1 = datums{k,2};
	F1 = datums{k,3};	
else
	% LL2UTM(...,DATUM) with DATUM as [A,F] user-defined
	A1 = datum(1);
	F1 = datum(2);
end

p1 = lat/D0;			% Phi = Latitude (rad)
l1 = lon/D0;			% Lambda = Longitude (rad)

% UTM zone automatic setting
if isempty(zone)
	F0 = round((l1*D0 + 183)/6);
else
	F0 = zone;
end

B1 = A1*(1 - 1/F1);
E1 = sqrt((A1*A1 - B1*B1)/(A1*A1));
P0 = 0/D0;
L0 = (6*F0 - 183)/D0;	% UTM origin longitude (rad)
Y0 = 1e7*(p1 < 0);		% UTM false northern (m)
N = K0*A1;

C = coef(E1,0);
B = C(1)*P0 + C(2)*sin(2*P0) + C(3)*sin(4*P0) + C(4)*sin(6*P0) + C(5)*sin(8*P0);
YS = Y0 - N*B;

C = coef(E1,2);
L = log(tan(pi/4 + p1/2).*(((1 - E1*sin(p1))./(1 + E1*sin(p1))).^(E1/2)));
z = complex(atan(sinh(L)./cos(l1 - L0)),log(tan(pi/4 + asin(sin(l1 - L0)./cosh(L))/2)));
Z = N.*C(1).*z + N.*(C(2)*sin(2*z) + C(3)*sin(4*z) + C(4)*sin(6*z) + C(5)*sin(8*z));
xs = imag(Z) + X0;
ys = real(Z) + YS;

% outputs zone if needed: scalar value if unique, or vector/matrix of the
% same size as x/y in case of crossed zones
if nargout > 2
   	f = F0.*sign(lat);
	fu = unique(f);
	if isscalar(fu)
		f = fu;
	end
end

if nargout < 2
	x = [xs(:),ys(:)];
else
	x = xs;
	y = ys;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = coef(e,m)
%COEF Projection coefficients
%	COEF(E,M) returns a vector of 5 coefficients from:
%		E = first ellipsoid excentricity
%		M = 0 for transverse mercator
%		M = 1 for transverse mercator reverse coefficients
%		M = 2 for merdian arc


if nargin < 2
	m = 0;
end

switch m
	case 0
	c0 = [-175/16384, 0,   -5/256, 0,  -3/64, 0, -1/4, 0, 1;
           -105/4096, 0, -45/1024, 0,  -3/32, 0, -3/8, 0, 0;
           525/16384, 0,  45/1024, 0, 15/256, 0,    0, 0, 0;
          -175/12288, 0, -35/3072, 0,      0, 0,    0, 0, 0;
          315/131072, 0,        0, 0,      0, 0,    0, 0, 0];
	  
	case 1
	c0 = [-175/16384, 0,   -5/256, 0,  -3/64, 0, -1/4, 0, 1;
             1/61440, 0,   7/2048, 0,   1/48, 0,  1/8, 0, 0;
          559/368640, 0,   3/1280, 0,  1/768, 0,    0, 0, 0;
          283/430080, 0, 17/30720, 0,      0, 0,    0, 0, 0;
       4397/41287680, 0,        0, 0,      0, 0,    0, 0, 0];

	case 2
	c0 = [-175/16384, 0,   -5/256, 0,  -3/64, 0, -1/4, 0, 1;
         -901/184320, 0,  -9/1024, 0,  -1/96, 0,  1/8, 0, 0;
         -311/737280, 0,  17/5120, 0, 13/768, 0,    0, 0, 0;
          899/430080, 0, 61/15360, 0,      0, 0,    0, 0, 0;
      49561/41287680, 0,        0, 0,      0, 0,    0, 0, 0];
   
end
c = zeros(size(c0,1),1);

for i = 1:size(c0,1)
    c(i) = polyval(c0(i,:),e);
end
end

function [lat,lon]=utm2ll(x,y,f,datum,varargin)
%UTM2LL UTM to Lat/Lon coordinates precise conversion.
%	[LAT,LON]=UTM2LL(X,Y,ZONE) converts UTM coordinates X,Y (in meters)
%	defined in the UTM ZONE (integer) to latitude LAT and longitude LON 
%	(in degrees). Default datum is WGS84.
%
%	X, Y and F can be scalars, vectors or matrix. Outputs LAT and LON will
%	have the same size as inputs.
%
%	For southern hemisphere points, use negative zone -ZONE.
%
%	UTM2LL(X,Y,ZONE,DATUM) uses specific DATUM for conversion. DATUM can be
%	a string in the following list:
%		'wgs84': World Geodetic System 1984 (default)
%		'nad27': North American Datum 1927
%		'clk66': Clarke 1866
%		'nad83': North American Datum 1983
%		'grs80': Geodetic Reference System 1980
%		'int24': International 1924 / Hayford 1909
%	or DATUM can be a 2-element vector [A,F] where A is semimajor axis (in
%	meters)	and F is flattening of the user-defined ellipsoid.
%
%	Notice:
%		- UTM2LL does not perform cross-datum conversion.
%		- precision is near a millimeter.
%
%
%	Reference:
%		I.G.N., Projection cartographique Mercator Transverse: Algorithmes,
%		   Notes Techniques NT/G 76, janvier 1995.
%
%	Author: Francois Beauducel, <beauducel@ipgp.fr>
%	Created: 2001-08-23
%	Updated: 2015-01-29


%	Copyright (c) 2001-2015, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without 
%	modification, are permitted provided that the following conditions are 
%	met:
%
%	   * Redistributions of source code must retain the above copyright 
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright 
%	     notice, this list of conditions and the following disclaimer in 
%	     the documentation and/or other materials provided with the distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%	POSSIBILITY OF SUCH DAMAGE.

% Available datums
datums = [ ...
	{ 'wgs84', 6378137.0, 298.257223563 };
	{ 'nad83', 6378137.0, 298.257222101 };
	{ 'grs80', 6378137.0, 298.257222101 };
	{ 'nad27', 6378206.4, 294.978698214 };
	{ 'int24', 6378388.0, 297.000000000 };
	{ 'clk66', 6378206.4, 294.978698214 };
];

if nargin < 3
	error('Not enough input arguments.')
end

if all([numel(x),numel(y)] > 1) && any(size(x) ~= size(y))
	error('X and Y must be the same size or scalars.')
end

if ~isnumeric(f) || any(f ~= round(f)) || (~isscalar(f) && any(size(f) ~= size(x)))
	error('ZONE must be integer value, scalar or same size as X and/or Y.')
end

if nargin < 4
	datum = 'wgs84';
end

if ischar(datum)
	if ~any(strcmpi(datum,datums(:,1)))
		error('Unkown DATUM name "%s"',datum);
	end
	k = find(strcmpi(datum,datums(:,1)));
	A1 = datums{k,2};
	F1 = datums{k,3};	
else
	if numel(datum) ~= 2
		error('User defined DATUM must be a vector [A,F].');
	end
	A1 = datum(1);
	F1 = datum(2);
end

% constants
D0 = 180/pi;	% conversion rad to deg
maxiter = 100;	% maximum iteration for latitude computation
eps = 1e-11;	% minimum residue for latitude computation

K0 = 0.9996;					% UTM scale factor
X0 = 500000;					% UTM false East (m)
Y0 = 1e7*(f < 0);				% UTM false North (m)
P0 = 0;						% UTM origin latitude (rad)
L0 = (6*abs(f) - 183)/D0;			% UTM origin longitude (rad)
E1 = sqrt((A1^2 - (A1*(1 - 1/F1))^2)/A1^2);	% ellpsoid excentricity
N = K0*A1;

% computing parameters for Mercator Transverse projection
C = coef(E1,0);
YS = Y0 - N*(C(1)*P0 + C(2)*sin(2*P0) + C(3)*sin(4*P0) + C(4)*sin(6*P0) + C(5)*sin(8*P0));

C = coef(E1,1);
zt = complex((y - YS)/N/C(1),(x - X0)/N/C(1));
z = zt - C(2)*sin(2*zt) - C(3)*sin(4*zt) - C(4)*sin(6*zt) - C(5)*sin(8*zt);
L = real(z);
LS = imag(z);

l = L0 + atan(sinh(LS)./cos(L));
p = asin(sin(L)./cosh(LS));

L = log(tan(pi/4 + p/2));

% calculates latitude from the isometric latitude
p = 2*atan(exp(L)) - pi/2;
p0 = NaN;
n = 0;
while any(isnan(p0(:)) | abs(p(:) - p0(:)) > eps) && n < maxiter
	p0 = p;
	es = E1*sin(p0);
	p = 2*atan(((1 + es)./(1 - es)).^(E1/2).*exp(L)) - pi/2;
	n = n + 1;
end

if nargout < 2
	lat = D0*[p(:),l(:)];
else
	lat = p*D0;
	lon = l*D0;
end
end