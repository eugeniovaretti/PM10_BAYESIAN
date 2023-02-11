read_ts_from_lombardia = function(data_name = "input_data/ImposedDB_complete.csv")
{
  data <- read.csv(data_name)
  
  # split data based on locations
  località = unique(data$NomeStazione)
  p = length(località)
  library(dplyr)
  
  data_split = vector(mode = "list", length = p)
  for(i in 1:p)
  {
    data_split[[i]] = data[which(data$NomeStazione ==località[i]), ]
    data_split[[i]] <- data_split[[i]] %>% arrange(Data)
  }
  
  # build a matrix 
  data_matrix = matrix(NA, nrow = 365, ncol = p)
  colnames(data_matrix) = località
  
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
  colnames(data_matrix_set) = località
  
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
  area_località = rep("",p)
  tipo_località = rep("",p)
  for (i in 1:p)
  {
    area_località[i] = unique(data_split[[i]][,"Area"])
    if(area_località[i]=="U"){
      area_località[i]="Urbano"
    } else if(area_località[i]=="R"){
      area_località[i]="Rurale"
    } else if(area_località[i]=="S"){
      area_località[i]="Suburbano"
    }
    tipo_località[i] = unique(data_split[[i]][,"Tipo"])
    if(tipo_località[i]=="B"){
      tipo_località[i]="Fondo"
    } else if(tipo_località[i]=="T"){
      tipo_località[i]="Traffico"
    } else if(tipo_località[i]=="I"){
      tipo_località[i]="Industriale"
    }
  }
  
  list(località = località,
       area_località = area_località,
       tipo_località = tipo_località,
       time_series_sett = data_matrix_set)
}