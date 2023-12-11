# Docker image including the necessary environment to run BehavIoT.

# Base image: Ubuntu 22.04 LTS
FROM ubuntu:22.04

WORKDIR /root

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y tshark
RUN apt-get update && apt-get install -y dnsutils wget git graphviz python3-pip

# Create non-root user
ARG USER=user
ARG UID
ARG GROUP=docker
ARG GID
ARG HOME=/home/${USER}
RUN groupadd --gid ${GID} ${GROUP} && \
    useradd --uid ${UID} --gid ${GID} -m ${USER}
USER ${USER}
WORKDIR ${HOME}

# Install Python packages
RUN pip3 install --no-warn-script-location \
    numpy \
    matplotlib \
    scikit-learn \
    statsmodels \
    networkx \
    pydot \
    jupyter

# Install Java 7
ARG JAVA_HOME=${HOME}/jdk1.7
COPY jdk-7u80-linux-x64.tar.gz ${HOME}/jdk-7u80-linux-x64.tar.gz
RUN tar -xzf jdk-7u80-linux-x64.tar.gz && \
    rm jdk-7u80-linux-x64.tar.gz
RUN mv jdk1.7.0_80 ${JAVA_HOME}
ENV JAVA_HOME=${JAVA_HOME}
ENV PATH=${JAVA_HOME}/bin:${PATH}
# Test Java installation
RUN javac -version

# Install Ant
ARG ANT_HOME=${HOME}/ant1.9
RUN wget https://dlcdn.apache.org//ant/binaries/apache-ant-1.9.16-bin.tar.gz
RUN tar -xzf apache-ant-1.9.16-bin.tar.gz && \
    rm apache-ant-1.9.16-bin.tar.gz
RUN mv apache-ant-1.9.16 ${ANT_HOME}
ENV ANT_HOME=${ANT_HOME}
ENV PATH=${ANT_HOME}/bin:${PATH}
# Test Ant installation
RUN ant -version

# Install Synoptic
RUN git clone https://github.com/ModelInference/synoptic.git
WORKDIR ${HOME}/synoptic
RUN ant synoptic

# Set working directory to home
WORKDIR ${HOME}

# Run scripts
#CMD ./run_all.sh
