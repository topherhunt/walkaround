# Proof-of-concept Docker image with `ffmpeg` installed.
#
# To build it:
# - cd to this folder
# > docker build -t docker-ffmpeg .
#
# To run it:
# > docker run --rm -v /path/to/your/images:/data docker-ffmpeg ffmpeg -i input.jpg output.webp
# > docker run --rm -v ~/Desktop:/data docker-ffmpeg ffmpeg -i Sahar.jpg Sahar.webp

FROM ubuntu:latest

RUN apt-get update && \
  apt-get install -y ffmpeg

WORKDIR /data
