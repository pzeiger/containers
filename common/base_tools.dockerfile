# Base development tools module
RUN apt-get update && apt-get full-upgrade -y && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget

USER ubuntu
WORKDIR /home/ubuntu
