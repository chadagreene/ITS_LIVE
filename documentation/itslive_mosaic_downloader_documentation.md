[&larr; Back to ITS\_LIVE main page](../README.md)

# `itslive_mosaic_downloader` documentation
The `itslive2geo` function transforms projected map coordinates to geographic coordinates. 

## Syntax

```matlab
itslive_mosaic_downloader(region)
itslive_mosaic_downloader(..., year=years)
itslive_mosaic_downloader(..., path=targetPath)
```

## Description 

`itslive_mosaic_downloader(region)` downloads the summary mosaic for a specified region. The region must be a number in the range of 1 to 19, where 1 is Alaska and 19 is Antarctica. For a map of ITS\_LIVE regions, type [`itslive_regions`](itslive_regions_documentation.md). 

`itslive_mosaic_downloader(..., year=years)` specifies the year(s) of data to download. If the year is not specified, the 0000 summary mosaic is downloaded. 

`itslive_mosaic_downloader(..., path=targetPath)` specifies a target directory for the data. If the path is not specified, the current working directory is used. 

## Example 1
Download the summary mosaic for Greenland: 

```matlab
itslive_mosaic_downloader(5)
```

## Example 2 
Download the Greenland mosaics for the years 1985 to 1990: 

```matlab
itslive_mosaic_downloader(5, year=1985:1990) 
```

## Example 3
Download mosaics for Europe and Southern Andes and specify directory:

```matlab
itslive_mosaic_downloader([11 17], path='/Users/cgreene/Documents/data/ITS_LIVE') 
```

## Tip
To explore what data are available, check out [https://its-live-data.s3.amazonaws.com/index.html](https://its-live-data.s3.amazonaws.com/index.html).  

# Author Info
The MATLAB functions in this repo and this documentation were written by Chad A. Greene of NASA/JPL. [The NASA MEaSUREs ITS\_LIVE project](https://its-live.jpl.nasa.gov/) is by Alex S. Gardner and the ITS\_LIVE team. 

