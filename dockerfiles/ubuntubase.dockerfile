FROM ubuntu:18.04
RUN apt update
RUN apt upgrade -y
RUN apt install sudo curl git zsh -y
RUN chsh -s $(which zsh)
RUN curl -L http://install.ohmyz.sh | sh

# Optional - Install node

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN cd /root && mkdir .nvm && touch /root/.nvm/test.txt
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 12.16.1

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH
