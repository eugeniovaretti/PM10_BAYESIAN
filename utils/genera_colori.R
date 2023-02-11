genera_colori = function(var_factor, colori_livelli=NULL)
{
  livelli = levels(var_factor) # vettore di stringhe con nomi livelli
  numero_livelli = length(livelli)
  n = length(var_factor)
  
  if(is.null(colori_livelli))
    colori_livelli = rainbow(numero_livelli) # g colori
  
  colori = rep(NA, n) # inizializzo quello che sarà il vettore dei colori di lunghezza n
  for(i in 1:n)
  {
    vettore_logico = var_factor[i] == livelli
    indice_col_ramp = which(vettore_logico) # which prende un vettore logico e restituisce l'indice del TRUE (l'unico)
    colori[i] = colori_livelli[indice_col_ramp]
  }
  
  list(colori = colori, colori_livelli = colori_livelli)
}