FROM jupyter/base-notebook:latest

USER root

# Instalar Maxima desde los repositorios de Ubuntu
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    maxima \
    sbcl \
    curl \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instalar Quicklisp (gestor de paquetes de Common Lisp)
RUN curl -o /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --non-interactive --load /tmp/quicklisp.lisp \
    --eval "(quicklisp-quickstart:install)" \
    --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    rm /tmp/quicklisp.lisp

# Cambiar al usuario jovyan
USER ${NB_USER}

# Clonar e instalar maxima-jupyter
RUN cd /tmp && \
    git clone https://github.com/robert-dodier/maxima-jupyter.git && \
    cd maxima-jupyter && \
    maxima --very-quiet --batch-string="load(\"load-maxima-jupyter.lisp\");jupyter_install();" && \
    rm -rf /tmp/maxima-jupyter

# Instalar JupyterLab
RUN pip install jupyterlab

# Configurar el comando de inicio
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
