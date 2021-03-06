FROM r-base:3.5.0

# Base packages
RUN apt-get update -q && apt-get install -qy \
  libcurl4-openssl-dev \
  libudunits2-dev \
  curl \
  gnupg \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Config files
RUN echo '#!/bin/bash\n\
source /root/.bashrc\n\
if [ "$#" -ne 1 ]; then\n\
    "$@"\n\
else\n\
    make clean thesis.pdf\n\
fi' > /root/docker-entrypoint.sh
RUN chmod +x /root/docker-entrypoint.sh

RUN echo '#!/bin/bash\n\
chown --reference=/data -R /data\n\
' > /root/cleanup.sh
RUN chmod +x /root/cleanup.sh

RUN echo 'trap /root/cleanup.sh EXIT\n\
' > /root/.bashrc
RUN chmod +x /root/.bashrc

ENV R_LIBS="/root/R_libs"
RUN mkdir -p $R_LIBS

# R packages
RUN Rscript -e 'install.packages(c("knitr", "tinytex", "tidyr", "dplyr", "ggplot2", "ggforce", "ggrepel", "cowplot", "readr", "xtable", "tikzDevice", "candisc", "broom", "multcompView"), repos="http://cran.rstudio.com/", clean=TRUE)'

# TeX Live
COPY ./small.profile /tmp/
RUN mkdir -p /tmp/texlive \
  && curl -SL http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
  | tar -xzC /tmp/texlive \
  && /tmp/texlive/install-tl-*/install-tl --profile /tmp/small.profile \
  && rm -rf /tmp/texlive
ENV PATH=/usr/local/texlive/2018/bin/x86_64-linux:$PATH \
    INFOPATH=/usr/local/texlive/2018/texmf-dist/doc/info:$INFOPATH \
    MANPATH=/usr/local/texlive/2018/texmf-dist/doc/man:$MANPATH

# Additional LaTeX packages
RUN tlmgr update -- all && tlmgr install \
  acro \
  adjustbox \
  biber \
  biblatex \
  biblatex-apa \
  biocon \
  chemgreek \
  collectbox \
  csquotes \
  currfile \
  framed \
  gincltex \
  latexmk \
  logreq \
  marginnote \
  mhchem \
  multirow \
  placeins \
  preprint \
  preview \
  standalone \
  siunitx \
  svn-prov \
  translations \
  threeparttable \
  xstring

VOLUME ["/data"]
WORKDIR "/data"

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF
ARG VCS_URL

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="CC BY-SA 4.0" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url=$VCS_URL

ENTRYPOINT ["/root/docker-entrypoint.sh"]
CMD ["/bin/bash"]
