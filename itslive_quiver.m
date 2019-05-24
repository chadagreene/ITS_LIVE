function h = itslive_quiver(varargin)
% itslive_quiver plots ice velocity arrows on a polar stereographic map. 
% 
%% Syntax
% 
%  itslive_quiver
%  itslive_quiver('colorspec')
%  itslive_quiver(...Name,Value) 
%  itslive_quiver(...,'density','DensityFactor') 
%  h = itslive_quiver(...) 
% 
%% Description 
%  
% itslive_quiver plots a quiver plot on the current map. 
% 
% itslive_quiver('colorspec') specifies a color of the vectors, like 'r'
% for red. 
%
% itslive_quiver(...Name,Value) formats the quiver arrows with any quiver
% properties. 
% 
% itslive_quiver(...,'density','DensityFactor') specifies the density of 
% the arrows. Default DensityFactor is 50, meaning hypot(Nrows,Ncols)=50, 
% but if your plot is too crowded you may specify a lower DensityFactor 
% (and/or adjust the markersize). 
% 
% h = itslive_quiver(...) returns a handle h of the plotted quiver object.
% 
%% Examples
% 
% mapzoomps('pine island glacier') 
% itslive_quiver
% 
% or 
% mapzoomps('pine island glacier') 
% itslive_quiver('r','density',100)
% 
%% Author Info
% Chad A. Greene wrote this in May 2019. 
%
% See also: itslive_imagesc and itslive_data. 


%% Check the presence of a current axes: 

ax = axis; 
if isequal(ax,[0 1 0 1]) 
   NewMap = true; 
else 
   NewMap = false; 
end

%% Load data: 

if NewMap
   answer = questdlg('The itslive_quiver function works best if you are already zoomed to the extents of interest, however you do not have a map open or zoomed. Loading the entire continent will be slow and the plot won''t be pretty. Continue anyway?',...
      'Performance Warning',...
      'Go for it anyway','Cancel','Cancel'); 
   if strcmp(answer,'Cancel')
      return
   end

   [vx,x,y] = itslive_data('vx','xy'); 
   vy = itslive_data('vy','xy'); 
else
   [vx,x,y] = itslive_data('vx',ax(1:2),ax(3:4),'buffer',10,'xy'); % A little bit of buffer to make the resizing nice. 
   vy = itslive_data('vy',ax(1:2),ax(3:4),'buffer',10,'xy'); 
end 

%% Plot things: 

hold on
h = quiversc(x,y,vx,vy,varargin{:}); 

axis xy
daspect([1 1 1]) 

%% Clean up: 

if nargout==0 
   clear h
end

end

function h = quiversc(x,y,u,v,varargin)
% quiversc scales a dense grid of quiver arrows to comfortably fit in axes
% before plotting them.
% 
%% Syntax
% 
%  quiversc(x,y,u,v)
%  quiversc(...,'density',DensityValue)
%  quiversc(...,scale)
%  quiversc(...,LineSpec)
%  quiversc(...,LineSpec,'filled')
%  quiversc(...,'Name',Value)
%  h = quiversc(...)
% 
%% Description 
% 
% quiversc(x,y,u,v) plots vectors as arrows at the coordinates specified in 
% each corresponding pair of elements in x and y. The matrices x, y, u, and 
% v must all be the same size and contain corresponding position and velocity
% components. By default, the arrows are scaled to just not overlap, but you 
% can scale them to be longer or shorter if you want.
% 
% quiversc(...,'density',DensityFactor) specifies density of quiver arrows. The 
% DensityFactor defines how many arrows are plotted. Default DensityFactor is 
% 50, meaning hypot(Nrows,Ncols)=50, but if your plot is too crowded you may 
% specify a lower DensityFactor (and/or adjust the markersize). 
% 
% quiversc(...,scale) automatically scales the length of the arrows to fit within 
% the grid and then stretches them by the factor scale. scale = 2 doubles their 
% relative length, and scale = 0.5 halves the length. Use scale = 0 to plot the 
% velocity vectors without automatic scaling. You can also tune the length of 
% arrows after they have been drawn by choosing the Plot Edit tool, selecting 
% the quiver object, opening the Property Editor, and adjusting the Length slider.
% 
% quiversc(...,LineSpec) specifies line style, marker symbol, and color using 
% any valid LineSpec. quiversc draws the markers at the origin of the vectors.
% 
% quiversc(...,LineSpec,'filled') fills markers specified by LineSpec.
% 
% quiversc(...,'Name',Value) specifies property name and property value pairs
% for the quiver objects the function creates.
% 
% h = quiversc(...) returns the quiver object handle h. 
% 
%% Examples 
% For examples, type 
% 
%  cdt quiversc 
% 
%% Author Info
% This function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
% 
% See also: quiver

%% Input parsing: 

% Turn vectors into grids: 
if all([isvector(x) isvector(y)])
   [x,y] = meshgrid(x,y); 
end

% Ensure all the dimensions match: 
assert(isequal(size(x),size(y),size(u),size(v))==1,'Error: Dimensions of x, y, u, and v must all agree. Check inputs, or use [x,y] = meshgrid(x,y) if necessary.')

% Check for user-defined density: 
tmp = strncmpi(varargin,'density',3); 
if any(tmp)
   density = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1)=1; 
   varargin = varargin(~tmp); 
   assert(isscalar(density)==1,'Input error: Density value must be a scalar. Default density is 100.') 
else 
   density = 50; 
end

%% Resize the grids: 

% Density is 50 by default, meaning hypot(Nrows,Ncols) will be 50. 
InputDensity = hypot(size(x,1),size(x,2)); 

sc = density/InputDensity; % scaling factor to convert InputDensity to desired density.

if ~isnan(sc)

   % First, scale by nearest-neighbor:
   xn = imresize(x,sc,'nearest');
   yn = imresize(y,sc,'nearest');
   un = imresize(u,sc,'nearest');
   vn = imresize(v,sc,'nearest');

   % For most of the grid we'll use default bicubic though: 
   x = imresize(x,sc);
   y = imresize(y,sc); 
   u = imresize(u,sc); 
   v = imresize(v,sc); 

   % But fill in NaNs with nearest-neighbor results b/c otherwise coastal areas would be decimated: 
   x(isnan(x)) = xn(isnan(x)); 
   y(isnan(y)) = yn(isnan(y)); 
   u(isnan(u)) = un(isnan(u)); 
   v(isnan(v)) = vn(isnan(v)); 
end

if true
   % Remove every other grid cell in a checkerboard fashion: 
   % This functionality is turned off, but could easily be added as an
   % option in a future release. 
   % ACTUALLY I TURNED IT ON FOR ITSLIVE_QUIVER.
   checker = true(size(x)); 
   checker(1:2:end,1:2:end) = false; 
   checker(2:2:end,2:2:end) = false; 
   x(checker) = NaN; 
   y(checker) = NaN; 
   u(checker) = NaN; 
   v(checker) = NaN; 
end

%% Plot

h = quiver(x,y,u,v,varargin{:}); 

%% Clean up: 

if nargout==0
   clear h
end

end