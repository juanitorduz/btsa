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

## 08.09.2020 Introduction to sktime : A Unified Interface for Machine Learning with Time Series

**Speaker:** [Markus Löning](https://www.geog.ucl.ac.uk/people/research-students/markus-loning) (PhD Student @UCL)

**Abstract:** We present sktime, a new unified toolbox for machine learning with time series in Python. We provide state-of-the-art time series algorithms and scikit-learn compatible tools for model composition. The goal of sktime is to make the time series analysis ecosystem more usable and interoperable. In this talk, you'll learn about different time series learning tasks, how algorithms for one task can be used to help solve another one, sktime's key design ideas and our plans for the future.

**Resources:**
- MeeUp Code [https://github.com/mloning/intro-to-sktime-berlin-tsa-meetup-2020](https://github.com/mloning/intro-to-sktime-berlin-tsa-meetup-2020)
- GitHub [https://github.com/alan-turing-institute/sktime](https://github.com/alan-turing-institute/sktime)
- Paper [sktime: A Unified Interface for Machine Learning
with Time Series](http://learningsys.org/neurips19/assets/papers/sktime_ml_systems_neurips2019.pdf)

## 13.10.2020 Amazon deepAR (Book Club)

**Moderator:** Korbinian Kuusisto (Co-Founder @ Kineo.ai)

**Abstract:** ... 

**Resources:**
- [DeepAR: Probabilistic forecasting with autoregressive recurrent networks](https://www.sciencedirect.com/science/article/pii/S0169207019301888)

## 03.10.2020 Multi-variate Probabilistic Time Series Forecasting via Conditioned Normalizing Flows

**Speaker:** Kashif Rasul (Research Scientist @[Zalando SE](https://en.zalando.de/?_rfl=de))

**Abstract:** ...

**Resources:**
- ArXiv: [Multi-variate Probabilistic Time Series Forecasting via Conditioned
Normalizing Flows](https://arxiv.org/pdf/2002.06103.pdf)

