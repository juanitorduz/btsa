# Berlin Time Series Analysis (BTSA) Repository

This repository contains resources of the *Berlin Time Series Analysis* [meetup](https://www.meetup.com/Berlin-Time-Series-Analysis-Meetup/). You can find a list of references on the [resources](https://github.com/juanitorduz/btsa/blob/master/resources.md) section (which we will continuously update).

<img src="python/fundamentals/images/basel_daily_gf.png">


---
## Environment  

As we want to make the code reproducible, here are some options to manage dependencies (choose R or Python as preferred):

### Conda Environment (Python)

- [Create conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html):

  `conda env create -f environment.yml`

- Activate conda environment:

  `conda activate btsa`

- Run [Jupyter Lab](https://jupyterlab.readthedocs.io/en/stable/index.html#):

  `jupyter lab`

  ---
### Docker (see [jupyter-docker-stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)) 

- Build Docker image:
  
  `docker build -t docker-btsa .`

- Run container

  `docker run -p 10000:8888 docker-btsa`

> Visiting `http://<hostname>:10000/?token=<token>` in a browser loads the Jupyter Notebook dashboard page, where `hostname` is the name of the computer running docker and `token` is the secret token printed in the console.

### R Environment

- From the root (btsa) directory, with R installed, run the following command: Rscript renv/activate.R

This command will activate the environment and the renv package manager. From there you have two options depending on how you like to edit your projects.

Note: This configuration has been tested on R version 3.6.3.

##### Option 1. Command Line:
From the root directory type R and hit enter. Then type renv::restore() and respond with 'y' when prompted to install the packages. Your environment is now set up. You can continue writing commands or quit the console, your folder is now set up with the required packages.

##### Option 2: From R-Studio
Open an Rstudio session. Go to R-Studio > 'Open Project in New Session'. Navigate to the btsa folder and click open.
In the console, type renv::restore() to install the necessary packages. Your RStudio session is now configured.
