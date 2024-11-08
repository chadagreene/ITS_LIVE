function [lat, lon] = itslive2geo(region, x, y)
% itslive2geo transforms projected map coordinates to geographic coordinates.
% 
%% Syntax
% 
%  [lat, lon] = itslive2geo(region, x, y)
% 
%% Description 
% 
% [lat, lon] = itslive2geo(region, x, y) converts projected map coordinates
% x,y into geographic coordinates lat,lon. The region must be a
% number from 1 to 19 corresponding to ITS_LIVE regions (which
% approximately match RGI regions). For a map of ITS_LIVE regions, type 
% itslive_regions. 
%
%% Example
% % Convert this spot on Malaspina Glacier Alaska (Region 1) to map coordinates: 
% 
%  [x, y] = geo2itslive(1, 60.08343, -140.46707)
%  
%  x =
%     -3298427.76
%  y =
%       315689.27
% 
% % Now convert them back into geocoordinates: 
% 
%  [lat, lon] = itslive2geo(1, x, y)
%  
%  lat =
%     60.0834
%  lon =
%   -140.4671
% 
%% Author Info 
% Written by Chad A. Greene, NASA/JPL, 2024. 

arguments
    region {mustBeMember(region,[1:12 14 17:19])}
    x {mustBeNumeric}
    y {mustBeNumeric}
end

assert(license('test','map_toolbox'), "Sorry, converting coordinates with the geo2itslive function requires a license for MATLAB's Mapping Toolbox. For northern regions that use the 3413 projection, you can simply use ll2psn in the Arctic Mapping Tools (easily downloadable from the Add-Ons menu). For Antarctica use ll2ps from Antarctic Mapping Tools.")
assert(isequal(size(x),size(y)), "Dimensions of input arrays x,y must exactly match each other.") 

%%

proj_code = [3413 32610 3413 3413 3413 3413 3413 3413 3413 32645 32632 32638 NaN 102027 NaN NaN 32718 32759 3031];

if region==14
    authority = 'ESRI'; 
else
    authority = 'EPSG'; 
end

proj = projcrs(proj_code(region), "Authority",authority); 

[lat, lon] = projinv(proj, x, y); 

end

