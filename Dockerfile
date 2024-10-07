FROM ros:humble-ros-core-jammy
ENV ROS2_WS /workspaces
ENV ROS_DOMAIN_ID=1
ENV ROS_DISTRO=humble
ARG THREADS=4
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

##### Copy Source Code #####
COPY . /tmp

##### Environment Settings #####
WORKDIR /tmp

# Copy the run command for rebuilding colcon. You can source it.
RUN mkdir -p ${ROS2_WS}/src && \
    mv /tmp/rebuild_colcon.rc ${ROS2_WS} && \

    # Entrypoint
    mv /tmp/ros_entrypoint.bash /ros_entrypoint.bash && \
    chmod +x /ros_entrypoint.bash && \

    # System Upgrade
    apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt autoclean -y

    # Necessary System Package Installation
RUN apt install -y \
        axel \
        bash-completion \
        bat \
        bmon \
        build-essential \
        curl \
        git \
        libncurses5-dev \
        libncursesw5-dev \
        lsof \
        nano \
        ncdu \
        nvtop \
        python3-pip \
        python3-venv \
        screen \
        tig \
        tmux \
        tree \
        vim \
        wget

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \

    # Soft Link
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/batcat /usr/bin/bat && \

    # Install oh-my-bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \

    # Use our pre-defined bashrc
    mv /tmp/.bashrc /root && \
    ln -s /root/.bashrc /.bashrc

    ##### ROS2 Installation #####
    # install ros2
RUN apt install -y \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool \
        ros-${ROS_DISTRO}-ros-base \
        # install ros bridge
        ros-${ROS_DISTRO}-rosbridge-suite ccache

    # install boost serial and json
RUN apt install -y \
        libboost-all-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libserial-dev \
        nlohmann-json3-dev

    # bootstrap rosdep
RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \

    # setup colcon mixin and metadata
    colcon mixin add default \
    https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
    https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update && \

    ##### Post-Settings #####
    # Clear tmp and cache
    rm -rf /tmp/* && \
    rm -rf /temp/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${ROS2_WS}
ENTRYPOINT [ "/ros_entrypoint.bash" ]
CMD ["bash", "-l"]
