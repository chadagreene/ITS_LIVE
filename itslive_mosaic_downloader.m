 

% This script downloads its_live velocity mosaics. Just select your region 
% of interest and let it run. 
% Written by Chad Greene of NASA Jet Propulsion Laboratory, October 2020. 

%% Set preferences: 

region = 'HMA'; % Can be GRE, ANT, HMA, PAT, ICE, SRA, CAN, or ALA.

yr = [0000 2018:-1:1985]; % Download the overall mosaic first, then each year starting with most recent. 

%% Download:
% Depending on the region and the speed of your internet connection, this might 
% take a while. For example, each mosaic for the HMA region is a few hundred MB, 
% so with my mediocre home internet connection it takes about 30 minutes to 
% download all 30+ years of data. 

% Loop through each year: 
w = waitbar(0,'Downloading '); 
for k = 1:length(yr)
   
   % Define filename: 
   if k==1
      fn = [region,'_G0240_0000.nc'];
      url = ['http://its-live-data.jpl.nasa.gov.s3.amazonaws.com/velocity_mosaic/landsat/v00.0/static/',fn];      
   else
      fn = [region,'_G0240_',num2str(yr(k)),'.nc'];
      url = ['http://its-live-data.jpl.nasa.gov.s3.amazonaws.com/velocity_mosaic/landsat/v00.0/annual/',fn];
   end
   
   waitbar((k-1)/length(yr),w,{['Downloading data from the ',num2str(yr(k)),' mosaic.'];'Going backward through time...'})
   websave(fn,url);
   if k==10
      break
   end
end

waitbar(1,w,'Done') 
pause(0.1) 
close(w) 
