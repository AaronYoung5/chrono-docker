# SPDX-License-Identifier: MIT
# This snippet install Chrono in ${PACKAGE_DIR}chrono
# NOTE: Requires OPTIX_SCRIPT to be set and for there be a file that exists there
# NOTE: ROS needs to be installed, as well

# Verify ROS has been installed, exit if not
ARG ROS_INSTALL_PREFIX
RUN if [ ! -f "${ROS_INSTALL_PREFIX}/setup.sh" ]; then echo "ROS must be installed before Chrono can be installed."; exit 1; fi

# Verify cuda is installed, exit if not
RUN if [ ! -d "/usr/local/cuda" ]; then echo "CUDA must be installed before Chrono can be installed."; exit 1; fi

# Set up some variables
ARG PACKAGE_DIR="${USERHOME}/packages"
RUN mkdir -p ${PACKAGE_DIR}

# Install Chrono dependencies
RUN sudo apt update && \
        sudo apt install --no-install-recommends -y \
        libirrlicht-dev \
        libeigen3-dev \
        git \
        cmake \
        ninja-build \
        swig \
        libxxf86vm-dev \
        freeglut3-dev \
        python3-colcon-common-extensions \
        python3-numpy \
        libglu1-mesa-dev \
        libglew-dev \
        libglfw3-dev \
        libblas-dev \
        liblapack-dev \
        wget \
        xorg-dev && \
        sudo apt clean && sudo apt autoremove -y && sudo rm -rf /var/lib/apt/lists/*

# OptiX
ARG OPTIX_SCRIPT
COPY ${OPTIX_SCRIPT} /tmp/optix.sh
RUN sudo chmod +x /tmp/optix.sh && \
    mkdir -p ${PACKAGE_DIR}/optix && \
    /tmp/optix.sh --prefix=${PACKAGE_DIR}/optix --skip-license && \
    sudo rm /tmp/optix.sh

# Vulkan
RUN wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo tee /etc/apt/trusted.gpg.d/lunarg.asc && \
    UBUNTU_CODENAME=$(lsb_release -cs) && \
    sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan.list "http://packages.lunarg.com/vulkan/lunarg-vulkan-${UBUNTU_CODENAME}.list" && \
    sudo apt update && sudo apt install vulkan-sdk -y && \
    sudo apt clean && sudo apt autoremove -y && sudo rm -rf /var/lib/apt/lists/*

# chrono_ros_interfaces
ARG ROS_WORKSPACE_DIR="${USERHOME}/packages/workspace"
ARG CHRONO_ROS_INTERFACES_DIR="${ROS_WORKSPACE_DIR}/src/chrono_ros_interfaces"
RUN mkdir -p ${CHRONO_ROS_INTERFACES_DIR} && \
    git clone https://github.com/projectchrono/chrono_ros_interfaces.git ${CHRONO_ROS_INTERFACES_DIR} && \
    cd ${ROS_WORKSPACE_DIR} && \
    . ${ROS_INSTALL_PREFIX}/setup.sh && \
    colcon build --packages-select chrono_ros_interfaces

# Chrono
ARG CHRONO_BRANCH="main"
ARG CHRONO_REPO="https://github.com/projectchrono/chrono.git"
ARG CHRONO_DIR="${USERHOME}/chrono"
ARG CHRONO_INSTALL_DIR="${USERHOME}/packages/chrono"
RUN git clone --recursive -b ${CHRONO_BRANCH} ${CHRONO_REPO} ${CHRONO_DIR} && \
    cd ${CHRONO_DIR}/contrib/build-scripts/urdf/ && \
    bash buildURDF.sh ${PACKAGE_DIR}/urdf
ARG PATH="${MAMBA_PATH}/envs/${PROJECT}/bin:${PATH}"
RUN . ${ROS_WORKSPACE_DIR}/install/setup.sh && \
    mkdir ${CHRONO_DIR}/build && \
    cd ${CHRONO_DIR}/build && \
    cmake ../ -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_DEMOS=OFF \
        -DBUILD_BENCHMARKING=OFF \
        -DBUILD_TESTING=OFF \
        -DENABLE_MODULE_VEHICLE=ON \
        -DENABLE_MODULE_IRRLICHT=ON \
        -DENABLE_MODULE_PYTHON=ON \
        -DENABLE_MODULE_SENSOR=ON \
        -DENABLE_MODULE_ROS=ON \
        -DENABLE_MODULE_PARSERS=ON \
        -DCMAKE_LIBRARY_PATH=$(find /usr/local/cuda/ -type d -name stubs) \
        -DEigen3_DIR=/usr/lib/cmake/eigen3 \
        -DOptiX_INCLUDE=${PACKAGE_DIR}/optix/include \
        -DOptiX_INSTALL_DIR=${PACKAGE_DIR}/optix \
        -DUSE_CUDA_NVRTC=ON \
        -DNUMPY_INCLUDE_DIR=$(python3 -c 'import numpy; print(numpy.get_include())') \
        -DCMAKE_INSTALL_PREFIX=${CHRONO_INSTALL_DIR} \
        -Durdfdom_DIR=${PACKAGE_DIR}/urdf/lib/urdfdom/cmake \
        -Durdfdom_headers_DIR=${PACKAGE_DIR}/urdf/lib/urdfdom_headers/cmake \
        -Dconsole_bridge_DIR=${PACKAGE_DIR}/urdf/lib/console_bridge/cmake \
        -Dtinyxml2_DIR=${PACKAGE_DIR}/urdf/CMake \
        && \
    ninja && ninja install

# Update shell config
RUN echo ". ${ROS_WORKSPACE_DIR}/install/setup.sh" >> ${USERSHELLPROFILE} && \
    echo "export PYTHONPATH=\$PYTHONPATH:${CHRONO_INSTALL_DIR}/share/chrono/python" >> ${USERSHELLPROFILE} && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${CHRONO_INSTALL_DIR}/lib:${PACKAGE_DIR}/urdf/lib:${PACKAGE_DIR}/vsg/lib" >> ${USERSHELLPROFILE}
