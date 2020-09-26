function [vi,v_std] = itslive_interannual(t,v,v_err,varargin)
% itslive_interannual computes the interannual component of velocity variability
% for an itslive time series. 
% 
%% Syntax 
% 
%  vi = itslive_interannual(t,v,err)
%  vi = itslive_interannual(...,'ti',ti)
%  [vi,v_std] = itslive_interannual(...)
% 
%% Description 
% 
% vi = itslive_interannual(t,v,v_err) gives the interannual component of variability
% in v, by assigning the weighted average of velocities for each calendar year to a 
% June 21st posting, then interpolating via pchip to the input times of t. Input times
% t can be Mx1 to represent the mean times of each input pair, or Mx2 for the times
% of each image a la [t1 t2]. Times t must be datenum or datetime format. Weighting
% follows w=1./v_err.^2; 
% 
% vi = itslive_interannual(...,'ti',ti) uses times ti as the posting dates to 
% interpolate to. If dates aren't specified ti = mean times of t. 
% 
% [vi,v_std] = itslive_interannual(...) also provides the unweighted standard
% deviation of interannual variability. 
%
%% Example 
% 
% load byrd_test_data 
% itslive_tsplot(t,v,v_err,'datenum','thresh',50); 
% 
% tm = mean(t,2); % mean times
% vm = itslive_interannual(t,v,v_err); 
% plot(tm,vm,'ro') 
% 
%% Author Info 
% Chad A. Greene wrote this, October 2019. 
% 

%% Error checks: 

narginchk(3,5)
assert(size(t,2)==2,'Error: times t must be Nx2 to specify start and end times for acquisition pairs.')
assert(isequal(size(t,1),size(v,1),size(v_err,1)),'Error: Dimensions of v must correspond to the times t.') 

%% Parse inputs:

user_ti = false;  % by default, use mean image times as posting dates to solve for. 

if nargin>2
   
   tmp = strcmpi(varargin,'ti'); 
   if any(tmp)
      user_ti = true; 
      ti = datenum(varargin{find(tmp)+1}); 
   end
   
end

%% Do mathematics: 

w = 1./v_err.^2; % weights 

% Get center dates: 
tm = mean(datenum(double(t)),2); % This allows input t to be Nx1 or Nx2.
if ~user_ti
   ti = tm; 
end

% Delete NaN data: 
isf = isfinite(v) & isfinite(v_err); 
tm = tm(isf); 
w = w(isf); 
v = v(isf); 

[start_year,~,~] = datevec(min(tm)-182.62); % 182.62 is 365.25/2
[end_year,~,~] = datevec(max(tm)+182.62); 

% Annual postings on June 21 (solstice) for the whole timespan: 
t_yearly = datenum(start_year:end_year,6,21); 
v_yearly = NaN(size(t_yearly)); 

for k = 1:length(t_yearly)
   ind = tm>=(t_yearly(k)-182.62) & tm<=(t_yearly(k)+182.62); 
   if any(ind)
       v_yearly(k) = sum(w(ind).*v(ind))./sum(w(ind)); % weighted mean
       t_yearly(k) = sum(w(ind).*tm(ind))./sum(w(ind)); % rewrites date as the weighted mean date
   end
end

isf = isfinite(v_yearly); 

try
   vi = interp1(t_yearly(isf),v_yearly(isf),ti,'pchip'); % extrapolates by default for pchip
catch 
   vi = NaN(size(ti)); 
end

if nargout>1
   v_std = std(v_yearly(isf)); 
end

end
