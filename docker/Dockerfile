FROM cimg/python:3.7.7


RUN \
  sudo apt-get update && sudo apt-get install -y software-properties-common && \
  sudo wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add - && \
  sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
  sudo apt-get update && sudo apt-get install -y adoptopenjdk-8-hotspot

