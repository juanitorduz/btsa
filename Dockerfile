# Choose your desired base image
FROM jupyter/minimal-notebook:latest

USER root

# name your environment and choose python 3.x version
ARG conda_env=btsa

# use a YAML file present in the docker build context
COPY environment.yml /home/$NB_USER/tmp/
RUN cd /home/$NB_USER/tmp/ && \
    conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
    conda clean --all -f -y

# create Python 3.x environment and link it to jupyter
RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
# prepend conda environment to path
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# If you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

COPY data /home/$NB_USER/work/data
COPY python /home/$NB_USER/work/python