FROM calyau/maxima-jupyter:latest

USER root
RUN pip install jupyterlab

USER jovyan
