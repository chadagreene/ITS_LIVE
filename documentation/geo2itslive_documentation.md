[&larr; Back to ITS\_LIVE main page](../README.md)

# `geo2itslive` documentation
The `geo2itslive ` function transforms geographic coordinates to projected map coordinates.[^1]

## Syntax

```matlab
[x, y] = geo2itslive(region, lat, lon)
```

## Description 

`[x, y] = geo2itslive(region, lat, lon)` converts the geocoordinates `lat` and `lon` into projected map coordinates `x` and `y` in meters. The region must be a number from 1 to 19 corresponding to ITS\_LIVE regions (which approximately match RGI regions). For a map of ITS\_LIVE regions, type [`itslive_regions`](itslive_regions_documentation.md). 

## Example
Convert this spot on Malaspina Glacier Alaska (Region 1) to map coordinates: 

```matlab
[x, y] = geo2itslive(1, 60.08343, -140.46707)

x =
   -3298427.76
y =
     315689.27
```

Now convert them back into geocoordinates: 

```matlab
[lat, lon] = itslive2geo(1, x, y)

lat =
   60.0834
lon =
 -140.4671
```

# Author & Citation Info
The MATLAB functions in this repo and this documentation were written by Chad A. Greene of NASA/JPL. [The NASA MEaSUREs ITS\_LIVE project](https://its-live.jpl.nasa.gov/) is by Alex S. Gardner and the ITS\_LIVE team. If you use ITS\_LIVE v2 velocity data, please cite: 

Gardner, A. S., Greene, C. A., Kennedy, J. H., Fahnestock, M. A., Liukis, M., López, L. A., Lei, Y., Scambos, T. A., and Dehecq, A.: ITS_LIVE global glacier velocity data in near real time, EGUsphere [preprint], [https://doi.org/10.5194/egusphere-2025-392](https://doi.org/10.5194/egusphere-2025-392), 2025. 

[^1]: Requires MATLAB's Mapping Toolbox
