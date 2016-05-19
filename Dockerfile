FROM ubuntu:trusty
MAINTAINER Jack Twilley <twilleyj@lifetime.oregonstate.edu>
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
  biber \
  build-essential \
  latexmk \
  r-base \
  texlive-latex-extra \
  texlive-latex-recommended \
  texlive-science \
  texlive-xetex 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# https://gist.github.com/stevenworthington/3178163
# In R code:
# packages <- c("ggplot2", "plyr", "reshape2", "RColorBrewer", "scales", "grid")
# ipak(packages)
RUN echo 'r = getOption("repos")\n\
r["CRAN"] = "https://cran.bnr.berkeley.edu"\n\
options(repos=r)\n\
rm(r)\n\
ipak <- function(pkg){\n\
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]\n\
    if (length(new.pkg) > 0)\n\
        install.packages(new.pkg, dependencies = TRUE)\n\
    sapply(pkg, require, character.only = TRUE)\n\
}' > ~/.Rprofile
RUN echo '#!/bin/bash\n\
if [ "$#" -ne 1 ]; then\n\
    exec "$@"\n\
else\n\
    exec make realclean thesis.pdf\n\
fi' > /root/docker-entrypoint.sh
RUN chmod +x /root/docker-entrypoint.sh
VOLUME ["/data"]
WORKDIR "/data"
ENTRYPOINT ["/root/docker-entrypoint.sh"]
CMD ["/bin/bash"]
