function [vf,x,y] = itslive_tilefun(variable,years,fun,varargin)
% itslive_tilefun applies a specified function to itslive velocity data. 
% This function exists to work around memory issues when dealing with large
% data cubes. 
% 
%% Syntax
% 
%  vf = itslive_tilefun(variable,years,fun)
%  vf = itslive_tilefun(...,functionOptions,...)
%  vf = itslive_tilefun(...,'tilesize',maxtilesize)
%  [vf,x,y] = itslive_tilefun(...)
% 
%% Description 
% 
% vf = itslive_tilefun(variable,years,fun) applies the function fun down the
% temporal dimensions of an itslive variable for a given number of years. 
% 
% vf = itslive_tilefun(...,functionOptions,...) allows any optional inputs 
% that are accepted by the specified function, such as 'omitnan'. 
% 
% vf = itslive_tilefun(...,'tilesize',maxtilesize) specifies a maximum tile
% size. By default, maxtilesize is 1000, meaning 1000x1000 grid cells per tile. 
% If you run into memory issues, which is quite possible if you're processing 
% a long time record, try reducing the tilesize (although doing so may increase
% the processing time). 
% 
% [vf,x,y] = itslive_tilefun(...) also returns the arrays of coordinates x,y
% corresponding to the grid. 
% 
%% Example 1
% Get the mean velocity from 2016 to 2018: 
% 
% vm = itslive_tilefun('v',2016:2018,@mean); 
% 
%% Example 2
% Get the mean velocity for 2016 to 2018, omitting NaN values, and specifying
% a maximum tilesize of 800x800: 
% 
% vm = itslive_tilefun('v',2016:2018,@mean,'tilesize',800);  
% 
%% Author Info 
% Written by Chad A. Greene, December 2019. 


%% Error checks:

narginchk(3,Inf)
assert(~isnumeric(variable),'Error: First input must be a string.') 
assert(isnumeric(years),'Error: Second input must be years.') 
assert(isa(fun,'function_handle'),'Error: Third input must be a function handle.') 
assert(exist('tile.m','file')==2,'Error: Cannot find the necessary function tile.m. It is part of the Climate Data Toolbox for Matlab, which you absolutely must have to use this function.') 

%% Parse inputs: 

% First, set default tilesize: 
tilesize = 1000; 

if nargin>3
   tmp = strncmpi(varargin,'tilesize',4); 
   if any(tmp)
      tilesize = varargin{find(tmp)+1}; 
      assert(numel(tilesize)<=2,'Error: tilesize must be a scalar or two element vector')
      tmp(find(tmp)+1) = true; 
      varargin = varargin(~tmp); 
   end
end

%% The main event: 

% Get the coordinates of the full grid: 
x = itslive_data('x'); 
y = itslive_data('y'); 

% Size of the full grid: 
siz = [length(y) length(x)]; 

% Get the coordinates of rows and columns for each tile: 
[row,col] = tile(siz,tilesize); % A function from Climate Data Toolbox (Greene et al., 2019)

% Preallocate output vf: 
vf = NaN(siz); 

% Loop through each tile: 
f = waitbar(0,'Processing '); 
for k = 1:numel(row)
   
   % Make the user feel good about all the progress that's happening: 
   waitbar(k/numel(row),f,['Processing tile ',num2str(k),' of ',num2str(numel(row))]); 
   
   % Load itslive data for the specified years and permute it into a rectangular matrix: 
   v_tmp = cube2rect(itslive_data(variable,x(col{k}),y(row{k}),'years',years)); % cube2rect is a function from Climate Data Toolbox (Greene et al., 2019)
   
   % Apply the specified function, permute it back into the correct shape, and store it in the correct rows and columns 
   vf(row{k},col{k}) = rect2cube(fun(v_tmp,varargin{:}),[numel(row{k}) numel(col{k})]); % cube2rect is a function from Climate Data Toolbox (Greene et al., 2019)
end
   
% Close the waitbar: 
waitbar(1,f,'Done!') 
pause(0.1)
close(f) 

end