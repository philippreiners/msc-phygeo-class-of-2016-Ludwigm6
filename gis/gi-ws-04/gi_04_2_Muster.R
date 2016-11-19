
shell('C:/OSGEO4~1/apps/saga/modules/ta_morphometry.dll -SLOPE = slpe -MINCURV = minimalcrv -MAXCURV = maximalcrv -PCURV = profile -TCURV = tangential -PLAIN = NULL -PIT = NULL -PEAK = NULL -RIDGE = NULL -CHANNEL = NULL -SADDLE = NULL -BSLOPE = NULL -FSLOPE = NULL -SSLOPE = NULL -HOLLOW = NULL -FHOLLOW = NULL -SHOLLOW = NULL -SPUR = NULL -FSPUR = NULL -SSPUR = NULL -FORM = NULL -MEM = NULL -ENTROPY = NULL -CI = NULL -SLOPETODEG = NULL -T_SLOPE_MIN = NULL -T_SLOPE_MAX = NULL -T_CURVE_MIN = NULL -T_CURVE_MAX = NULL)

slope <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/slope.tif"

maximalcrv <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/maximal.tif"

minimalcrv <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/minimal.tif"

profile <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/profile.tif"

tangential <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/tangential.tif"

output <- "C:/Users/Marius/Documents/Uni/Master/WS_1617/Advanced_GIS/data/plain2.sgrd"

plot(profile)

system(abc)
system(paste0("C:/OSGeo4W64/apps/saga/saga_cmd.exe ta_morphometry 25 -SLOPE=",slope,
                                                                     " -MINCURV=" ,minimalcrv,
                                                                     " -MAXCURV=", maximalcrv, 
                                                                     " -PCURV=",profile, 
                                                                     " -TCURV=",profile,
                                                                     " -PLAIN=", output))
abc
shell(C:/OSGeo4W64/apps/saga/saga_cmd.exe)
"