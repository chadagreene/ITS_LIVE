function [v,v_error] = itslive_timeseries(region,lati_or_xi,loni_or_yi,ti)
% itslive_timeseries builds a velocity time series including interannual
% and seasonal variability for a single location. 
% 
%% Syntax
% 
%  v = itslive_timeseries(region,lati,loni,ti)
%  v = itslive_timeseries(region,xi,yi,ti)
%  [v,v_error] = itslive_timeseries(...) 
% 
%% Description 
% 
% v = itslive_timeseries(region,lati,loni,ti) creates a velocity timeseries
% v for the location lati,loni at times ti in datenum or datetime format.
%
% v = itslive_timeseries(region,xi,yi,ti) as above, but for coordinates
% xi,yi in meters corresponding to the projection of the ITS_LIVE region.
% 
% [v,v_error] = itslive_timeseries(...) also estimates error as the root
% sum square of v_error from the annual mosaics and v_amp_error from the
% summary mosaic. 
% 
%% Example
% Consider this location: https://mappin.itsliveiceflow.science/?lat=34.3963&lon=85.9067&z=12&int=1&int=72&x=2012-07-15&x=2025-07-09&y=-70&y=992
% 
%  region = 14; 
%  lat = 34.3963; 
%  lon = 85.9067; 
%  t = datenum('jan 1, 2014'):datenum('dec 31, 2022'); 
% 
%  [v,v_error] = itslive_timeseries(region,lat,lon,t); 
% 
%  figure
%  boundedline(t,v,v_error) % from Climate Data Toolbox
%  datetick('x')
% 
%  % Add Level 2 data for context: 
%  T = readtable('lat_34.3963_lon_85.9067 2.csv','TextType','string'); 
% 
%  % Convert time string to datenum: 
%  for k = 1:height(T)
%      T.t(k) = datenum(T.mid_date{k}(1:10)); 
%  end
% 
%  hold on
%  h = scatter3(T.t,T.v_m_yr_,-T.dt_days_,10,T.dt_days_,'filled'); 
%  cmocean -amp % optional colormap 
%  axis tight
%  ylabel 'Velocity (m yr^{-1})'
%  cb = colorbar('north'); 
%  cb.Position(3:4) = cb.Position(3:4)/2; 
%  xlabel(cb,'dt (days)')
% 
%% More Examples
% 
% For more examples, see the documentation at:
% https://github.com/chadagreene/ITS_LIVE.
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
% Chad A. Greene wrote this in May of 2019, rewritten Nov 2024 for
% the release of ITS_LIVE version 2. 
%
% See also itslive_interp and itslive_data. 

%% Input checks 

narginchk(4,4)
assert(isscalar(region),'Error: Input region must be a scalar.')
assert(isscalar(lati_or_xi) & isscalar(loni_or_yi),'Error: Geographic coordinates must be scalars that define a single location.')

% Convert to datenum in case inputs are datetime:
ti = datenum(ti); 

%% Do fun stuff:  

% Get the full range of years so we know which annual mosaics to load: 
[yr,~,~] = datevec(ti); 
yr_annual = min(yr):max(yr); 

% Load mosaic data: 
v_annual = itslive_interp(region,'v',lati_or_xi,loni_or_yi, year=yr_annual, method='nearest'); 
v_amp = itslive_interp(region,'v_amp',lati_or_xi,loni_or_yi, method='nearest'); 
v_phase = itslive_interp(region,'v_phase',lati_or_xi,loni_or_yi, method='nearest'); 

% Interpolate annual to specified times: 
v = interp1(datenum(yr_annual+.5,0,0),v_annual,ti,'makima') + sineval([v_amp v_phase], ti); 

% Get error metrics if requested: 
if nargout>1
    v_annual_error = itslive_interp(region,'v_error',lati_or_xi,loni_or_yi, year=yr_annual, method='nearest'); 
    v_amp_error = itslive_interp(region,'v_amp_error',lati_or_xi,loni_or_yi, method='nearest'); 
    v_error = hypot(interp1(datenum(yr_annual+.5,0,0),v_annual_error,ti,'makima'), v_amp_error); 
end

end


function y = sineval(ft,t) 
% sineval produces a sinusoid of specified amplitude and phase with
% a frequency of 1/yr. 
% 
%% Syntax
% 
%  y = sineval(ft,t)
% 
%% Description 
% 
% y = sineval(ft,t) evaluates a sinusoid of given fit parameters ft 
% at times t. Times t can be in datenum, datetime, or datestr format, 
% and parameters ft correspond to the outputs of the sinefit function
% and can have 2 to 5 elements, which describe the following: 
% 
%   2: ft = [A doy_max] where A is the amplitude of the sinusoid, and doy_max 
%      is the day of year corresponding to the maximum value of the sinusoid. 
%      The default TermOption is 2.
%   3: ft = [A doy_max C] also estimates C, a constant offset.
%   4: ft = [A doy_max C trend] also estimates a linear trend over the entire
%      time series in units of y per year.
%   5: ft = [A doy_max C trend quadratic_term] also includes a quadratic term
%      in the solution, but this is experimental for now, because fitting a 
%      polynomial to dates referenced to year zero tends to be scaled poorly.
% 
%% Examples
% For examples, type: 
% 
%  cdt sineval
% 
%% Author Info
% Written by Chad A. Greene
% 
% See also sinefit and polyval. 

%% Error checks: 

narginchk(2,2) 
assert(numel(ft)>=2,'Error: Input parameters ft must contain at least an amplitude and a phase term.') 

%% Allow for 3d field: 

nterms = 2; % the default 

switch ndims(ft) 
   case {1,2} 
      A = ft(:,1); 
      ph = ft(:,2); 
      if size(ft,2)>2
         C = ft(:,3); 
         nterms = 3; 
         if size(ft,2)>3
            tr = ft(:,4); 
            nterms = 4; 
            if size(ft,2)>4
               quad_term = ft(:,5); 
               nterms = 5; 
            end 
         end
      end
      
   case 3 % this is essentially map view 
      A = ft(:,:,1); 
      ph = ft(:,:,2); 
      if size(ft,3)>2
         C = ft(:,:,3); 
         nterms = 3; 
         if size(ft,3)>3
            tr = ft(:,:,4); 
            nterms = 4; 
            if size(ft,3)>4
               quad_term = ft(:,:,5); 
               nterms = 5; 
            end 
         end
      end
      
   otherwise 
      error('Invalid format of ft.') 
end 
      
%% Evaluate sinusoid: 

% normalize phase: 
ph = 0.25 - ph/365.25; 

% Convert times to fraction of year: 
yr = doy(t,'decimalyear'); 

switch nterms
   case 2
       y = A.*sin((yr + ph)*2*pi); 
   case 3 
       y = A.*sin((yr + ph)*2*pi) + C; 
   case 4
       y = A.*sin((yr + ph)*2*pi) + C + tr.*yr; 
   case 5
       y = A.*sin((yr + ph)*2*pi) + C + tr.*yr + quad_term.*yr.^2; 
   otherwise 
      error('Unrecognized sinusoidal fit model.') 
end


end

