function [x, y] = geo2itslive(region, lat, lon)
% geo2itslive transforms geographic coordinates to projected map
% coordinates corresponding to a given ITS_LIVE velocity mosaic region. 
% 
%% Syntax
% 
%  [x, y] = geo2itslive(region, lat, lon)
% 
%% Description 
% 
% [x, y] = geo2itslive(region, lat, lon) converts the geocoordinates lat,
% lon into projected map coordinates x,y in meters. The region must be a
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
%% Citing this data
% If you use ITS_LIVE v2 velocity data, please cite:  
%
% Gardner, A. S., Greene, C. A., Kennedy, J. H., Fahnestock, M. A., Liukis, 
% M., López, L. A., Lei, Y., Scambos, T. A., and Dehecq, A.: ITS_LIVE global 
% glacier velocity data in near real time, EGUsphere [preprint], 
% https://doi.org/10.5194/egusphere-2025-392, 2025. 
%
%% Author Info 
% Written by Chad A. Greene, NASA/JPL, 2024. 

arguments
    region {mustBeMember(region,[1:12 14 17:19])}
    lat {mustBeLatitude(lat)}
    lon {mustBeLongitude(lon)}
end

assert(license('test','map_toolbox'), "Sorry, converting coordinates with the geo2itslive function requires a license for MATLAB's Mapping Toolbox. For northern regions that use the 3413 projection, you can simply use ll2psn in the Arctic Mapping Tools (easily downloadable from the Add-Ons menu). For Antarctica use ll2ps from Antarctic Mapping Tools.")
assert(isequal(size(lat),size(lon)), "Dimensions of input arrays lat,lon must exactly match each other.") 

%%

proj_code = [3413 32610 3413 3413 3413 3413 3413 3413 3413 32645 32632 32638 NaN 102027 NaN NaN 32718 32759 3031];

if region==14
    authority = 'ESRI'; 
else
    authority = 'EPSG'; 
end

proj = projcrs(proj_code(region), "Authority",authority); 

[x, y] = projfwd(proj, lat, lon); 

end

function mustBeLatitude(lat)
    if or(any(lat(:)<-90), any(lat(:)>90))
        error("Latitude values are outside of plausible range.")
    end
end

function mustBeLongitude(lon)
    if or(any(lon(:)<-180), any(lon(:)>360))
        error("Longitude values are outside of plausible range.")
    end
end