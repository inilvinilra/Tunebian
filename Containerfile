FROM debian:stable

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        debootstrap \
        dosfstools \
        file \
        git \
        grub-efi-amd64-bin \
        grub-pc-bin \
        isolinux \
        live-build \
        mtools \
        qemu-utils \
        rsync \
        squashfs-tools \
        sudo \
        syslinux-common \
        xorriso \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${GROUP_ID}" builder \
    && useradd --uid "${USER_ID}" --gid "${GROUP_ID}" --create-home --shell /bin/bash builder \
    && printf 'builder ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/builder \
    && chmod 0440 /etc/sudoers.d/builder

WORKDIR /workspace
USER builder
