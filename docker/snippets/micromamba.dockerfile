# syntax = devthefuture/dockerfile-x
# Install micromamba

RUN sudo apt update && \
    sudo apt install --no-install-recommends -y curl procps && \
    sudo apt clean && \
    sudo apt autoremove -y && \
    sudo rm -rf /var/lib/apt/lists/*

ARG MAMBA_PATH="${USERHOME}/micromamba"
ARG MAMBA_BIN_FOLDER="${MAMBA_PATH}/bin"
RUN mkdir -p ${MAMBA_PATH} && \
    echo "" | BIN_FOLDER=${MAMBA_BIN_FOLDER} ${USERSHELL} -c "$(curl -L micro.mamba.pm/install.sh)" 

ENV PATH="${MAMBA_PATH}/bin:${PATH}"
ENV MAMBA_ROOT_PREFIX=${MAMBA_PATH}
ENV MAMBA_EXE="${MAMBA_BIN_FOLDER}/micromamba"

ARG PROJECT
RUN ${MAMBA_EXE} create -n ${PROJECT} -y && \
    echo "micromamba activate ${PROJECT}" >> ${USERSHELLPROFILE} && \
    echo "alias conda=micromamba" >> ${USERSHELLPROFILE} && \
    echo "alias mamba=micromamba" >> ${USERSHELLPROFILE}

ARG MAMBA_CHANNELS=""
RUN [ -z "${MAMBA_CHANNELS}" ] || \
    for channel in ${MAMBA_CHANNELS}; do ${MAMBA_EXE} config --add channels ${channel}; done

ARG MAMBA_PACKAGES=""
RUN [ -z "${MAMBA_PACKAGES}" ] || ${MAMBA_EXE} install -n ${PROJECT} ${MAMBA_PACKAGES}

ARG PIP_REQUIREMENTS=""
RUN [ -z "${PIP_REQUIREMENTS}" ] || ${MAMBA_PATH}/envs/${PROJECT}/bin/python -m pip install --no-cache-dir ${PIP_REQUIREMENTS}

# Run SHELL so subsequent commands are run in the new environment
SHELL ["/bin/bash", "-c"]

