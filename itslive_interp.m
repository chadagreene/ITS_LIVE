function zi = itslive_interp(variable,lati_or_xi,loni_or_yi,varargin)
% interpolates ITS_LIVE velocity data to specified points. 
% 
%% Syntax
% 
%  zi = itslive_interp(variable,lati,loni)
%  zi = itslive_interp(variable,xi,yi)
%  zi = itslive_interp(...,'path',filepath) 
%  zi = itslive_interp(...,'region',region)
%  zi = itslive_interp(...,'method',InterpMethod) 
%  zi = itslive_interp(...,'year',years) 
% 
%% Description 
% 
% zi = itslive_interp(variable,lati,loni) interpolates the specified ITS_LIVE
% variable to the geo coordinate(s) lati,loni. The variable can be 'v', 'vx',
% 'vy', 'vx_err', 'vy_err', 'v_err', 'date', 'dt', 'count', 'chip_size_max', 
% 'ocean', 'rock', or 'ice'.
% 
% zi = itslive_interp(variable,xi,yi) interpolates to the polar stereographic 
% coordinates xi,yi in meters. 
% 
% zi = itslive_interp(...,'path',filepath) specifies a filepath to the mosaic data. 
% 
% zi = itslive_interp(...,'region',region) specifies a region as ALA, ANT, 
% CAN, GRE, HMA, ICE, PAT, or SRA. So far I know the ANT option works, but 
% all other regions are currently in beta, so let me know if you experience 
% any problems. ANT is the default region. 
% 
% zi = itslive_interp(...,'method',InterpMethod) specifies an interpolation 
% method. Interpolation is linear by default, except for variables 'ocean', 
% 'rock', or 'ice', which are nearest neighbor. 
% 
% zi = itslive_interp(...,'year',years) specifies years of velocity mosaics.
% 
% v_across = itslive_interp('across',lati_or_xi,loni_or_yi,...) calculates the 
% across-track velocity for a path such as a grounding line lati,loni or xi,yi. 
% This is designed for calculating the flow across a flux gate. 
% 
% v_along = itslive_interp('along',lati_or_xi,loni_or_yi,...) the complement 
% to the across track component.  
% 
%% Example 1 
% Byrd glacier grounding line:
% 
% year = 2000:2018; 
% v = itslive_interp('v',-80.38,158.75,'years',year); 
% v_err = itslive_interp('v_err',-80.38,158.75,'years',year); 
% errorbar(year,v,v_err) 
% 
%% Example 2
% Get velocity data for a grid of points surrounding Totten, 150 km wide 
% by 200 km tall at 0.1 km resolution: 
% 
% [lat,lon] = psgrid('totten glacier',[150 200],0.1); 
% v = itslive_interp('v',lat,lon); 
% 
% pcolorps(lat,lon,v) % an AMT function for pcolor in polar stereographic. 
% 
%% Example 3
% Same grid as above, but specify a year and a filepath: 
% 
% v_err = itslive_interp('v_err',lat,lon,'path','/Users/cgreene/Documents/MATLAB/data','year',2018); 
%
% pcolorps(lat,lon,v_err) % an AMT function for pcolor in polar stereographic. 
% 
%% Example 4
% Calculate total flux in/out of a basin: 
% 
% % Load a basin outline: 
% [lati,loni] = basin_data('imbie refined','pine island'); 
% 
% % Densify to 100 m spacing: (use only finite values)
% isf = isfinite(lati); 
% [lati,loni] = pspath(lati(isf),loni(isf),100); 
% 
% % Calculate ice velocity across the basin boundary: 
% vci = itslive_interp('across',lati,loni);
% 
% % Get corresponding ice thickness: 
% thi = bedmachine_interp('thickness',lati,loni,'antarctica');
% 
% % Calculate (crosstrack velocity)*(thickness) at each point: 
% Ui = vci.*thi; 
% 
% Calculate total volume imbalance (requires multiplying by dx which is about 100m in this example) 
% d = pathdistps(lati,loni); % distance along the path in meters
% dx = gradient(d); % dx is 100 m in our example, but this general solution is better. 
% Vol = sum(Ui.*dx,'omitnan'); 
% 
% % Convert Volume to mass (multiply by 917 kg/m^3, then 1e-12 to get to Gt) 
% Mass = Vol*917*1e-12
%        -128.56
% 
% Plot everything: 
% 
% figure
% subsubplot(3,1,1) 
% anomaly(d/1000,vci) 
% axis tight
% ylabel 'velocity across (m/yr)'
% 
% subsubplot(3,1,2) 
% plot(d/1000,thi) 
% axis tight
% set(gca,'YAxisLocation','right') 
% ylabel 'ice thickness (m)' 
% 
% subsubplot(3,1,3) 
% anomaly(d/1000,Ui)
% axis tight
% ylabel 'local flow m^2/yr' 
% xlabel 'distance around basin boundary (km)' 
% 
% % Another way of looking at it: 
% figure
% scatterps(lati,loni,30,Ui,'filled') 
% cmocean('-balance','pivot') 
% modismoaps('contrast','low') 
% cb = colorbar
% ylabel(cb,'ice flux m^2/yr')
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
% See also itslive_data. 

narginchk(3,Inf) 
assert(~isnumeric(variable),'Error: First input must be a variable name.') 
assert(isequal(size(lati_or_xi),size(loni_or_yi)),'Error: Input query points must have matching dimensions.') 

%% Parse Inputs 

tmp = strncmpi(varargin,'region',3); 
if any(tmp)
   region = varargin{find(tmp)+1}; 
else 
   region = 'ANT'; 
end

tmp = strncmpi(varargin,'years',4); 
if any(tmp)
   years = varargin{find(tmp)+1}; 
   annual = true; 
else 
   annual = false; 
end

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

tmp = strncmpi(varargin,'method',4); 
if any(tmp)
   InterpMethod = varargin{find(tmp)+1}; 
else
   if ismember(lower(variable),{'rock','ice','ocean'})
      InterpMethod = 'nearest'; 
   else
      InterpMethod = 'linear'; 
   end
end

tmp = strncmpi(varargin,'years',4); 
if any(tmp)
   years = varargin{find(tmp)+1}; 
   annual = true; 
else 
   annual = false; 
end

tmp = strcmpi(varargin,'path'); 
if any(tmp)
   filepath = varargin{find(tmp)+1}; 
else
   filepath = []; 
end

if ismember(lower(variable),{'along','across'})
   CrossTrack = true; 
   assert(strcmpi(region,'ANT'),'Along or across track velocities are only supported for Antarctica.')
else
   CrossTrack = false; 
end

%% Load data: 

if CrossTrack
   
   if annual
      [vx,x,y] = itslive_data('vx',xi,yi,'buffer',1,'years',years,'path',filepath,'region',region); 
      vy = itslive_data('vy',xi,yi,'buffer',1,'years',years,'path',filepath,'region',region); 
   else
      [vx,x,y] = itslive_data('vx',xi,yi,'buffer',1,'path',filepath,'region',region); 
      vy = itslive_data('vy',xi,yi,'buffer',1,'path',filepath,'region',region);
   end
   
else 
   if annual
      [Z,x,y] = itslive_data(variable,xi,yi,'buffer',1,'years',years,'path',filepath,'region',region); 
   else
      [Z,x,y] = itslive_data(variable,xi,yi,'buffer',1,'path',filepath,'region',region); 
   end
end

%% Interpolate: 

if CrossTrack
   
   % Preallocate: 
   vxi = NaN(size(xi,1),size(xi,2),size(vx,3)); 
   vyi = vxi; 

   % Interpolate: 
   for k = 1:size(vx,3)
      vxi(:,:,k) = interp2(x,y,vx(:,:,k),xi,yi,InterpMethod); 
      vyi(:,:,k) = interp2(x,y,vy(:,:,k),xi,yi,InterpMethod); 
   end
   
else
   
   if islogical(Z)
      
      % Preallocate:
      zi = false(size(xi,1),size(xi,2),size(Z,3)); 

      for k=1:size(Z,3)
         zi(:,:,k) = interp2(x,y,Z(:,:,k),xi,yi,'nearest',0); 
      end
   else
      
      % Preallocate:
      zi = NaN(size(xi,1),size(xi,2),size(Z,3)); 

      % Interpolate: 
      for k = 1:size(Z,3)
         zi(:,:,k) = interp2(x,y,Z(:,:,k),xi,yi,InterpMethod); 
      end
   end
end


%% Convert to along/across track components:

if CrossTrack
   
   % Calculate along-track angles
   alongtrackdist = pathdistps(xi,yi); % cumulative distance along path in meters
   fx = gradient(xi,alongtrackdist); 
   fy = gradient(yi,alongtrackdist);
   theta = atan2(fy,fx);          

   % Convert x and y components to cross-track component: 
   v_along = vxi.*cos(theta) + vyi.*sin(theta);       
   v_across = vxi.*sin(theta) - vyi.*cos(theta); 

   switch lower(variable)
      case 'along'
         zi = squeeze(v_along); 
      case 'across'
         zi = squeeze(v_across);
      otherwise
         error(['unrecognized variable ',variable])
   end

end

%% 

if isequal([size(zi,1) size(zi,1)],[1 1])
   zi = squeeze(zi); 
end

end