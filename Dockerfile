FROM jupyter/minimal-notebook

LABEL maintainer="Juan Orduz <juanitorduz@gmail.com>"

USER root

# Install from requirements.txt file
COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER