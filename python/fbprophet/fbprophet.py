import numpy as np
import fbprophet
import pandas as pd
import matplotlib.pyplot as plt
import datascroller as scroller
import sys
import os
import statsmodels
import generate_time_series as gts

# Import time series generating functions
#sys.path.append("/Users/aaronpickering/Desktop/rnn/py/")

# Load the sample data
sample_data = pd.read_csv("./data/sample_data_1.csv")
#  Rename columns to prophet format
sample_data.columns = ['ds','media','y']
#  Convert the date object to datetime
sample_data['ds'] = pd.to_datetime(sample_data['ds'])

sample_data['media_lag_1'] = sample_data['media'].shift(1)

# Split into training and test sets
train_indices = np.where(~(sample_data['y'].isnull()))[-1]
test_indices = np.where(sample_data['y'].isnull())[-1]

train = sample_data.iloc[train_indices,:]
test = sample_data.iloc[test_indices,:]

#-------- Exploratory analysis
# Plot the sample Sales over time

plt.plot(sample_data['ds'],sample_data['y'])
plt.xlabel("Date")
plt.ylabel("Sales")
plt.show()


# Non-stationarity tests (ADF, KPSS) - eyeball it to start with
# ACF - Clearly autocorrelation
acf_values = statsmodels.tsa.stattools.acf(train['y'])
plt.plot(acf_values)
plt.show()
# PACF
acf_values = statsmodels.tsa.stattools.pacf(train['y'])
plt.plot(acf_values)
plt.show()

# Trend, seasonality remainder.
# What is happening in January 2020?
# Media Cross correlation
statsmodels.tsa.stattools.ccf(train['media'], train['y'])


# Calculate the errors - Error (MAPE?)

# Start with a default prophet model
prophet_model = fbprophet.Prophet()
prophet_model.fit(train)


future = prophet_model.make_future_dataframe(periods=60)
future.tail()

# Check the fit
fit = prophet_model.predict(train)

# Plot the forecast
fit_plot = prophet_model.plot(fit)
fit_plot.show()

y_f =  prophet_model.predict(test)
forecast_plot = prophet_model.plot(y_f)
forecast_plot.show()

# Plot the fit components
comp_plot = prophet_model.plot_components(fit)
comp_plot.show()

# Add the external regressor (Media) and retrain
prophet_model = fbprophet.Prophet()
prophet_model.add_regressor("media")
prophet_model.fit(train)

fit_x = prophet_model.predict(train)

# Plot the new fit
fit_plot = prophet_model.plot(fit_x)
fit_plot.show()

# Lets look  at the changepoint detection
fit_plot = prophet_model.plot(fit_x)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_x)
fit_plot.show()

#  This plot shows that Prophet is detecting a liner structure after 2020-01, but before we have an unusual combination of piecewise linear terms
#  This suggests to me that we are probably  overfitting still missing something at around 2020-01.
#  Lets  look at the residuals over time to double check.

res = train['y'] - fit_x['yhat']
plt.plot(train['ds'], res)
plt.show()

# Play around with change point prior
prophet_model = fbprophet.Prophet(changepoint_prior_scale=0.2)
prophet_model.add_regressor("media")
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()

#  Seems to be a discontinuity at 2020-01.  Lets specifiy a change point at 2020-01 and assume liner otherwise.
prophet_model = fbprophet.Prophet(changepoints=["2020-01-01","2020-01-25"])
prophet_model.add_regressor("media")
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()

# Plot the residuals again
res = train['y'] - fit_xc['yhat']
plt.plot(train['ds'], res)
plt.show()

# The change is still not really picked up as seen  by the residuals. Add a dummy variable for the changepoint
struct_break = np.where(train['ds'] ==  "2020-01-31")
struct_break = np.concatenate([np.repeat(0, struct_break[-1]), np.repeat(1, train.shape[0] - struct_break[-1])])

train['struct_break'] = struct_break

# plot the dummy variable
plt.plot(train['y'])
plt.plot(train['struct_break'])
plt.show()

# Add  the regressor and retrain
prophet_model = fbprophet.Prophet(seasonality_mode="multiplicative", changepoints=[])
prophet_model.add_regressor("media")
prophet_model.add_regressor("struct_break")
prophet_model.add_regressor("media_lag_1")
prophet_model.add_seasonality('yearly', period=365.25, fourier_order=6, mode='multiplicative')
train = train.dropna()
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()



# Plot the residuals again
res = train['y'] - fit_xc['yhat']
plt.plot(res)
plt.show()
plt.hist(res)
plt.show()

# Plot the fit components
comp_plot = prophet_model.plot_components(fit_xc)
comp_plot.show()

# Add a new variable for the 'struct break' in the  test set.
test['struct_break'] = 1

# Create the forecasts and plot
forecast = prophet_model.predict(test)
plt.plot(forecast['yhat'].dropna())
plt.show()
















# Try prophet default on an AR type time series
# Prophet trends the trend as a completely deterministic (but unexplained) piecewise linear function.
# This would appear to be suitable for the situation where the majority of the variation is caused by external regressors
# Consider the structure of the time series, if there is autocorrelation you might need to add lagged regressors.
y_arima = gts.generate_arima_walk(1, 200, alpha=0.6)

plt.plot(y_arima)
plt.show()

ds = np.arange(1, y_arima.shape[0] + 1)

df = pd.concat([pd.Series(y_arima), pd.Series(ds)], axis=1)
df.columns = ['y','ds']


df['ds'] = pd.to_datetime(df['ds'])
df['y_1'] = df['y'].shift(1)
df['y_1'][0] = 0

arima_model = fbprophet.Prophet()
arima_model.add_regressor('y_1')
arima_model.fit(df)

forecast = arima_model.predict(df)


plt.plot(forecast['yhat'])
plt.plot(df['y'])
plt.show()
