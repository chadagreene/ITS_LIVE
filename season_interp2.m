function [Ai,phi] = season_interp2(x,y,A,ph,xi,yi,InterpMethod)
% season_interp2 performs 2D interpolation on a grid of phase values from
% ITS_LIVE seasonal data. Phase is in units of day of year. This function 
% is mainly a workaround for the discontinuity over new years. 

%% Syntax 
% 
%  phi = season_interp2(x,y,ph,xi,yi,InterpMethod)
%  phi = season_interp2(x,y,ph,xi,yi)
% 
%% Author Info
% Written by Chad A. Greene of NASA/JPL, May 2022. 

narginchk(6,7)
assert(max(ph,[],'all')<366,'phase must not exceed 365.25')

if nargin<7
   InterpMethod = 'linear'; 
end

%% Transform coordinates and interpolate 

% Transform "polar" coordinates to cartesian: 
[xtmp,ytmp] = pol2cart(ph*2*pi/365.25,A); 

% Do any filtering here:
% [no fiter currently]

% Interpolate: 
xtmpi = interp2(x,y,xtmp,xi,yi,InterpMethod); 
ytmpi = interp2(x,y,ytmp,xi,yi,InterpMethod); 

% Transform back to "polar" coordinates: 
[thetai,Ai] = cart2pol(xtmpi,ytmpi); 
phi = thetai*365.25/(2*pi); 
phi(phi<0) = phi(phi<0)+365.25; % wraps phase  

end