![Build](https://github.com/juanitorduz/btsa/workflows/Docker%20Build/badge.svg)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/juanitorduz/btsa/master)
[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/juanitorduz/btsa)

# Berlin Time Series Analysis (BTSA) Repository

This repository contains resources of the *Berlin Time Series Analysis* [Meetup](https://www.meetup.com/Berlin-Time-Series-Analysis-Meetup/). We encourage everyone to [contribute to this repository](https://github.com/juanitorduz/btsa/blob/master/CONTRIBUTING.md)! [Here](https://github.com/juanitorduz/btsa/blob/master/meetup.md) you can find the schedule and details of the meetup.

<img src="python/fundamentals/images/basel_daily_gf.png">

**contact:** [berlin.timeseries.analysis@gmail.com](berlin.timeseries.analysis@gmail.com)

---
## Code of Conduct 
**Important:** Make sure you read the [Code of Conduct](https://github.com/juanitorduz/btsa/blob/master/code_of_conduct.md). 

---
## Resources 

You can find a list of references on the [resources](https://github.com/juanitorduz/btsa/blob/master/resources.md) section (which we will continuously update).

---
## Environment  

As we want to make the code reproducible, here are some options to manage dependencies (choose R or Python as preferred):

### Conda Environment (Python)

- [Create conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) (you can also update the environment from as described [here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#updating-an-environment)):

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

You can find the `python` folder under the `work` directory.

---
### [R](https://www.r-project.org/) [Environment](https://rstudio.github.io/renv/articles/renv.html)

- From the root (`btsa`) directory, with R installed, run the following command: `Rscript renv/activate.R`.

This command will activate the environment and the [renv package manager](https://github.com/rstudio/renv/). From there you have two options depending on how you like to edit your projects.

*Note: This configuration has been tested on R version 3.6.3.*

#### Option 1. Command Line:
From the root directory type R and hit enter. Then type `renv::restore()` and respond with 'y' when prompted to install the packages. Your environment is now set up. You can continue writing commands or quit the console, your folder is now set up with the required packages.

#### Option 2: From [RStudio](https://rstudio.com/)
Open an Rstudio session. Go to `RStudio > 'Open Project in New Session'`. Navigate to the btsa folder and click open.
In the console, type `renv::restore()` to install the necessary packages. Your RStudio session is now configured.
