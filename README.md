# TCI
## Description 
here you find...

## TCI_TS_clickPoint_LC
This code provides the capability to visualize the TCI time series with a trendline for a selected region of interest (ROI). Additionally, by clicking on the map, users can retrieve geographic coordinates, landcover class information, TCI time series, and pixel count histograms for specific points.

You can also access GEE directly via [this link](https://code.earthengine.google.com/f882ed53aaa6fc83c95cd5e50ff1d5b0).

## TCI_map_rgb_unchanged_pixel_export 
This code prepares the data for exporting as a Google Drive file, containing the following information (only for pixels that have not changed land cover types from 2003 to 2022):

- TCI values
- TCI-detrended values
- Mean annual temperature
- Mean annual precipitation
- Pixel count
- Year
- Longitude and latitude

Additionally, you will receive a false-color image map where red represents TCI values, green represents standard deviation values, and blue represents the pixel count.

You can also access GEE directly via [this link](https://code.earthengine.google.com/328f4ab5739189e2f3ab1243d641ad03).

## sample_points_TCI.R

The R code processes the previously exported points, categorizing them based on climatic conditions, and generates scatterplots between pixel count and detrended TCI values.

