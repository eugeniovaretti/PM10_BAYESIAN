ts_imputation = function(num_vector)
# use only if the missing values are the last values
{
  library(forecast)
  n_na = sum(is.na(num_vector))
  num_vector_no_na = na.omit(num_vector)
  arima_model = auto.arima(num_vector_no_na)
  predicted_values = forecast(arima_model, h = n_na)$mean
  predicted_values = as.numeric(predicted_values)
  return(c(num_vector_no_na,predicted_values))
}