import numpy as np
import fbprophet
import pandas as pd
import matplotlib.pyplot as plt
import datascroller as scroller
import sys
import os
import statsmodels.tsa.stattools as sm
import generate_time_series as gts

# Import time series generating functions
#sys.path.append("/Users/aaronpickering/Desktop/rnn/py/")

# Load the sample data
sample_data = pd.read_csv("./data/sample_data_1.csv")
#  Rename columns to prophet format
sample_data.columns = ['ds','media','y']
#  Convert the date object to datetime
sample_data['ds'] = pd.to_datetime(sample_data['ds'])

# Add a media variable at lag 1 and 2
sample_data['media_lag_1'] = sample_data['media'].shift(1)
sample_data['media_lag_2'] = sample_data['media'].shift(2)

# Add a 31 day lag variable
sample_data['y_lag_31'] = sample_data['y'].shift(31)

# Fill NA values with zeroes
sample_data.loc[0,'media_lag_1'] = 0
sample_data.loc[0:1,'media_lag_2'] = 0

# Fill the y_lag_31 values with the first genuine data point
sample_data.loc[0:30,'y_lag_31'] = 6.258472

# Add a 7th of July dummy to account for the negative spike
sample_data['seven_seven'] = sample_data['ds'].isin(["2018-07-07","2019-07-07","2020-07-07","2021-07-07"])
sample_data['seven_seven'] = sample_data['seven_seven'].astype(int)

# Add the structure break variable to the dataset
struct_break = np.where(sample_data['ds'] ==  "2020-01-31")
struct_break = np.concatenate([np.repeat(0, struct_break[-1]), np.repeat(1, sample_data.shape[0] - struct_break[-1])])
sample_data['struct_break'] = struct_break

# Split into training and test sets
train_indices = np.where(~(sample_data['y'].isnull()))[-1]
test_indices = np.where(sample_data['y'].isnull())[-1]

train = sample_data.iloc[train_indices,:]
test = sample_data.iloc[test_indices,:]

# Drop the na values from the lagged terms
train = train.dropna()


#-------- Exploratory analysis
# Plot the sample Sales over time

plt.plot(sample_data['ds'],sample_data['y'])
plt.xlabel("Date")
plt.ylabel("Sales")
plt.show()


# Non-stationarity tests (ADF, KPSS) - eyeball it to start with
# ACF - Clearly autocorrelation
acf_values = sm.acf(train['y'])
plt.plot(acf_values)
plt.show()
# PACF
acf_values = sm.pacf(train['y'])
plt.plot(acf_values)
plt.show()

# Trend, seasonality remainder.
# What is happening in January 2020?
# Media Cross correlation (after removing seasonality)
sm.ccf(train['media'], train['y'])


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

# Add the external regressor (Media) and retrain. Disable weekly seasonality.
prophet_model = fbprophet.Prophet(weekly_seasonality=False)
prophet_model.add_regressor("media")
prophet_model.fit(train)

fit_x = prophet_model.predict(train)

# Plot the new fit
fit_plot = prophet_model.plot(fit_x)
fit_plot.show()

plt.plot(train['y'])
plt.plot(fit_x['yhat'])
plt.show()


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
prophet_model = fbprophet.Prophet(changepoint_prior_scale=0.2, weekly_seasonality=False)
prophet_model.add_regressor("media")
prophet_model.add_regressor("media_lag_1")
prophet_model.add_regressor("media_lag_2")
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()

#  Seems to be a discontinuity at 2020-01.  Lets specifiy a change point at 2020-01 and assume liner otherwise.
prophet_model = fbprophet.Prophet(changepoints=["2019-12-15","2020-03-01"], weekly_seasonality=False)
prophet_model.add_seasonality("yearly", period=365.25, fourier_order=12, mode="multiplicative")
prophet_model.add_regressor("struct_break")
prophet_model.add_regressor("media")
prophet_model.add_regressor("media_lag_1")
prophet_model.add_regressor("media_lag_2")
prophet_model.add_regressor("media_lag_1")
prophet_model.add_regressor("seven_seven")
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()

prophet_model.plot_components(fit_xc)
plt.show()
plt.plot(fit_xc['multiplicative_terms'])
plt.show()

# Plot the residuals again
res = train['y'] - fit_xc['yhat']
plt.plot(train['ds'], res)
plt.show()

# The change is still not really picked up as seen  by the residuals. Add a dummy variable for the changepoint


# plot the dummy variable
plt.plot(train['y'])
plt.plot(train['struct_break'])
plt.show()

# Add  the regressor and retrain
prophet_model = fbprophet.Prophet(seasonality_mode="multiplicative", changepoints=[])
prophet_model.add_regressor("media")
prophet_model.add_regressor("struct_break")
prophet_model.add_regressor("media_lag_1")
prophet_model.add_regressor("y_lag_31")
prophet_model.add_seasonality('yearly', period=365.25, fourier_order=12, mode='multiplicative')
prophet_model.add_seasonality('yearly', period=365.25, fourier_order=12, mode='additive')
train = train.dropna()
fit_xc = prophet_model.fit(train)

fit_xc = fit_xc.predict(train)
fit_plot = prophet_model.plot(fit_xc)
a = fbprophet.plot.add_changepoints_to_plot(fit_plot.gca(), prophet_model, fit_xc)
fit_plot.show()

fig1 = prophet_model.plot_components(fit_xc)
fig1.show()


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
