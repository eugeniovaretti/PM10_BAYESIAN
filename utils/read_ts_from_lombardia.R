read_ts_from_lombardia = function(data_name = "input_data/ImposedDB_complete.csv")
{
  data <- read.csv(data_name)
  
  # split data based on locations
  localita = unique(data$NomeStazione)
  p = length(localita)
  library(dplyr)
  
  data_split = vector(mode = "list", length = p)
  for(i in 1:p)
  {
    data_split[[i]] = data[which(data$NomeStazione ==localita[i]), ]
    data_split[[i]] <- data_split[[i]] %>% arrange(Data)
  }
  
  # build a matrix 
  data_matrix = matrix(NA, nrow = 365, ncol = p)
  colnames(data_matrix) = localita
  
  variabile = "Valore"
  
  for(i in 1:p) # scorre le colonne della matrice
  {
    for(j in 1:365)
    {
      data_matrix[j,i] = data_split[[i]][j,variabile]
    }
  }
  
  # mean by weeks
  data_matrix_set = matrix(NA, nrow = 52, ncol = p)
  colnames(data_matrix_set) = localita
  
  for(i in 1:p)
  {
    
    for(j in 1:52)
    {
      index = 7*j - 6
      dati = data_matrix[index:(index+6),i]
      data_matrix_set[j,i] = mean(dati)
    }
  }
  
  # labels related to locations
  area_localita = rep("",p)
  tipo_localita = rep("",p)
  for (i in 1:p)
  {
    area_localita[i] = unique(data_split[[i]][,"Area"])
    if(area_localita[i]=="U"){
      area_localita[i]="Urbano"
    } else if(area_localita[i]=="R"){
      area_localita[i]="Rurale"
    } else if(area_localita[i]=="S"){
      area_localita[i]="Suburbano"
    }
    tipo_localita[i] = unique(data_split[[i]][,"Tipo"])
    if(tipo_localita[i]=="B"){
      tipo_localita[i]="Fondo"
    } else if(tipo_localita[i]=="T"){
      tipo_localita[i]="Traffico"
    } else if(tipo_localita[i]=="I"){
      tipo_localita[i]="Industriale"
    }
  }
  
  list(localita = localita,
       area_localita = area_localita,
       tipo_localita = tipo_localita,
       time_series_sett = data_matrix_set)
}