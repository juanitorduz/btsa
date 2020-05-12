# Berlin Time Series Analysis (BTSA) Repository

This repository contains resources of the *Berlin Time Series Analysis* meetup. You can find a list of references on the [resources](https://github.com/juanitorduz/btsa/blob/master/resources.md) section (which we will continuously update).

---
## Environment  

As we want to make the code reproducible, here are some options to manage dependencies:

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
