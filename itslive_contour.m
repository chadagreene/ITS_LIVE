function [C,h] = itslive_contour(varargin)
% itslive_contour plots itslive data on polar stereographic projection map. 
% 
%% Syntax
% 
%  itslive_contour
%  itslive_contour(contourspec,...) 
%  [C,h] = itslive_contour(...)
% 
%% Description 
% 
% itslive_contour plots ITS_LIVE ice speed as a contour object. Large regipns
% might take a while to render. 
% 
% itslive_contour(contourspec,...) accepts any Matlab contour options.
% 
% [C,h] = itslive_contour(...) returns a handle h of the image object. 
% 
%% Examples: 
%
% mapzoomps('pine island glacier') 
% modismoaps('contrast','low')
% itslive_contour
% itslive_quiver
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
% Chad A. Greene wrote this in December of 2019. 
%
% See also: itslive_quiver and itslive_data. 

%% Parse inputs: 

narginchk(0,3)

%% Check the presence of a current axes: 

ax = axis; 
if isequal(ax,[0 1 0 1]) 
   NewMap = true; 
else 
   NewMap = false; 
end

%% Load data: 

if NewMap
   [Z,x,y] = itslive_data('v','xy'); 
else
   [Z,x,y] = itslive_data('v',ax(1:2),ax(3:4),'xy'); 
end 

%% Plot things: 

hold on
[C,h] = contour(x,y,Z,varargin{:}); 

axis xy
daspect([1 1 1]) 

%% Clean up: 

if nargout==0 
   clear C h
end
end

