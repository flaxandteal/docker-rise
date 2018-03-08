FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update
RUN apt-get install -y python3-numpy python3-scipy python3-matplotlib ipython ipython3-notebook python3-pandas python3-nose \
    python3-yaml python3-pip git libffi-dev libssl-dev yarn nodejs
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

RUN pip3 install jupyter

ENV RISE_COMMIT fa1cf91c3e34b373404c740e1c06f3b83f08290d
RUN (git clone https://github.com/flaxandteal/rise && cd rise && git checkout ${RISE_COMMIT})

WORKDIR /rise
RUN yarn install && yarn run build-reveal && yarn run reset-reveal && yarn run build-css
RUN (python3 setup.py install && cd .. && rm -rf RISE)

RUN jupyter-nbextension install rise --py --sys-prefix && \
    jupyter-nbextension enable rise --py --sys-prefix

ENV JUPYTER_THEMER_COMMIT 209aa663e183837f2593c79ad2dc5f244c3a549d
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themer.git@${JUPYTER_THEMER_COMMIT}

ENV JUPYTER_THEMES_COMMIT 425f403a246d3366b649f29a9bd23b97e390cf7b
RUN pip3 install git+git://github.com/flaxandteal/jupyter-themes.git@${JUPYTER_THEMES_COMMIT}

RUN pip3 install sympy xlrd bokeh Quandl seaborn scikit-learn pandas geopandas shapely folium

RUN useradd -ms /bin/bash jupyter

VOLUME /notebooks
RUN chown -R jupyter /notebooks

USER jupyter

RUN mkdir -p -m 700 /home/jupyter/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /home/jupyter/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /home/jupyter/.jupyter/jupyter_notebook_config.py

WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser"]
# TODO clean the apt update in one line
