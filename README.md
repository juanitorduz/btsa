# Berlin Time Series Analysis (BTSA) Repository

This repository contains resources of the *Berlin Time Series Analysis* meetup.

---
## Conda Environment (Python)

- [Create conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html):

  `conda create -n btsa python=3.7`

- Activate conda environment:

  `conda activate btsa`

  - Install packages:

  `pip install -r requirements.txt`

- Run [Jupyter Lab](https://jupyterlab.readthedocs.io/en/stable/index.html#):

  `jupyter lab`

  ---
## Docker (see [jupyter-docker-stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)) 

- Build Docker image:
  
  `docker build -t docker-btsa .`

- Run container

  `docker run -p 8888:8888 docker-btsa`

> Visiting `http://<hostname>:8888/?token=<token>` in a browser loads the Jupyter Notebook dashboard page, where `hostname` is the name of the computer running docker and `token` is the secret token printed in the console.