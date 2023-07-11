FROM quay.io/redhatgov/workshop-dashboard:latest

USER root

# install aws2
RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip && \
    unzip ./awscli-exe-linux-x86_64-2.0.30.zip && \
    rm ./awscli-exe-linux-x86_64-2.0.30.zip && \
    ./aws/install && \
    rm -rf ./aws

# install stern
RUN wget https://github.com/stern/stern/releases/download/v1.25.0/stern_1.25.0_linux_amd64.tar.gz && \
    tar -xf ./stern_1.25.0_linux_amd64.tar.gz && \
    mv ./stern /usr/local/bin && \
    rm ./stern_1.25.0_linux_amd64.tar.gz && \
    chown 1001 /usr/local/bin/stern && \
    chmod 550 /usr/local/bin/stern

# install kn
RUN wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/1.8.1/kn-linux-amd64.tar.gz && \
    tar -xf ./kn-linux-amd64.tar.gz -C /usr/local/bin && \
    mv /usr/local/bin/kn-linux-amd64 /usr/local/bin/kn && \
    rm kn-linux-amd64.tar.gz && \
    chown 1001 /usr/local/bin/kn && \
    chmod 550 /usr/local/bin/kn

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

ENV TERMINAL_TAB=split

USER 1001

RUN /usr/libexec/s2i/assemble
