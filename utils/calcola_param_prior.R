calcola_param_prior = function(data)
  # data è una matrice di timeseries (ogni riga è una timeseries)
{
  p = nrow(data)
  data = t(data)
  fitted_models_AR1 = vector(mode="list",length = p)
  coefficienti_AR = matrix(0,nrow = p, ncol = 1)
  sigma_2_i = rep(0,p)
  
  for(i in 1:p)
  {
    fitted_models_AR1[[i]] = arima(data[,i], order = c(1,0,0), include.mean = FALSE)
    coefficienti_AR[i,] = fitted_models_AR1[[i]]$coef
    sigma_2_i[i] = fitted_models_AR1[[i]]$sigma2
  }
  
  # stimo i parametri delle prior
  ### rho_h ~ N(rho_0, sigma_2_h / lambda )
  rho_0 = mean(coefficienti_AR)
  sigma_2_avg = mean(sigma_2_i)
  var_rho_h = var(coefficienti_AR)
  lambda = (sigma_2_avg/var_rho_h)[1,1]
  alpha = (sigma_2_avg)^2 / var(sigma_2_i) + 2
  beta = (alpha-1)*sigma_2_avg
  
  parametri = list(rho_0 = rho_0,
                   lambda = lambda,
                   alpha = alpha,
                   beta = beta)
  
  return(list(coefficienti = coefficienti_AR[,1],
              parametri = parametri))
}