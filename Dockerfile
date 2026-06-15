FROM jupyter/base-notebook:latest

USER root

# Instalar Maxima y dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    maxima \
    sbcl \
    curl \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instalar Quicklisp
RUN curl -o /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --non-interactive --load /tmp/quicklisp.lisp \
    --eval "(quicklisp-quickstart:install)" \
    --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    rm /tmp/quicklisp.lisp

# Cambiar al usuario jovyan
USER ${NB_USER}

# Clonar maxima-jupyter
RUN cd /tmp && \
    git clone https://github.com/robert-dodier/maxima-jupyter.git

# Crear script de instalación de Maxima
RUN echo 'load("/tmp/maxima-jupyter/load-maxima-jupyter.lisp");' > /tmp/install-maxima-jupyter.maxima && \
    echo 'jupyter_install();' >> /tmp/install-maxima-jupyter.maxima

# Ejecutar el script de instalación
RUN maxima --very-quiet -r "batch(\"/tmp/install-maxima-jupyter.maxima\");"

# Limpiar archivos temporales
RUN rm -rf /tmp/maxima-jupyter /tmp/install-maxima-jupyter.maxima

# Instalar JupyterLab
RUN pip install jupyterlab

# Configurar el comando de inicio
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
