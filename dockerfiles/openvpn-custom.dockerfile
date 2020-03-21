FROM ubuntu-base:latest

ENV HOME /root
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 12.16.1
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

# Install dependencies
RUN apt install wget openvpn -y

RUN echo "Copying config file..."

# Install EasyRSA
RUN wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
RUN cd /root && tar -xvf EasyRSA-3.0.4.tgz
RUN rm -rf /root/EasyRSA-3.0.4.tgz

COPY ./config/vars /root/EasyRSA-3.0.4/vars
RUN cd ~/EasyRSA-3.0.4/ \
    && ./easyrsa init-pki 

COPY ./config/openssl-easyrsa.cnf /root/EasyRSA-3.0.4/pki/openssl-easyrsa.cnf
RUN cd /root/EasyRSA-3.0.4/ \
    && (echo "megumin-ca" && cat) | ./easyrsa build-ca nopass

# Now we are generating the server certificate
RUN cd ~/EasyRSA-3.0.4/ && (echo "server" && cat) | ./easyrsa gen-req server nopass
RUN cp ~/EasyRSA-3.0.4/pki/private/server.key /etc/openvpn/
RUN cd ~/EasyRSA-3.0.4/ && (echo "yes" && cat) | ./easyrsa sign-req server server

# The key now lives at ~/EasyRSA-3.0.4/pki/issued/server.crt
RUN cp ~/EasyRSA-3.0.4/pki/issued/server.crt /etc/openvpn/ \
    && cp ~/EasyRSA-3.0.4/pki/ca.crt /etc/openvpn/
RUN cd ~/EasyRSA-3.0.4/ && ./easyrsa gen-dh

# Copy the generated keys to OpenVpn
RUN cd ~/EasyRSA-3.0.4/ \
    && openvpn --genkey --secret ta.key \
    && cd ~/EasyRSA-3.0.4/ \
    && cp ~/EasyRSA-3.0.4/ta.key /etc/openvpn/ \
    && cp ~/EasyRSA-3.0.4/pki/dh.pem /etc/openvpn/

# Set up the client keys directory
RUN mkdir -p ~/client-configs/keys

# OPTIONAL - Lock down permissions of client keys directory
RUN chmod -R 700 ~/client-configs

RUN source /root/.bashrc

ENV CACHE_BUSTER 12

# RUN alias create-client="~/EasyRSA-3.0.4/easyrsa gen-req client1 nopass"
# We now have a create-client command to create new clients with.

RUN source /root/.bashrc \
    && . $NVM_DIR/nvm.sh \
    && git clone https://github.com/carl-eis/openvpn-cli /root/openvpn-cli \
    && cd /root/openvpn-cli \
    && npm install
    
# RUN cd /root/openvpn-cli && npm install