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

# Functions 

**[`itslive_mosaic_downloader`](documentation/itslive_mosaic_downloader_documentation.md)** downloads all of the annual mosaics for a given region. 

**[`itslive_regions`](documentation/itslive_regions_documentation.md)** displays a map of ITS\_LIVE regions, which approximately correspond to [Randolph Glacier Inventory v6](https://nsidc.org/data/nsidc-0770/versions/6) regions. 

**[`itslive2geo`](documentation/itslive2geo_documentation.md)** transforms projected map coordinates to geographic coordinates[^1].

**[`geo2itslive`](documentation/geo2itslive_documentation.md)** transforms geographic coordinates to projected map coordinates corresponding to a given ITS\_LIVE velocity mosaic region[^1].

**[`itslive_data`](documentation/itslive_data_documentation.md)** loads ITS\_LIVE velocity mosaic data.

**[`itslive_interp`](documentation/itslive_interp_documentation.md)** interpolates ITS\_LIVE velocity mosaic data to specified locations. 

**[`itslive_imagesc`](documentation/itslive_imagesc_documentation.md)** plots ITS\_LIVE mosaic data as an `imagesc` plot.

**[`itslive_quiver`](documentation/itslive_quiver_documentation.md)** plots ITS\_LIVE velocity data as quiver arrows. 

**[`itslive_flowline`](documentation/itslive_flowline_documentation.md)** calculates flowlines from ITS\_LIVE velocity mosaics. 

[^1]:Requires MATLAB's Mapping Toolbox

# Major Updates 
This repository and the functions in it were initially developed in 2019 for the release of ITS\_LIVE version 1. The mosaics in ITS\_LIVE version 2 have now been revamped, variable names changed, file naming conventions changed, and most of the old functions required significant changes to work with the new mosaics. Accordingly, the version 2.0 updates to this repo in November 2024 contain many breaking changes from previous versions. 

# Citing this dataset 
The ITS\_LIVE data and these functions are free for all to use. We do ask that you please cite the dataset, and if relevant cite my Antarctic Mapping Tools paper too. Wording might be something like, "Velocity data generated using auto-RIFT (Gardner et al., 2018) and provided by the NASA MEaSUREs ITS\_LIVE project (Gardner et al., 2019). Analysis was performed with Antarctic Mapping Tools for Matlab (Greene et al., 2017)"

Gardner, A. S., M. A. Fahnestock, and T. A. Scambos, 2019 [update to time of data download]: ITS\_LIVE Regional Glacier and Ice Sheet Surface Velocities. Data archived at National Snow and Ice Data Center; doi:10.5067/6II6VW8LLWJ7.

Gardner, A. S., G. Moholdt, T. Scambos, M. Fahnstock, S. Ligtenberg, M. van den Broeke, and J. Nilsson, 2018: Increased West Antarctic and unchanged East Antarctic ice discharge over the last 7 years, _Cryosphere,_ 12(2): 521–547, doi:10.5194/tc-12-521-2018.

Greene, C. A., D. E. Gwyther, and D. D. Blankenship, 2017 “Antarctic Mapping Tools for Matlab.” _Computers & Geosciences,_ (104) 151–157, doi:10.1016/j.cageo.2016.08.003.
