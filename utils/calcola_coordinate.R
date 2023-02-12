calcola_coordinate = function(località, file_name = "input_data/Stations_Coord.csv")
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
  coordinate_long_lat = cbind(long, lat)
  coordinate_lat_long = cbind(lat, long)
  
  list(coordinate_lat_long = coordinate_lat_long,
       coordinate_long_lat = coordinate_long_lat)
  
}