#! This function takes a matrix B * N (B=num_iter, N=num_items) (or a list) and a dataframe of coordinates (N * 2), with colnames ("lat","lon").
#! The output is a plot of the graph, with the best clustering and optimal number of clusters under different loss function (select them).

plot_clustering <- function(data, coord, loss, M = NULL, a = NULL, dataset_plot, unique_vals_chain = NULL)
{
  
  library(salso)
  library(ggmap)
  library(ggplot2)
  # cast to matrix the eventual dataframe
  if(typeof(data) == "list")
  {
    nrow_ = dim(data)[1]
    ncol_ = dim(data)[2]
    data <- matrix(unlist(data), nrow=nrow_,ncol=ncol_, byrow = F)
  }
  s_binder <- salso(
    data,
    loss = loss,
    maxNClusters = 0,
    nRuns = 16,
    maxZealousAttempts = 10,
    probSequentialAllocation = 0.5,
    nCores = 0
  )
  best_clus <- summary(s_binder)
  
  # unique vals
  posterior_unique_vals_ = NULL
  if(!is.null(unique_vals_chain))
  {
  source("utils/unique_vals_given_clus.R")
  posterior_unique_vals_ = unique_vals_given_clus(unique_vals_chain, data, best_clus$estimate)
  }
  
  # plots
  loc <- c(left=min(coord$lon)-0.1*diff(range(coord$lon)), bottom=min(coord$lat)-0.1*diff(range(coord$lat)),
           right=max(coord$lon)+0.1*diff(range(coord$lon)), top=max(coord$lat)+0.1*diff(range(coord$lat)))
  mapdata <- get_map(location=loc, source="stamen")
  
  # added
  library(viridis)
  nClus = best_clus$nClusters
  # col_preset = viridis_pal(option = "C")(nClus)
  col_preset = rainbow(nClus)
  
  osservazioni_livelli = factor(as.numeric(best_clus$estimate))
  source("utils/genera_colori.R")
  livelli = levels(osservazioni_livelli)
  colori = genera_colori(osservazioni_livelli,col_preset)$colori
  colori_livelli = genera_colori(osservazioni_livelli,col_preset)$colori_livelli
  colori_set = setNames(colori_livelli, livelli)
  
  coord = cbind(coord, factor(as.numeric(best_clus$estimate)))
  names(coord)[4] = "Cluster"
  # added
  
  plot <- ggmap(mapdata) +
    geom_point(data=coord, aes(lon,lat, color=Cluster), size=3, alpha=0.8) +
    ggtitle(paste("Loss: ",toupper(loss), " -- N_clust =", best_clus$nClusters, " -- M =", M, " -- a =", a, sep=" "))+
    scale_color_manual(values = colori_set) +
    theme(axis.text=element_text(size=rel(2.5)),
          axis.title=element_text(size=rel(2.5)),
          plot.title = element_text(face="bold", size=rel(2), hjust = 0.5),
          legend.text = element_text(size=rel(2)),
          legend.title = element_text(size=rel(2)))
  
  plot_label = ggmap(mapdata) +
    geom_point(data=coord, aes(lon,lat, color=Cluster), size=3, alpha=0.8) +
    ggtitle(paste("Loss: ",toupper(loss), " -- N_clust =", best_clus$nClusters, " -- M =", M, " -- a =", a, sep=" ")) +
    geom_text(data = coord, aes(x = lon, y = lat, label = loc), hjust = 0, vjust = 0) +
    scale_color_manual(values = colori_set) +
    theme(axis.text=element_text(size=rel(2.5)),
          axis.title=element_text(size=rel(2.5)),
          plot.title = element_text(face="bold", size=rel(2), hjust = 0.5),
          legend.text = element_text(size=rel(2)),
          legend.title = element_text(size=rel(2)))
  
  par(mar=c(5,6,4,1))
  matplot <- matplot(t(dataset_plot), 
                     type="l", lty=1, col = colori, 
                     main = paste("Optimal clustering under", toupper(loss), sep=" "),
                     xlab = "Weeks",
                     ylab = "PM10",
                     cex.main = 2,
                     cex.lab = 2,
                     cex.axis = 2)
  
  legend("top", legend = livelli, fill = colori_livelli, bty="n", cex=1,ncol=nClus)
  matplot_g <- recordPlot()
  
  
  dev.off()
  
  psm <- plot(best_clus, "heatmap", main = paste("Posterior similarity matrix using",loss,"loss function",sep = " "))
  psm_g <- recordPlot()
  dev.off()
  out <- list(
    plot = plot,
    plot_label = plot_label,
    matplot = matplot_g,
    best_clus = best_clus$estimate,
    nClus = best_clus$nClusters,
    psm = psm_g,
    posterior_unique_vals = posterior_unique_vals_,
    posterior_unique_vals_labels = unique(as.numeric(best_clus$estimate))
  )
  
  
  
  return(out)
}