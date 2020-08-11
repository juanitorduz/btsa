import numpy as np

def generate_arima_walk(batch_size, n_steps, alpha=0.7, noise=0.1, ma_component=True):

    y = np.zeros([n_steps], dtype=float)

    # Loop through the empty array and add random noise to the dataset. Make the dataset stationary with alpha=0.1
    for i in range(1,len(y)):
        y[i] = y[i-1]*alpha + np.random.normal(0,noise,1)
    return y


def create_impulse_series(y, impulse):
    # Convolve
    y_convolved = np.convolve(y, impulse, mode="full")
    # Clip the end
    y_convolved = y_convolved[:len(y)]
    return y_convolved


def straight_line(n_steps, gradient, intercept):
    t = np.arange(0,n_steps)
    y = gradient*t + intercept
    return y