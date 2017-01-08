FROM jupyter/notebook:latest

RUN apt-get update
RUN apt-get install -y python3-numpy python3-scipy python3-matplotlib ipython ipython3-notebook python3-pandas python3-nose
RUN pip3 install sympy xlrd

ENV RISE_COMMIT 60c7efb2a3a57b9a90263aecac02014f4aae8c36
RUN (git clone https://github.com/flaxandteal/RISE && cd RISE && git checkout ${RISE_COMMIT} && python3 setup.py install && cd .. && rm -rf RISE)

ENV JUPYTER_THEMER_COMMIT 209aa663e183837f2593c79ad2dc5f244c3a549d
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themer.git@${JUPYTER_THEMER_COMMIT}

ENV JUPYTER_THEMES_COMMIT 425f403a246d3366b649f29a9bd23b97e390cf7b
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themes.git@${JUPYTER_THEMES_COMMIT}

RUN apt-get install -y python3-yaml
RUN pip3 install bokeh Quandl
# TODO clean the apt update in one line
