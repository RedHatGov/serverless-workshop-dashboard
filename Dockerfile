FROM quay.io/redhatgov/workshop-dashboard:latest

USER root

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

ENV TERMINAL_TAB=split

USER 1001

# install stern
RUN wget https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64 -O stern && \
    chown 1001 ./stern && \
    chmod 500 ./stern

# install kn
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/serverless/latest/kn-linux-amd64-0.17.3.tar.gz && \
    tar -xf ./kn-linux-amd64-0.17.3.tar.gz && \
    rm kn-linux-amd64-0.17.3.tar.gz && \
    chown 1001 ./kn && \
    chmod 500 ./kn

RUN /usr/libexec/s2i/assemble
