FROM cimg/base:2020.05

RUN \
  sudo apt-get update && \
  sudo apt-get install -y openjdk-8-jdk software-properties-common && \
  sudo add-apt-repository ppa:deadsnakes/ppa && \
  sudo apt update && \
  sudo apt install python3.7 && \
  sudo rm -rf /var/lib/apt/lists/*
