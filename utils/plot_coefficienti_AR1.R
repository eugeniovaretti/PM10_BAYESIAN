plot_coefficienti_AR1 = function(coefficienti, label1, label2, xlab = "Locations", ylab = "AR(1) coefficients")
{
  library(viridis)
  osservazioni_livelli1 = factor(label1)
  livelli1 = levels(osservazioni_livelli1)
  colori1 = genera_colori(osservazioni_livelli1)$colori
  colori_livelli1 = genera_colori(osservazioni_livelli1)$colori_livelli
  plot1 = plot(coefficienti, 
               col=colori1,
               pch=19,
               xlab = xlab,
               ylab = ylab,
               main = "AR(1) coefficients for each location")
  legend("bottomright", legend = livelli1, fill = colori_livelli1, bty="n", cex=0.8)
  plot1_g <- recordPlot()
  dev.off()
  
  osservazioni_livelli2 = factor(label2)
  livelli2 = levels(osservazioni_livelli2)
  colori2 = genera_colori(osservazioni_livelli2, viridis_pal(option = "C")(3))$colori
  colori_livelli2 = genera_colori(osservazioni_livelli2, viridis_pal(option = "C")(3))$colori_livelli
  plot2 = plot(coefficienti, 
               col=colori2,
               pch=19,
               xlab = xlab,
               ylab = ylab,
               main = "AR(1) coefficients for each location")
  legend("bottomright", legend = livelli2, fill = colori_livelli2, bty="n", cex=0.8)
  plot2_g <- recordPlot()
  dev.off()
  
  return(list(plot1 = plot1_g,
              plot2 = plot2_g))
}