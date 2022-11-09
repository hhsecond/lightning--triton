FROM nvcr.io/nvidia/tritonserver:22.10-py3

RUN apt-get update && apt-get install sudo

# Adding dump-init to the image
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /bin/dumb-init
RUN chmod +x /bin/dumb-init

# Create user "triton-server" with sudo powers
RUN userdel triton-server && useradd -ms /bin/bash -u 1000 -G sudo triton-server && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'APT::Get::Assume-Yes "true";' | sudo tee -a /etc/apt/apt.conf.d/00Do-not-ask && \
    mkdir /home/triton-server/data && \
    cp /root/.bashrc /home/triton-server/ && \
    chown -R --from=root triton-server /home/triton-server
ENV USER triton-server
USER 1000

ENV HOME /home/triton-server
ENV PATH /home/triton-server/.local/bin:$PATH
ENV WORKDIR=/content
# Avoid first use of sudo warning - https://askubuntu.com/a/22614/781671
RUN touch $HOME/.sudo_as_admin_successful

# installing ssh service - this shouldn't be needed
RUN sudo apt-get install openssh-server
RUN pip install lightning redis virtualenv

# Set /content as cwd
WORKDIR ${WORKDIR}
