#
# The makefile for driving the build process via Docker
#

IMAGE_NAME := rpi

KERNEL_CONTAINER := rpi-kernel

all: image

.PHONY: image
image:
	docker build -t $(IMAGE_NAME) .

# Use this target to login into the "vanilla" image
.PHONY: login
login: image
	docker run -ti $(IMAGE_NAME) bash

# Use this target for altering the cross compiler configuration.
# The local crosstool.config will be updated when this target is
# executed.
.PHONY: crosstools-menuconfig
crosstools-menuconfig: image
	-docker rm $@
	docker run -ti --name $@ $(IMAGE_NAME) sh -c "cd /build/crosstool-arm-build && /build/crosstool-bin/bin/ct-ng menuconfig && cp .config crosstool.config"
	docker cp $@:/build/crosstool-arm-build/crosstool.config .

# Use this target for altering the linux kernel configuration.
# The local linux.config will be updated when this target is
# executed.
.PHONY: linux-menuconfig
linux-menuconfig: image
	-docker rm $@
	docker run -ti --name $@ $(IMAGE_NAME) sh -c "cd /build/linux-rpi/ && make ARCH=arm menuconfig && cp .config linux.config"
	docker cp $@:/build/linux-rpi/linux.config .

# Use this target to compile the linux kernel
.PHONY: kernel
kernel: image
	-docker rm $(KERNEL_CONTAINER)
	docker run -ti --name $(KERNEL_CONTAINER) $(IMAGE_NAME) sh -x -c "cd /build/linux-rpi && make ARCH=arm -j\$$(nproc) CROSS_COMPILE=\$${CCPREFIX}"
	docker cp $(KERNEL_CONTAINER):/build/linux-rpi/arch/arm/boot/zImage .

.PHONY: kernel-clean
kernel-clean:
	-docker rm $(KERNEL_CONTAINER)
