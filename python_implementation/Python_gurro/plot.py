from cmdstanpy import CmdStanModel
import arviz as az
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import math
from scipy.special import softmax
from tensorflow_probability.substrates import numpy as tfp
tfd = tfp.distributions
import sys

dataset = pd.read_csv('ts_nona_3.csv')
dataset_plot = pd.read_csv('ts_nona.csv')
y = np.array(dataset.iloc[:,1:53]) # 53 escluso
y_plot = np.array(dataset_plot.iloc[:,1:53]) # 53 escluso
data = y
data_plot = y_plot

a = float(sys.argv[1]) #3*12.85
M = float(sys.argv[2])
niter = int(sys.argv[3]) #15
nburn = int(sys.argv[4]) #5



clus_chain = pd.read_csv(f'clus_chain_M_{M}_a_{int(a)}.csv', delimiter=',')
clus_chain = np.array(clus_chain.iloc[:,1:40])

# distribution of the number of cluster
nclus_chain = np.zeros((niter-nburn), dtype=int)
for i in range(niter-nburn):
    nclus_chain[i] = np.max(clus_chain[i]) + 1
x_graph, y_graph = np.unique(nclus_chain, return_counts=True)
plt.figure(figsize=(16,9))
plt.bar(x_graph, y_graph)
plt.xticks(x_graph,size=26)
plt.yticks(size=26)
plt.xlabel("Number of clusters", size=28)
plt.title("Barplot of the number of clusters", size=30, weight='bold')

plt.savefig(f'n_clus_M_{M}_a_{int(a)}.svg')
plt.clf()


weeks = np.linspace(1, y.shape[1], 52)
list_scode = list(set(dataset.iloc[:,0]))
checks = 4 # Se lo volete provare mettete un numero pari grazie
clus_indeces = np.random.choice(np.arange(nclus_chain.shape[0]), size=checks)

figs, axs = plt.subplots(int(checks/2), 2, sharex=True, figsize=(16, 9))

for j in range(checks):

    clus_index = clus_indeces[j]
    palette = list(sns.color_palette(n_colors=len(np.unique(clus_chain[clus_index]))).as_hex())
    col_index = clus_chain[clus_index] # Il colore sarà indicato dalla label del cluster

    labels = []
    for i in range(len(np.unique(col_index))):
        labels.append("Cluster " + str(i+1))

    for i, col in enumerate(list_scode):
        axs[int(j/2), j%2].plot(weeks, data_plot[i], color=palette[int(col_index[i])], label=labels[int(col_index[i])])

    axs[int(j/2), j%2].set_title("MCMC iteration #" + str(clus_index) + \
                                 " Number of clusters: " + str(nclus_chain[clus_index]), size=16)

plt.savefig(f'time_series_it_M_{M}_a_{int(a)}.svg')
plt.clf()


# singola
clus_index = 0
palette = list(sns.color_palette(n_colors=len(np.unique(clus_chain[clus_index]))).as_hex())
col_index = clus_chain[clus_index] # Il colore sarà indicato dalla label del cluster
list_scode = list(set(dataset.iloc[:,0]))

labels = []
for i in range(len(np.unique(col_index))):
    labels.append("Cluster " + str(i+1))

weeks = np.linspace(1, y.shape[1], 52)

#plt.rcParams["figure.figsize"] = [8.5, 6]
plt.rcParams["figure.autolayout"] = True
for i, col in enumerate(list_scode):
    plt.plot(weeks, data_plot[i], color=palette[int(col_index[i])], label=labels[int(col_index[i])])

plt.title(" Number of clusters: " + str(nclus_chain[clus_index]), size=30, weight='bold')
plt.xticks(size=26)
plt.yticks(size=26)
#plt.legend(labels)
plt.savefig(f'time_series_it_sing_M_{M}_a_{int(a)}.svg')
