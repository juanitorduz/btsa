import numpy as np
import fbprophet
import pandas as pd
import matplotlib.pyplot as plt
import datascroller as scroller
import sys
import generate_time_series as gts

# Import time series generating functions
sys.path.append("/Users/aaronpickering/Desktop/rnn/py/")

basel_weather = pd.read_csv("./data/basel_weather.csv")
basel_weather.columns = ['ds','y','rain','wind','wind_direction']
basel_weather['ds'] = pd.to_datetime(basel_weather['ds'])

plt.plot(basel_weather['y'])
plt.show()

prophet_model = fbprophet.Prophet()
prophet_model.fit(basel_weather)

#future = prophet_model.make_future_dataframe(periods=365)
#future.tail()
forecast = prophet_model.predict(basel_weather)

# Plot the forecast
fig1 = prophet_model.plot(forecast)
fig1.show()


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