FROM nvidia/cuda:11.3.0-devel-centos8

ARG username

RUN yum -y install epel-release \
    && yum -y install  usbutils pciutils psmisc bzip2 unzip rsync \
    glx-utils mesa-libGLU libXmu libXi libSM freetype librsvg2  \
    alsa-lib   alsa-plugins-pulseaudio libgomp libxkbcommon fuse-libs wget \
    java-11-openjdk-devel ocl-icd xorriso log4cxx.x86_64  cuda \
    && rm -rf /var/cache/yum/*

RUN mkdir -p /etc/OpenCL/vendors \
    && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

COPY davinci-studio.tgz /tmp/
RUN  alias zenity=echo \
    && cd /tmp \
    && tar xvfz davinci-studio.tgz \
    && cd /tmp/squashfs-root \
    && mkdir -p -m 0775 "/opt/resolve/"{configs,DolbyVision,easyDCP,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT} \
    && ./installer -i -y -n -a -C "/opt/resolve" "$PWD" \
    && cd /opt/resolve \
    && ln -s /usr/lib/libcrypto.so.1.0.0 libs/libcrypto.so.10 \
    && ln -s /usr/lib/libssl.so.1.0.0 libs/libssl.so.10 \
    && rm -rf /tmp/davinci-studio.tgz && rm -rf /tmp/squashfs-root 

RUN dbus-uuidgen > /etc/machine-id

VOLUME ["/opt/resolve/configs", "/opt/resolve/Resolve Disk Database", "/opt/resolve/logs"]

RUN useradd -ms /bin/bash ${username}

USER ${username}:${username}
WORKDIR /home/${username}

RUN mkdir /home/${username}/.local

CMD /opt/resolve/bin/resolve

# nvidia-container-runtime 
ENV NVIDIA_VISIBLE_DEVICES all 
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display,video
