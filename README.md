[![View ITS\_LIVE Antarctic ice velocity data on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/72701-ITS\_LIVE-antarctic-ice-velocity-data)

![](ITS\_LIVE_v2_mosaic_regions.jpeg)

The MATLAB functions in this repository are designed to make it easy and efficient to work with [ITS\_LIVE](https://its-live.jpl.nasa.gov/) version 2 annual and climatology velocity mosaic data. 

# Data access/download

Get ITS\_LIVE v2 velocity mosaics in any of these ways: 

* Explore and download velocity mosaics in NetCDF or Cloud Optimized GeoTiff (COG) format through the [NSIDC ITS\_LIVE app](https://nsidc.org/apps/itslive), 
* Download the annual and climatology mosaics [directly from from AWS](https://its-live-data.s3.amazonaws.com/index.html#velocity_mosaic/), or 
* If you know which region and years of mosaics you want, use the [`itslive_mosaic_downloader`](documentation/itslive_mosaic_downloader_documentation.md) function included in this repo.  

After downloading the data, put the NetCDF(s) somewhere MATLAB can find them. I personally have a folder called `data`, and I have a [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) file in my home directory that contains this line:

`addpath(genpath('/Users/cgreene/Documents/data'))` 

which automatically adds the path to the `data` folder and all of its subfolders every time I start MATLAB. 

# Video Tutorial

[![How to analyze trends in sea surface temperature using CDT](https://img.youtube.com/vi/kRPNxrGfYrA/0.jpg)](https://www.youtube.com/watch?v=kRPNxrGfYrA "ITS_LIVE - MATLAB Tutorial")

# Functions 

**[`itslive_mosaic_downloader`](documentation/itslive_mosaic_downloader_documentation.md)** downloads all of the annual mosaics for a given region. 

**[`itslive_regions`](documentation/itslive_regions_documentation.md)** displays ITS\_LIVE regions that follow [Randolph Glacier Inventory v6](https://nsidc.org/data/nsidc-0770/versions/6) conventions.

**[`itslive2geo`](documentation/itslive2geo_documentation.md)** transforms projected map coordinates to geographic coordinates[^1].

**[`geo2itslive`](documentation/geo2itslive_documentation.md)** transforms geographic coordinates to ITS\_LIVE velocity mosaic map projected coordinates[^1].

**[`itslive_data`](documentation/itslive_data_documentation.md)** loads ITS\_LIVE velocity mosaic data.

**[`itslive_interp`](documentation/itslive_interp_documentation.md)** interpolates ITS\_LIVE velocity mosaic data to specified locations. 

**[`itslive_imagesc`](documentation/itslive_imagesc_documentation.md)** plots ITS\_LIVE mosaic data as an `imagesc` plot.

**[`itslive_quiver`](documentation/itslive_quiver_documentation.md)** plots ITS\_LIVE velocity data as quiver arrows. 

**[`itslive_flowline`](documentation/itslive_flowline_documentation.md)** calculates flowlines from ITS\_LIVE velocity mosaics. 

**[`itslive_timeseries`](documentation/itslive_timeseries_documentation.md)** creates continuous velocity time series at a single location by combining annual mosaic velocities with seasonal climatology. 

[^1]:Requires MATLAB's Mapping Toolbox

# Updates to the MATLAB functions (November 2024)
This repository and the functions in it were initially developed in 2019 for the release of ITS\_LIVE version 1. The mosaics in ITS\_LIVE version 2 have been revamped, variable names changed, file naming conventions changed, and most of the old functions required significant changes to work with the new mosaics. Accordingly, the version 2.0 updates to this repo in November 2024 contain many breaking changes from previous versions. 

# Data Description

Most of what you could possibly want to know about ITS\_LIVE v2 can be found in the [Gardner et al.](https://doi.org/10.5194/egusphere-2025-392) manuscript currently in open review for _The Cryosphere_. Happy reading!  

# Citing this dataset 
The ITS\_LIVE data and these functions are free for all to use. We just ask that you cite the following: 

Gardner, A. S., Greene, C. A., Kennedy, J. H., Fahnestock, M. A., Liukis, M., López, L. A., Lei, Y., Scambos, T. A., and Dehecq, A.: ITS_LIVE global glacier velocity data in near real time, EGUsphere [preprint], [https://doi.org/10.5194/egusphere-2025-392](https://doi.org/10.5194/egusphere-2025-392), 2025. 

Gardner, A. S., M. A. Fahnestock, and T. A. Scambos, 2019 [update to time of data download]: ITS\_LIVE Regional Glacier and Ice Sheet Surface Velocities. Data archived at National Snow and Ice Data Center; doi:10.5067/6II6VW8LLWJ7.
