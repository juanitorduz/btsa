library("dplyr")
library("lubridate")
library("magrittr")
library("janitor")
library("ggplot2")
library("here")

#Set the working directory
setwd(here())

# Read the weather data
weather = read.csv("../data/basel_weather.csv")

# Clean the column names
#   This function removes special characters, spaces etc
weather %<>%
    janitor::clean_names()

colnames(weather)[2] = "temperature"

# Create various date variables and add them to the dataframe
weather %<>%
  mutate_at(vars(timestamp), as.character) %>%
  mutate(date = as.Date(substr(timestamp, 1 ,8 ), format="%Y%m%d")) %>%
  mutate(year = lubridate::year(date)) %>%
  mutate(month = lubridate::month(date)) %>%
  mutate(day = lubridate::day(date)) %>%
  mutate(day_of_year = lubridate::yday(date))

extract_hour = function(timestamp){
  t = substr(timestamp, 10, 11)
  as.numeric(t)
}

weather %<>%
  mutate(hour = extract_hour(timestamp))

# Plot the hourly temperature over time
ggplot(weather) +
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  ggtitle("Basel Temperature (Hourly)") + 
  xlab("Date") + 
  ylab("Temperature (deg C)")

# Plot the daily temperature over time
daily_df = weather %>%
              group_by(date, day) %>%
              summarise(temperature = mean(temperature),
                        day_of_year = unique(day_of_year))

ggplot(daily_df) +
  geom_line(mapping=aes(x=date, y=temperature), col="darkblue") + 
  ggtitle("Basel Temperature (Daily)") + 
  xlab("Date") + 
  ylab("Temperature (deg C)")


# Visualise the seasonality using a cyclical transformation and a spider plot.
ggplot(daily_df) + 
  geom_line(mapping=aes(x=day_of_year, y=temperature), col="blue") +
  coord_polar()
  
# Create a function for calculating the moving average
moving_average = function(x, k = 14){
  x_smooth = rep(NA, length(x))
  for (i in (k+1):length(x)){
    x_smooth[i] = mean(x[(i - k):i])
  }
  return(x_smooth)
}

daily_df$temp_smooth_ma_7 = moving_average(daily_df$temperature, k=7)
daily_df$temp_smooth_ma_14 = moving_average(daily_df$temperature, k=14)
daily_df$temp_smooth_ma_365 = moving_average(daily_df$temperature, k=365)

# Plot the Smoothed Moving Average variables
ggplot(daily_df) + 
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  geom_line(mapping=aes(x=date, y=temp_smooth_ma_7), col="darkred")

ggplot(daily_df) + 
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  geom_line(mapping=aes(x=date, y=temp_smooth_ma_14), col="darkred")

ggplot(daily_df) + 
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  geom_line(mapping=aes(x=date, y=temp_smooth_ma_365), col="darkred")



# Apply a gaussian filters as smoothers
daily_df$temp_gf_30 = ksmooth(x=daily_df$date, y=daily_df$temperature, bandwidth = 30, kernel="normal")$y
daily_df$temp_gf_90 = ksmooth(x=daily_df$date, y=daily_df$temperature, bandwidth = 90, kernel="normal")$y


ggplot(daily_df) + 
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  geom_line(mapping=aes(x=date, y=temp_gf_30), col="darkred")

ggplot(daily_df) + 
  geom_line(mapping=aes(x=date, y=temperature), col="blue") + 
  geom_line(mapping=aes(x=date, y=temp_gf_90), col="darkred")
