ARG base=max-one.local:5001/jetson/ml-base
FROM ${base}

MAINTAINER Helmut Hoffer von Ankershoffen <helmuthva@googlemail.com>

# Install Jupyter
RUN conda install -y jupyter && \
    conda install -y ipywidgets
RUN pip uninstall -y tornado && \
    pip uninstall -y nbconvert
RUN pip install tornado==4.2
RUN pip install nbconvert==5.3.1

# Install packages for data science
RUN conda install -y seaborn

# Install Matlab clone Octave as alternative Jupyter kernel
RUN apt-get update && \
    apt-get install -y \
    octave \
    octave-optim \
    gnuplot \
    && \
    apt-get clean
RUN conda install -y octave_kernel && \
    conda install -y texinfo

# Inject jupyter configuration and initial notebook
COPY jupyter_notebook_config.py /root/.jupyter/
ADD tf-tutorials.tgz /notebook
WORKDIR "/notebook"
CMD ["jupyter", "notebook", "--allow-root", "--no-browser" ]

# Expose jupyter and tensorboard
EXPOSE 8888
EXPOSE 6006
