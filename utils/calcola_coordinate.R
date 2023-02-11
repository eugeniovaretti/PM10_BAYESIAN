calcola_coordinate = function(località, file_name = "Stations_Coord.csv")
{
  coord = read.csv(file_name)
  p = length(località)
  indici = rep(0,p)
  k =1
  for (j in 1:p) {
    for (i in 1:nrow(coord)) {
      if(località[j] == coord$NomeStazione[i])
      {
        indici[k] = coord$X[i]
        k=k+1
      }
    }
    
  }
  coordinate_lat_long = coord[indici,3:4]
  lat <- coordinate_lat_long[,1]
  long <- coordinate_lat_long[,2]
  
  R <- 6371 # set the approx of Earth radius R
  
  # compute cartesian coordinates
  x <- R*cos(lat)*cos(long)
  y <- R*cos(lat)*sin(long)
  z <- R*sin(lat)
  
  # create new dataframes
  coordinate_x_y_z <- cbind(x,y,z)
  coordinate_x_y <- cbind(x,y)
  
  list(coordinate_lat_long = coordinate_lat_long,
       coordinate_x_y_z = coordinate_x_y_z,
       coordinate_x_y = coordinate_x_y)
  
}