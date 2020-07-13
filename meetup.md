# Meet Up Schedule 

In this section we want to track the Meet Up contents and information. 

## 02.06.2020 Kick-Off Meeting 

## 07.07.2020 Synthetic control in time series 

**Speaker:** [Sebastian Martinez](https://smartinez.co/)

**Abstract:** Synthetic control is a method for estimating *causal* effects (evaluate the effect of an intervention) in comparative case studies when there is only one treatment unit. The method chooses a set of weights for a group of corresponding units that produces an optimally estimated *counterfactual* to the unit that received the treatment. This unit is referred to as the “synthetic unit” and can be used to outline what would have happened to the treated unit had the treatment never occurred.

## 11.08.2020 Exploring [Facebook Prophet](https://facebook.github.io/prophet/) (Book Club)

<img src="images/sample_data_1_plot.png">

**Moderator:** [Aaron Pickering](https://www.linkedin.com/in/aaron-p-87a139175/)

We want to discuss the capabilities and limitations of Facebook’s forecasting package *Prophet*. We want to work a concrete example:

On the file `data/sample_data_1.csv` you can find (dummy) `sales` data (`2018-01-01` to `2021-06-30`). In addition there is a feature `media` which could be used as an external predictor. The objective is to create a time series forecasting model using [Facebook Prophet](https://facebook.github.io/prophet/). The forecasting window is 30 days. Here are some hints/steps for the challenge: 

1. Do an EDA on the sample data. 
2. Is there any clear seasonality or trend? 
3. Is the feature `media` useful for prediction? 
4. How do you evaluate model performance?
5. Can you estimate model uncertainty (credible intervals)? 

Try to generate predictions for the whole month of *July 2021*. We will provide the "true" values during the meetup so that we can all test our models. Again, this is not a competition, but rather a concrete use case to apply what we learn about Prophet. 

Please bring questions and suggestions to make the best out of this session!
