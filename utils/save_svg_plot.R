
#' Per un plot standard si usa mettendo nello script tutte le instruzioni per il
#' plot ed infine "plot_recorded = recordPlot()". Si passa a questa funzione 
#' "plot_recorded"
#' Per un ggplot si usa salvando il plot in una variabile che viene passata
#' 
#' Può essere usata per salvare 
# in name non ci va .svg
# in folder l'ultimo carattere deve essere / e all'inizio non ci va /

save_svg_plot = function(plot, name="test", folder="", type="normal", width = 9, height = 6)
{
  nome_finale = paste(folder, name, ".svg", sep="")
  if(type == "normal")
  {
    svg(nome_finale, width = width, height = height)
    replayPlot(plot)
    dev.off()
  } else if(type == "ggplot")
  {
    #ggsave(nome_finale, plot, width = width, height = height)
    svg(nome_finale, width = width, height = height)
    print(plot)
    dev.off()
  }
}
