# ITS_LIVE functions for MATLAB 
These MATLAB functions are intended to make it easy and efficient to work with [ITS_LIVE](https://its-live.jpl.nasa.gov/) velocity data. Right now these functions only support the Antarctic region, but if you'd like them for other regions just let me know. 

## Requirements 
Since these functions are currently just for the Antarctic, they rely on [Antarctic Mapping Tools for Matlab](http://www.mathworks.com/matlabcentral/fileexchange/47638), so you'll need to get that package if you don't already have it. 

## Downloading data
If you don't already have the velocity data, download the NetCDF version of the velocity data for your years of interest [here](https://staging.itslive.apps.nsidc.org). If you only want the mosaic, I recommend the 240 m composite, which provides the error-weighted synthesis of all available data. 

After downloading the data, put the NetCDF(s) somewhere Matlab can find them. I personally have a folder called `data`, and I have a [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) file in my home directory that contains this line:

`addpath(genpath('/Users/cgreene/Documents/MATLAB/data'))` 

which automatically adds the path to the `data` folder and all of it subfolders every time I start Matlab. 

