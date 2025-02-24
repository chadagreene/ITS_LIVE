function itslive_mosaic_downloader(region, options)
% itslive_mosaic_downloader downloads ITS_LIVE v2 velocity mosaics. 
% 
%% Syntax 
% 
%  itslive_mosaic_downloader(region)
%  itslive_mosaic_downloader(..., year=years)
%  itslive_mosaic_downloader(..., path=targetPath)
% 
%% Description  
% 
% itslive_mosaic_downloader(region) downloads the summary mosaic for a
% specified region. The region must be a number in the range of 1 to 19, 
% where 1 is Alaska and 19 is Antarctica. For a map of regions, type
% itslive_regions. 
%
% itslive_mosaic_downloader(..., year=years) specifies the year(s) of data
% to download. If the year is not specified, the 0000 summary mosaic is
% downloaded. 
% 
% itslive_mosaic_downloader(..., path=targetPath) specifies a target
% directory for the data. If the path is not specified, the current working
% directory is used. 
% 
%% Examples 
% 
% % Download the summary mosaic for Greenland: 
% itslive_mosaic_downloader(5)
% 
% % Download the Greenland mosaics for the years 1985 to 1990: 
% itslive_mosaic_downloader(5, year=1985:1990) 
%
% % Download mosaics for Europe and Southern Andes and specify directory:
% itslive_mosaic_downloader([11 17], path='/Users/cgreene/Documents/data/ITS_LIVE') 
% 
%% Tip: 
% To explore what data are available, check out https://its-live-data.s3.amazonaws.com/index.html.  
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
% Written by Chad A. Greene, NASA/JPL, 2024. 

%% Input parsing 

arguments 
    region {mustBeMember(region,[1:12 14 17:19])}
    options.path {mustBeText} = pwd
    options.year {mustBeMember(options.year,[0000 1985:2022])} = 0000
end

%%

N_mosaics = numel(options.year) * numel(region); % total number of mosaics to download. 
k = 0; % counter 

w = waitbar(k,'Downloading '); 

for rk = 1:numel(region) 
    for yk = 1:numel(options.year)

        url = ['https://its-live-data.s3-us-west-2.amazonaws.com/velocity_mosaic/v2/annual/ITS_LIVE_velocity_120m_RGI',num2str(region(rk),'%02.f'),'A_',num2str(options.year(yk),'%04.f'),'_v02.nc'];
        waitbar((k)/N_mosaics,w,['Downloading data from the ',num2str(options.year(yk),'%04.f'),' region ',num2str(region(rk),'%02.f'),' mosaic.'])
        download(url,options.path)
        k = k + 1; % increment waitbar counter 
      
    end
end

waitbar(1,w,'Download complete.') 
pause(0.1) 
close(w) 
end


function download(url,directory)
% download uses websave to download a file from the internet. 
% 
%% Syntax 
% 
%  download(url)
%  download(url,directory)
%
%% Description 
% 
% download(url) downloads a file at the specified url to the current
% directory. The url can be a single string url, or a cell array of
% multiple urls. 
%
% download(url,directory) specifies a target directory on your local
% machine. If the directory is not declared, the current directory is
% used. 
% 
%% Example 
% 
% download('https://climate.northwestknowledge.net/TERRACLIMATE-DATA/TerraClimate_q_2000.nc','/Users/cgreene/Documents/data/climatology/TerraClimate')
% 
%% Author Info 
% Written by Chad A. Greene, NASA/JPL. 

if nargin<2
   directory = pwd; 
end

% If it's just a string (only one file to download) put it in a cell array: 
if ischar(url)
   url = {url}; 
end

for k = 1:length(url) 
   [~, url_name, url_ext] = fileparts(url{k}); 
   websave(fullfile(directory, [url_name,url_ext]), url{k}); 
end
end
