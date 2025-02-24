[&larr; Back to ITS\_LIVE main page](../README.md)

# `itslive_regions` documentation
The `itslive_regions` function displays a world map with ITS\_LIVE mosaic regions labeled. 

## Syntax

```matlab
itslive_regions
h = itslive_regions 
```

## Description 

`itslive_regions` displays a map of ITS\_LIVE regions. 

`h = itslive_regions` also returns a handle `h` of the plotted object. 

## Example
Here's how to show the ITS\_LIVE regions in MATLAB: 

```matlab
itslive_regions
```
![](../ITS_LIVE_v2_mosaic_regions.jpeg)

In the image above, each colored rectangle represents an ITS\_LIVE mosaic region. For example, RGI01A corresponds to Region 1 in the syntax of the MATLAB functions in this repository. 

Some 100 km by 100 km black squares fall outside the ITS\_LIVE mosaic regions. In those locations, the full record of velocity data are available in Zarr and NetCDF format as Level 2 image-pair data, but are not provided as mosaicked data. 

To explore what data are available, check out [https://its-live-data.s3.amazonaws.com/index.html](https://its-live-data.s3.amazonaws.com/index.html).   

# Author & Citation Info
The MATLAB functions in this repo and this documentation were written by Chad A. Greene of NASA/JPL. [The NASA MEaSUREs ITS\_LIVE project](https://its-live.jpl.nasa.gov/) is by Alex S. Gardner and the ITS\_LIVE team. If you use ITS\_LIVE v2 velocity data, please cite: 

Gardner, A. S., Greene, C. A., Kennedy, J. H., Fahnestock, M. A., Liukis, M., López, L. A., Lei, Y., Scambos, T. A., and Dehecq, A.: ITS_LIVE global glacier velocity data in near real time, EGUsphere [preprint], [https://doi.org/10.5194/egusphere-2025-392](https://doi.org/10.5194/egusphere-2025-392), 2025. 