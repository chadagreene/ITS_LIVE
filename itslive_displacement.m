function [lat1_or_x1,lon1_or_y1] = itslive_displacement(lat0_or_x0,lon0_or_y0,dt_years,varargin) 
% itslive_displacement estimates the horizontal location of a parcel of ice after a specified
% amount of time, based on ITS_LIVE surface velocities. It works by solving for
% displacements in annual increments to account for any curving path the ice might 
% take over a number of years. This function does not account for seasonal or 
% interannual changes in velocity, nor the vertical structure of ice velocity. 
% 
%% Syntax 
% 
%  [lat_end,lon_end] = itslive_displacement(lat_start,lon_start,dt) 
%  [x_end,y_end] = itslive_displacement(x_start,y_start,dt) 
%  
%% Description 
% 
% [lat_end,lon_end] = itslive_displacement(lat_start,lon_start,dt) gives the geographic locations of points given by 
% lat_start,lon_start after dt years.  The dt variable can be negative if you'd like to estimate where a parcel
% of ice was dt years ago.
% 
% [x_end,y_end] = itslive_displacement(x_start,y_start,dt) performs the same function described above, but returns
% values in polar stereographic meters if input coordinates are polar stereographic meters.  Coordinates are automatically 
% determined by the islatlon function. 
% 
%% Examples
% 
% Example 1: A grid after five years:
%
%    [lat0,lon0] = psgrid('pine island glacier',150,10); 
%    [lat5,lon5] = itslive_displacement(lat0,lon0,5); 
% 
% Example 2: A single parcel of ice at different times in its life: 
%
%    t = -16:4:16; % every four years from 16 yr ago to 16 yr from now.
%    [x_t,y_t] = itslive_displacement(-1587645,-257033,t); 
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
% Greene, C.A., Gwyther, D.E. and Blankenship, D.D. Antarctic Mapping Tools for Matlab. 
% Computers & Geosciences.  http://dx.doi.org/10.1016/j.cageo.2016.08.003
% 
%% Author Info
% This function was written by Chad A. Greene, July 2020. 
% 
% See also: itslive_flowline and itslive_interp. 

%% Error checks: 

narginchk(3,4)
nargoutchk(2,2) 
assert(isequal(size(lat0_or_x0),size(lon0_or_y0)),'Input error: Dimensions of input coordinates must agree.') 

if any(abs(dt_years(:))>1000)
   error('You are trying to solve for more than a millennium of ice displacement. I have a feeling you either entered days instead of years, or you''re seeking a solution which may be questionable.  A thousand years seems like too much.  I have not performed any sort of rigorous analysis to deem a thousand years too much, but it sure seems like errors in the velocity field would integrate, plus it would call the ITS_LIVE_interp function more than a thousand times, and that is computationally slow.  I recommend using the flowline function instead. Or, if you really want to, you can delete this error message and also change the years_of_simulation loop to a larger number. Good luck.')
end

if any(abs(dt_years(:))>365)
   warning('Just a heads up - you''re solving for more than 365 years of displacement. That''s fine, I''m working on a solution right now, but if you accidentally entered days instead of years, hit Ctrl+C to stop the solution, then retry with dt/365.') 
end
      
%% Parse inputs: 

if islatlon(lat0_or_x0,lon0_or_y0) 
   geo = true; % If geo is true, we'll convert back to geo at the end.  
   [x0,y0] = ll2ps(lat0_or_x0,lon0_or_y0); 
else
   geo = false; 
   x0 = lat0_or_x0; 
   y0 = lon0_or_y0; 
end

%% Perform mathematics: 

% Preallocate outputs by starting with initial condition: 
if isscalar(x0)
   x1 = x0*ones(size(dt_years)); 
   y1 = y0*ones(size(dt_years)); 
else
   x1 = x0; 
   y1 = y0; 
end

if isscalar(dt_years)
   tminus = dt_years*ones(size(x1)); 
else
   tminus = dt_years; 
end


for years_of_simulation = 1:1000
   
   if any(abs(tminus(:))>0)
   
      % How big of a time step will we do this time through the loop?
      t_step = tminus; % Use the remaining time. 

      % Limit steps to one year, and we'll lose the sign, but that's okay we'll account for it later: 
      t_step(abs(t_step)>1) = sign(t_step(abs(t_step)>1)); 
   
      % Get the local velocity at each point: 
      vx = itslive_interp('vx',x1,y1); 
      vy = itslive_interp('vy',x1,y1); 
         
      % Update coordinates as original coordinates plus 1 year's displacement (or less than 1 yr for any points with less than 1 year remaining in tminus) 
      x1 = x1 + vx.*t_step; 
      y1 = y1 + vy.*t_step; 
      
      % Update the amount of time remaining: 
      tminus = tminus-t_step; 
   
   else 
      break
   end
   
end

%% Clean up: 

if geo 
   [lat1_or_x1,lon1_or_y1] = ps2ll(x1,y1); 
else
   lat1_or_x1 = x1; 
   lon1_or_y1 = y1; 
end


end