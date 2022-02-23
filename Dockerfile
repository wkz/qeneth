FROM ubuntu:21.10

#COPY CFG-Vault .
#  Installs all dependances 
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
    
    
# Adding tmux
RUN pip3 install web.py 
RUN pip3 install graphviz

# needs the rikght 
#RUN wget https://github.com/westermo/netbox/blob/master/doc/igmp-seminar/topology.dot.in

COPY qeneth .

COPY topology.dot.in .

COPY /web /web

COPY qeneth-complete.sh .

COPY /templates /templates


CMD ./qeneth generate && ./qeneth start && ./qeneth web 

