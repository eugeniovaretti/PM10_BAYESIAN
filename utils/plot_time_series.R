plot_time_series = function(data, label1, label2, anno, xlab = "Weeks", ylab = "PM10")
  # data è una matrice di timeseries (ogni riga è una timeseries)
  # label1 e label2 sono vettori di char, con lunghezza nrows della matrice (numero di timeseries)
{
  library(viridis)
  data = t(data)
  osservazioni_livelli1 = factor(label1)
  livelli1 = levels(osservazioni_livelli1)
  colori1 = genera_colori(osservazioni_livelli1)$colori
  colori_livelli1 = genera_colori(osservazioni_livelli1)$colori_livelli
  titolo = paste("Concentration of PM10 in", anno)
  plot1 = plot.ts(data,plot.type = "single", col=colori1, xlab = xlab, ylab = ylab, main = titolo)
  legend("top", legend = livelli1, fill = colori_livelli1, bty="n", cex=0.8)
  plot1_g <- recordPlot()
  dev.off()
  
  osservazioni_livelli2 = factor(label2)
  livelli2 = levels(osservazioni_livelli2)
  colori2 = genera_colori(osservazioni_livelli2, viridis_pal(option = "C")(3))$colori
  colori_livelli2 = genera_colori(osservazioni_livelli2, viridis_pal(option = "C")(3))$colori_livelli
  plot2 = plot.ts(data,plot.type = "single", col=colori2, xlab = xlab, ylab = ylab, main = titolo)
  legend("top", legend = livelli2, fill = colori_livelli2, bty="n", cex=0.8)
  plot2_g <- recordPlot()
  dev.off()
  
  return(list(plot1 = plot1_g,
              plot2 = plot2_g))
}