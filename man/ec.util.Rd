% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/util.R
\name{ec.util}
\alias{ec.util}
\title{Utility functions}
\usage{
ec.util(..., cmd = "sf.series", js = NULL)
}
\arguments{
\item{...}{Optional parameters for the command \cr
for \emph{sf.series} - see \href{https://echarts.apache.org/en/option.html#series-scatter.type}{points}, \href{https://echarts.apache.org/en/option.html#series-lines.type}{polylines}, polygons(itemStyle).\cr
for \emph{tabset} parameters should be in format \emph{name1=chart1, name2=chart2}, see example\cr}

\item{cmd}{utility command, see Details\cr}

\item{js}{optional JavaScript function, default is NULL.\cr}
}
\description{
tabset, table layout, support for GIS shapefiles through library 'sf'
}
\details{
\strong{cmd = 'sf.series'}\cr
\verb{ }Build \emph{leaflet} or \href{https://echarts.apache.org/en/option.html#geo.map}{geo} map series from shapefiles.\cr
\verb{ }Supported types: POINT, MULTIPOINT, LINESTRING, MULTILINESTRING, POLYGON, MULTIPOLYGON \cr
\verb{ }Coordinate system is \emph{leaflet}(default), \emph{geo} or \emph{cartesian3D} (for POINT(xyz))\cr
\verb{ }Limitations:\cr
\verb{     }polygons can have only their name in tooltip,  \cr
\verb{     }assumes Geodetic CRS is WGS 84, for conversion use \link[sf]{st_transform} with \emph{crs=4326}.\cr
\verb{ }Parameters:\cr
\verb{   }df - value from \link[sf]{st_read}\cr
\verb{   }nid - optional column name for name-id used in tooltips\cr
\verb{   }cs - optional \emph{coordinateSystem} value, default 'leaflet'\cr
\verb{   }verbose - optional, print shapefile item names in console\cr
\verb{ }Returns a list of chart series\cr
\strong{cmd = 'sf.bbox'}\cr
\verb{ }Returns JavaScript code to position a map inside a bounding box from \link[sf]{st_bbox}, for leaflet only.\cr
\strong{cmd = 'sf.unzip'}\cr
\verb{ }Unzips a remote file and returns local file name of the unzipped .shp file\cr
\verb{   }url - URL of remote zipped shapefile\cr
\verb{   }shp - optional name of .shp file inside ZIP file if multiple exist. Do not add file extension. \cr
\strong{cmd = 'geojson'} \cr
\verb{ }Custom series list from geoJson objects\cr
\verb{   }geojson - object from \link[jsonlite]{fromJSON}\cr
\verb{   }cs - optional \emph{coordinateSystem} value, default 'leaflet'\cr
\verb{   }ppfill - optional fill color like '#F00', OR NULL for no-fill, for all Points and Polygons\cr
\verb{   }nid - optional feature property for item name used in tooltips\cr
\verb{   }... - optional custom series attributes like \emph{itemStyle}\cr
\verb{ }Can display also geoJson \emph{feature properties}: color; lwidth, ldash (lines); ppfill, radius (points)\cr
\strong{cmd = 'layout'} \cr
\verb{ }Multiple charts in table-like rows/columns format\cr
\verb{   }... - List of charts\cr
\verb{   }title - optional title for the set, rows= Number of rows, cols= Number of columns\cr
\verb{ }Returns a container \link[htmltools]{div} in rmarkdown, otherwise \link[htmltools]{browsable}.\cr
\verb{ }For 3-4 charts one would use multiple series within a \href{https://echarts.apache.org/en/option.html#grid}{grid}. \cr
\verb{ }For greater number of charts \emph{ec.util(cmd='layout')} comes in handy\cr
\strong{cmd = 'tabset'} \cr
\verb{   }... - a list name/chart pairs like \emph{n1=chart1, n2=chart2}, each tab may contain a chart.\cr
\verb{   }tabStyle - tab style string, see default \emph{tabStyle} variable in the code\cr
\verb{ }Returns A) \link[htmltools]{tagList} of tabs when in a pipe without '...' params, see example\cr
\verb{ }Returns B) \link[htmltools]{browsable} when '...' params are provided by user\cr
\strong{cmd = 'button'} \cr
\verb{ }UI button to execute a JS function,\cr
\verb{   }text - the button label\cr
\verb{   }js - the JS function string\cr
\verb{   }... - optional parameters for the \href{https://echarts.apache.org/en/option.html#graphic.elements-rect.type}{rect} element\cr
\verb{ }Returns a graphic.elements-\href{https://echarts.apache.org/en/option.html#graphic.elements-rect.type}{rect} element.\cr
\strong{cmd = 'morph'} \cr
\verb{   }... - a list of charts or chart options\cr
\verb{   }js - optional JS function for switching charts. Default function is on \emph{mouseover}. Disable with FALSE.\cr
\verb{ }Returns a chart with ability to morph into other charts\cr
\strong{cmd = 'fullscreen'} \cr
\verb{ }A toolbox feature to toggle fullscreen on/off. Works in a browser, not in RStudio.\cr
\strong{cmd = 'rescale'} \cr
\verb{   }v - input vector of numeric values to rescale\cr
\verb{   }t - target range c(min,max), numeric vector of two\cr
\strong{cmd = 'level'} \cr
\verb{ }Calculate vertical levels for timeline \emph{line} charts, returns a numeric vector\cr
\verb{   }df - data.frame with \emph{from} and \emph{to} columns\cr
\verb{   }from - name of 'from' column\cr
\verb{   }to - name of 'to' column\cr
}
\examples{
if (interactive()) {  # comm.out: Fedora errors about some 'browser'
  library(sf)
  fname <- system.file("shape/nc.shp", package="sf")
  nc <- as.data.frame(st_read(fname))
  ec.init(load= c('leaflet', 'custom'),  # load custom for polygons
     js= ec.util(cmd= 'sf.bbox', bbox= st_bbox(nc$geometry)),
     series= ec.util(cmd= 'sf.series', df= nc, nid= 'NAME', itemStyle= list(opacity=0.3)),
     tooltip= list(formatter= '{a}')
  )

  htmltools::browsable(
    lapply(iris |> dplyr::group_by(Species) |> dplyr::group_split(), 
           function(x) {
     x |> ec.init(ctype= 'scatter', title= list(text= unique(x$Species)))
           }) |> 
    ec.util(cmd= 'tabset')
  )

  p1 <- cars |> ec.init(grid= list(top= 20))  # move chart up
  p2 <- mtcars |> ec.init()
  ec.util(cmd= 'tabset', cars= p1, mtcars= p2, width= 333, height= 333)

  lapply(list('dark','macarons','gray','jazz','dark-mushroom'),
                \(x) cars |> ec.init() |> ec.theme(x) ) |>
  ec.util(cmd='layout', cols= 2, title= 'my layout')
  
  setd <- \(type) {
	   mtcars |> group_by(cyl) |> 
	 ec.init(ctype= type,
		  title= list(subtext= 'mouseover points to morph'),
		  xAxis= list(scale= TRUE))
  }
  oscatter <- setd('scatter')
  obar <- setd('bar')
  ec.util(cmd='morph', oscatter, obar)
}
}
