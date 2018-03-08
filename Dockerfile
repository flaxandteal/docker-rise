FROM ubuntu:16.04

USER root
RUN apt-get update
RUN apt-get install -y python3-numpy python3-scipy python3-matplotlib ipython ipython3-notebook python3-pandas python3-nose
RUN apt-get install -y python3-yaml python3-pip git
RUN apt-get install -y curl
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

RUN pip3 install sympy xlrd jupyter

ENV RISE_COMMIT 60c7efb2a3a57b9a90263aecac02014f4aae8c36
RUN (git clone https://github.com/flaxandteal/RISE && cd RISE && git checkout ${RISE_COMMIT} && python3 setup.py install && cd .. && rm -rf RISE)

ENV JUPYTER_THEMER_COMMIT 209aa663e183837f2593c79ad2dc5f244c3a549d
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themer.git@${JUPYTER_THEMER_COMMIT}

ENV JUPYTER_THEMES_COMMIT 425f403a246d3366b649f29a9bd23b97e390cf7b
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themes.git@${JUPYTER_THEMES_COMMIT}

RUN apt-get install -y libffi-dev libssl-dev
RUN pip3 install bokeh Quandl

RUN mkdir -p -m 700 /root/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py
RUN pip3 install -vvv seaborn

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser"]
# TODO clean the apt update in one line
