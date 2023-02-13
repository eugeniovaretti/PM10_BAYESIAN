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

# Importazione dati
dataset = pd.read_csv('../bayesmix/resources/datasets/ts.csv', header=None)
dataset_plot = pd.read_csv('../bayesmix/resources/datasets/ts_mean.csv', header=None)
print(dataset.shape)
print(dataset_plot.shape)
T = dataset.shape[1]

# Coordinate
coords_file = pd.read_csv('../bayesmix/resources/datasets/coord.csv', header=None)
print(coords_file.shape)
coords_file.head()


y = np.array(dataset)
y_plot = np.array(dataset_plot)
# y_i_t (rows -> localities; columns->weeks)
coords = np.array(coords_file)

# Functions for time series

def covf(v, tau): # v is a vector
    # Covariance function with time lag tau
    cov = 0
    # check over tau...
    for i in range(tau, len(v)):
        cov += (v[i] * v[i-tau])
    return (cov / len(v)-tau)


def avg_covf(vs, tau): # vs is a matrix
    # Average sample mean of covariance functions
    # with time lag tau of all the series
    avg_cov = 0
    # check over tau...
    n = vs.shape[0]
    for i in range(0, n): # da 0 ad n-1
        avg_cov += covf(np.array(vs[i]),tau)

    return (avg_cov / n)


def sample_nnig_post(clusdata, rho_0, lam, alpha, beta):

    n = clusdata.shape[0]
    T = clusdata.shape[1]
    # clusdata is a matrix n*T

    A = n * (T-1) * avg_covf(clusdata[:, 0:(T - 1)],0) + lam
    B = n * (T-2) * avg_covf(clusdata[:, 0:(T - 1)],1) + lam*rho_0
    C = n * T * avg_covf(clusdata,0) + lam*(rho_0**2)

    # Posterior parameters for sampling from the Normal (Rho (k+1))
    rho_post = B / A
    lam_post = A

    # Posterior parameters for sampling from the Inverse-Gamma (Sigma_2_h (k+1))
    alpha_post = alpha + (n * T)/2
    beta_post = beta + 0.5*( C - (B**2)/A )

    # Update Sigma_2_h (k+1)
    sig_2_new = tfd.InverseGamma(alpha_post, beta_post).sample()

    # Update Rho_h (k+1)
    rho_new = tfd.Normal(rho_post, np.sqrt(sig_2_new)/lam_post).sample()
    #print(rho_new)

    return rho_new, sig_2_new


def marginal_nnig(y, rho_0, lam, alpha, beta):

    n = 1 # In questo caso
    T = len(y)

    A =  (T-1) * covf(y[0:(T - 1)],0) + lam
    B =  (T-2) * covf(y[0:(T - 1)],1) + lam * rho_0
    C =  T * covf(y,0) + lam*(rho_0**2)

    coeff = math.gamma(alpha + T/2) / \
            ( math.gamma(alpha) * (math.pi*2*alpha)**(T/2) * ( ((beta**T)*A)/((alpha**T)*lam) )**(0.5) )

    res = ( 1 + 1/(2*alpha)*( (alpha/beta)*(C - B**2/A) ) )**(-T/2 -alpha)

    return np.log( coeff*res )


#####################
### NEAL - STEP 1 ###
#####################
def sample_clus_allocs(y, clus_allocs, coords, rho_h, sig_2_h, M, a):

    T = y.shape[1]
    # clus_allocs = vector of labels of observation i: c_i
    # Unique values are stored in:
        # rho_h: vector of Rhos of the clusters labelled by c_i
        # sig_h: vector of Sigmas of the clusters labelled by c_i
    # M, a: parameters for the computation of the weights
        # ------------> These two are to be decided <------------

    #_, n_by_clus=np.unique(clus_allocs,return_counts=True)
    # I don't care abut the unique values but i save only
    # the number of times the unique value appears.
    # n_by_clus = vector saying how many obs there are in label c_i

    for i in range(y.shape[0]):

        _, n_by_clus=np.unique(clus_allocs,return_counts=True)

        c_i=clus_allocs[i]
        n_by_clus[c_i] -= 1

        # Check if it was a singleton --> i have to delete it
        if n_by_clus[c_i]==0:
            n_by_clus = np.delete(n_by_clus,c_i) # Vettore delle cardinalità degli S_h^(-i)
            rho_h = np.delete(rho_h,c_i)
            sig_2_h = np.delete(sig_2_h,c_i)
            clus_allocs[clus_allocs>c_i]-=1
            # Decreasing the labels greater than c_i in order to have labels in sequence

        K = len(n_by_clus)

        log_probs = np.zeros(K+1)

        # Probability of sitting in a table already existing:
        near_clus = np.ones(K) # variabili flag, se trovo una località troppo lontana (>a) diventerà zero

        x_i, y_i = coords[i][0], coords[i][1]
        # Cycling to check the distancies for each cluster
        for j in range(y.shape[0]):
            if ( not( near_clus.any() ) ):
                break
            else:
                if( j!=i ):
                    if( near_clus[ clus_allocs[j] ] ):
                        x_j, y_j = coords[j][0], coords[j][1]
                        if( np.sqrt( (x_i-x_j)**2 + (y_i-y_j)**2 ) > a ):
                            near_clus[ clus_allocs[j] ] = 0


        for k in range(0, K):
            if(near_clus[k]):
                loc = np.zeros(T)
                diag = np.repeat(1 + rho_h[k]**2,T)
                diag[T-1] = 1
                inf_diag = sup_diag = np.repeat(-rho_h[k], T-1)
                H = np.diag(diag, 0) + np.diag(inf_diag, -1) + np.diag(sup_diag, 1)
                Sigma_inv = H / sig_2_h[k]
                Sigma = np.linalg.inv(Sigma_inv)

                E,V = np.linalg.eigh(Sigma)
                scale = np.linalg.cholesky(Sigma) #Sigma_inv

                log_probs[k] = np.log(n_by_clus[k])
                lik = tfd.MultivariateNormalTriL(loc, scale)
                log_probs[k] += lik.log_prob(y[i])
            else:
                log_probs[k] = float('-inf')

        # Probability of sitting in a new table:
        log_probs[K] = np.log(M)
        marg = marginal_nnig(y[i], rho_0, lam, alpha, beta)
        log_probs[K] += marg

        # Sampling a new label
        h_new = tfd.Categorical(probs=softmax(log_probs)).sample()

        clus_allocs[i] = h_new

        if h_new == K:
            # Sampling unique values -> i need to add them to the others
            # and also update n_by_clus
            # Faccio direttamente dalla prior
            rho_new = tfd.Normal(loc=rho_first, scale=sig_2_first/lam).sample(3)
            sig_2_new = tfd.InverseGamma(alpha, beta).sample(3)

            rho_h = np.concatenate([rho_h,rho_new])
            sig_2_h = np.concatenate([sig_2_h,sig_2_new])
            n_by_clus = np.concatenate([n_by_clus,[1]])
        else:
            n_by_clus[h_new] +=1

    return clus_allocs, rho_h, sig_2_h

#####################
### NEAL - STEP 2 ###
#####################

def sample_clus_params(y, clus_allocs, rho_0, lam, alpha, beta): # Anche qui ovviamente rivedi parametri
    nclus = len(np.unique(clus_allocs)) # K
    # How many unique values in the cluster allocations

    clus_labels=np.unique(clus_allocs)
    # Vector where in position h i have label c

    rho_out=np.zeros(nclus)
    sig_2_out=np.zeros(nclus)

    for h,clus_id in enumerate(clus_labels):
        tmp = sample_nnig_post(y[clus_allocs == clus_id], rho_0, lam, alpha, beta)
        rho_out[h]=tmp[0]
        sig_2_out[h]=tmp[1]

    return rho_out, sig_2_out


def run_one_gibbs(y, clus_allocs, coords, rho_h, sig_2_h, M, a):

    #####################
    ### NEAL - STEP 1 ###
    #####################

    clus_allocs, rho_h, sig_2_h = sample_clus_allocs(y, clus_allocs, coords, rho_h, sig_2_h, M, a)

    #####################
    ### NEAL - STEP 2 ###
    #####################

    rho_h, sig_2_h = sample_clus_params(y, clus_allocs, rho_0, lam, alpha, beta)

    return clus_allocs, rho_h, sig_2_h


## Fixed parameters
rho_0 = 0.4807468
lam = 13625.29
alpha = 7.690926
beta = 1257.956

## Initial values
rho_first = rho_0 # media campionaria dei rho
sig_2_first = 10

# sPPM parameters
a = float(sys.argv[1]) #3*12.85
M = float(sys.argv[2]) #1 # Consigliato da paper sPPM caso C2

data = y
data_plot = y_plot
n = data.shape[0]

n_clus_init = 3

clus_allocs = np.random.choice(np.arange(n_clus_init), size=y.shape[0])

rho_h = tfd.Normal(loc=rho_first, scale=sig_2_first/lam).sample(n_clus_init)
sig_2_h = tfd.InverseGamma(alpha, beta).sample(n_clus_init)

niter = int(sys.argv[3]) #15
nburn = int(sys.argv[4]) #5

#clus_chain = []
rho_chain = []
sig_2_chain = []
clus_chain = np.zeros((niter-nburn, n), dtype=int)

#%%time

# MCMC #
for i in range(niter):

    print("\r{0} / {1}".format(i+1, niter), flush=True, end=" ")

    clus_allocs, rho_h, sig_2_h = run_one_gibbs(y, clus_allocs, coords, rho_h, sig_2_h, M, a)
    #print(i)
    #print("Cluster allocations: ")
    #print(clus_allocs)
    #print("Rho_h: ")
    #print(rho_h)
    #print("Sigma_2_h: ")
    #print(sig_2_h)
    #print("__________________________________________________________________________________________")

    if i >= nburn:
        #clus_chain.append(clus_allocs)
        clus_chain[i-nburn] = clus_allocs
        rho_chain.append(rho_h)
        sig_2_chain.append(sig_2_h)
print()
# Salvataggio file

pd.DataFrame(clus_chain).to_csv(f'output_data/clus_chain_M_{M}_a_{int(a)}.csv')

# distribution of the number of cluster
nclus_chain = np.zeros((niter-nburn), dtype=int)
for i in range(niter-nburn):
    nclus_chain[i] = np.max(clus_chain[i]) + 1
x_graph, y_graph = np.unique(nclus_chain, return_counts=True)
plt.figure(figsize=(16,9))
plt.bar(x_graph, y_graph)
plt.xticks(x_graph)
plt.xlabel("Number of clusters", size=16)
plt.title("Barplot of the number of clusters", size=20, weight='bold')

plt.savefig(f'output_plot/n_clus_M_{M}_a_{int(a)}.svg')



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

plt.savefig(f'output_plot/time_series_it_M_{M}_a_{int(a)}.svg')
