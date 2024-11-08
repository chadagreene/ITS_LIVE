function h = itslive_regions
% itslive_regions displays a world map with ITS_LIVE mosaic regions labeled. 
% The ITS_LIVE mosaic regions approximately correspond to RGI regions.
% 
%% Syntax 
% 
%  itslive_regions
%  h = itslive_regions 
% 
%% Description 
% 
% itslive_regions displays a map of ITS_LIVE regions. 
% 
% h = itslive_regions also returns a handle h of the plotted object. 
% 
%% Tip: 
% To explore what data are available, check out https://its-live-data.s3.amazonaws.com/index.html.  
% 
%% Author Info 
% Written by Chad A. Greene, NASA/JPL, 2024. 

h = imshow("ITS_LIVE_v2_mosaic_regions.jpeg"); 

if nargout==0
    clear h
end