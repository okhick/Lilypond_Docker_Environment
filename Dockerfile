FROM ubuntu:bionic
LABEL version="1.0"
LABEL description="Custom enviroment for lilypond engraving"
LABEL author="Oliver Hickman <okhick@gmail.com>"

RUN apt-get update && \
  apt-get -y install sudo

#install node
RUN apt-get -y install curl gnupg wget
RUN curl -sL https://deb.nodesource.com/setup_12.x  | bash -
RUN apt-get -y install nodejs
RUN npm install -g onchange

# add user
RUN adduser --disabled-password --gecos '' lily
RUN adduser lily sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER lily
RUN cd /home/lily

# install lilypond
# download the installers
RUN mkdir /home/lily/installers \
  && cd /home/lily/installers \
  && wget http://lilypond.org/download/binaries/linux-64/lilypond-2.18.2-1.linux-64.sh \
  && wget http://lilypond.org/download/binaries/linux-64/lilypond-2.19.83-1.linux-64.sh

# install 2.18
RUN mkdir /home/lily/.bin /home/lily/.bin/lilypond_2.18 /home/lily/.bin/lilypond_2.19
RUN cd /home/lily/installers \
  && sudo chmod 777 lilypond-2.18.2-1.linux-64.sh \
  && sh lilypond-2.18.2-1.linux-64.sh --prefix /home/lily/.bin/lilypond_2.18
# setup shell script to more easily run each version
COPY ./shell/lilypond-2.18.sh /home/lily/
RUN sudo chmod 777 /home/lily/lilypond-2.18.sh

# repeat above for 2.19
RUN cd /home/lily/installers \
  && sudo chmod 777 lilypond-2.19.83-1.linux-64.sh \
  && sh lilypond-2.19.83-1.linux-64.sh --prefix /home/lily/.bin/lilypond_2.19
COPY ./shell/lilypond-2.19.sh /home/lily/
RUN sudo chmod 777 /home/lily/lilypond-2.19.sh

# clean up install
RUN rm -rfv /home/lily/installers

# install my fonts
RUN sudo apt-get -y install fontconfig
RUN mkdir /home/lily/.fonts
COPY fonts/lora/ /home/lily/.fonts/lora/
COPY fonts/lato/ /home/lily/.fonts/lato/
COPY fonts/bravura/ /home/lily/.fonts/bravura/
RUN fc-cache -f -v