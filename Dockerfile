FROM ubuntu:21.10

COPY ./ /home/

WORKDIR /home/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt -y install \
    e2fsprogs graphviz \
    ruby-mustache \
    squashfs-tools \
    qemu-system-x86 \
    qemu-utils \
    python3  \
    python3-pip \
    wget \
    net-tools
    
    
RUN pip3 install web.py 
RUN pip3 install graphviz

CMD ./qeneth generate && ./qeneth start && ./qeneth web 

