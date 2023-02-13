read_ts_from_emilia = function(anno = "2018", data_name = "input_data/PM10_Emilia.csv")
{
  n_giorni = 365
  if(anno=="2016"){n_giorni = 366}
  PM10_Emilia = read.csv(data_name)
  PM10_Emilia = na.omit(PM10_Emilia)
  
  # divido i dati per localita, selezionando un anno in particolare
  localita = unique(PM10_Emilia[,"NomeStazione"])
  p = length(localita)
  data = PM10_Emilia[which(PM10_Emilia[,"Anno"]== anno),]
  data_split = vector(mode = "list", length = p)
  for(i in 1:p)
  {
    data_split[[i]] = data[which(data[,"NomeStazione"]==localita[i]), ]
  }
  # import info about year

  dati_anni = read.delim2("input_data/dati_anni.txt", header=FALSE)
  dati_anni = dati_anni[-c(2,5,6)]
  anno_vett = c(rep("2014",365),rep("2015",365),rep("2016",366),rep("2017",365),rep("2018",365),rep("2019",365))
  dati_anni = cbind(dati_anni,anno_vett)
  colnames(dati_anni)=c("numero", "giorno","settimana","anno")
  dati_anno = dati_anni[which(dati_anni$anno==anno),]
  
  # costruisco una matrice 365 x numero_localita in cui inserisco i valori di una variabile a piacimento (misurazioni PM10), aggiungo gli opportuni Na
  dati_completi = matrix(NA, nrow = n_giorni, ncol = p)
  colnames(dati_completi) = localita
  
  variabile = "Valore"
  
  for(i in 1:p) # scorre le colonne della matrice
  {
    k = 1
    n = nrow(data_split[[i]])
    for(j in 1:n_giorni)
    {
      if(data_split[[i]][k,"Wday"] == dati_anno[j,"giorno"] & k<=n)
      {
        dati_completi[j,i] = data_split[[i]][k,variabile]
        k=k+1
      }
    }
  }
  
  # faccio la media nelle settimane
  dati_completi_set = matrix(NA, nrow = 52, ncol = p)
  colnames(dati_completi_set) = localita
  
  for(i in 1:p)
  {
    for(j in 1:52)
    {
      dati = dati_completi[which(dati_anno$settimana == j),i]
      dati_completi_set[j,i] = mean(dati,na.rm = TRUE)
      if(is.nan(dati_completi_set[j,i])){dati_completi_set[j,i]=NA}
    }
  }
  
  # gestisco gli na rimanenti
  source("utils/ts_imputation.R")
  index = 0
  for(i in 1:p)
  {
    ts = dati_completi_set[,i]
    n_na = sum(is.na(ts))
    if(n_na > 0.05*52){
      index = c(index,i)
    } else if(n_na>0){
      dati_completi_set[,i] = ts_imputation(ts)
    }
  }
  index = index[-1]
  indici = 1:p
  indici = indici[-index]
  dati_completi_set = dati_completi_set[,indici]
  p = ncol(dati_completi_set)
  localita = localita[indici]
  
  # creo delle label relative all'area per visualizzare le ts
  area_localita = rep("",length(indici))
  tipo_localita = rep("",length(indici))
  j=1
  for (i in indici)
  {
    area_localita[j] = unique(data_split[[i]][,"Area"])
    tipo_localita[j] = unique(data_split[[i]][,"Tipo"])
    j=j+1
  }
  
  medie = colMeans(dati_completi_set)
  ts_no_mean = dati_completi_set
  for (i in 1:p) {
    ts_no_mean[,i] = dati_completi_set[,i] - medie[i]
  }
  
  list(localita = localita,
       area_localita = area_localita,
       tipo_localita = tipo_localita,
       time_series_sett = dati_completi_set,
       time_series_sett_no_mean = ts_no_mean)
  
  #write.csv(t(dati_completi_set), row.names = FALSE, col.names = FALSE, file = paste('ts_emilia_', anno, '.csv', sep=""))
  #write.csv(t(dati_completi_set),  file = paste('ts_emilia_', anno, '_con_nomi.csv', sep=""))
  
  
}