This repository contains the Docker configuration to build my master's thesis.

It's essentially an Ubuntu image with TeXLive, biber, and R.

# What's in it?

The image starts from Ubuntu.  I tried Alpine, too frustrating.

I install all of TeXLive -- and biber too, which I use for bibliographies.  I chose XeLaTeX over pdflatex because Unicode.

I also install the R language, which I use for statistics.

# Quick guide

To build the image:
`$ docker build -t mathuin/thesis .`

To debug the image:
`$ docker run --rm -it --entrypoint=/bin/bash -v ${PWD}:/data mathuin/thesis`

Note that this command assumes that the command is being executed from the top level of my thesis.
