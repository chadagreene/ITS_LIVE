[![View ITS_LIVE Antarctic ice velocity data on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/72701-its_live-antarctic-ice-velocity-data)

![](ITS_LIVE_v2_mosaic_regions.jpeg)

The MATLAB functions in this repository are designed to make it easy and efficient to work with [ITS_LIVE](https://its-live.jpl.nasa.gov/) version 2 velocity mosaic data. 

# Data access/download

Get the ITS_LIVE v2 velocity mosaics in any of these ways: 

* Explore and download velocity mosaics in NetCDF format through the [NSIDC ITS\_LIVE app](https://nsidc.org/apps/itslive), 
* Download the annual and static mosaics [directly from from AWS](https://its-live-data.s3.amazonaws.com/index.html#velocity_mosaic/v2/), or 
* If you know which region and years of mosaics you want, use the `itslive_mosaic_downloader` function included in this repo.  

After downloading the data, put the NetCDF(s) somewhere MATLAB can find them. I personally have a folder called `data`, and I have a [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) file in my home directory that contains this line:

`addpath(genpath('/Users/cgreene/Documents/data'))` 

which automatically adds the path to the `data` folder and all of its subfolders every time I start MATLAB. 

# Functions 

**`itslive_mosaic_downloader`** downloads all of the annual mosaics for any specified region. 

**`itslive_regions`** displays map above of ITS_LIVE regions, which approximately correspond to RGI regions. 

**[`itslive_data`](documentation/itslive_data_documentation.md)** loads ITS_LIVE velocity mosaic data.

**`itslive_interp`** interpolates ITS_LIVE velocity mosaic data to specified locations. 

**`itslive_imagesc`** plots itslive velocity magnitude (speed) data as an `imagesc` plot. If a map is already initialized, `itslive_imagesc` will only load and plot enough data to fill the current map. 

**`itslive_quiver`** is equivalent to `itslive_imagesc`, but plots ITS_LIVE velocity data as quiver arrows. 

**`itslive_flowline`** calculates flowlines from itslive velocity mosaics. 

**`itslive_displacement`** similar to `itslive_flowline`, but calculates the position of point(s) after a specified time interval. For example, where was a certain grid point 3.5 year ago? Enter its coordinates with a dt value of -3.5 to find out. 

**`itslive2geo`** transforms projected map coordinates to geographic coordinates. (Requires MATLAB's Mapping Toolbox)

**`geo2itslive`** transforms geographic coordinates to projected map coordinates corresponding to a given ITS_LIVE velocity mosaic region. (Requires MATLAB's Mapping Toolbox)

# Major Updates 
This repository and the functions in it were initially developed in 2019 for the release of ITS_LIVE version 1. However, the mosaics in ITS_LIVE version 2 were revamped, variable names changed, file naming conventions changed, and most of these functions required significant changes to work with the new mosaics. Accordingly, the version 2.0 updates to this repo in 2024 contain many breaking changes from previous versions. 

## Citing this dataset 
The ITS\_LIVE data and these functions are provided free of charge. All we ask is that you please cite the dataset, and if you're feeling extra generous please do me a kindness and cite my Antarctic Mapping Tools paper too. Wording might be something like, "Velocity data generated using auto-RIFT (Gardner et al., 2018) and provided by the NASA MEaSUREs ITS\_LIVE project (Gardner et al., 2019). Analysis was performed with Antarctic Mapping Tools for Matlab (Greene et al., 2017)"

Gardner, A. S., M. A. Fahnestock, and T. A. Scambos, 2019 [update to time of data download]: ITS\_LIVE Regional Glacier and Ice Sheet Surface Velocities. Data archived at National Snow and Ice Data Center; doi:10.5067/6II6VW8LLWJ7.

Gardner, A. S., G. Moholdt, T. Scambos, M. Fahnstock, S. Ligtenberg, M. van den Broeke, and J. Nilsson, 2018: Increased West Antarctic and unchanged East Antarctic ice discharge over the last 7 years, _Cryosphere,_ 12(2): 521–547, doi:10.5194/tc-12-521-2018.

Greene, C. A., D. E. Gwyther, and D. D. Blankenship, 2017 “Antarctic Mapping Tools for Matlab.” _Computers & Geosciences,_ (104) 151–157, doi:10.1016/j.cageo.2016.08.003.
