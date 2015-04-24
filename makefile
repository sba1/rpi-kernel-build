#
# The makefile for driving the build process via Docker
# At least Docker 1.5 is required.
#

IMAGE_NAME := rpi
IMAGE_WITH_KERNAL_NAME := rpi-kernel

KERNEL_CONTAINER := rpi-kernel

all: image

.PHONY: image
image:
	docker build -t $(IMAGE_NAME) .

.PHONY: kernel-image
kernel-image: image
	docker build -t $(IMAGE_WITH_KERNAL_NAME) -f Dockerfile.kernel .

# Use this target to login into the "vanilla" image
.PHONY: login
login: image
	docker run -ti $(IMAGE_NAME) bash

# Use this target to login into the image that also contains the kernel artifact
.PHONY: login-kernel
login-kernel: kernel-image
	docker run -ti $(IMAGE_WITH_KERNAL_NAME) bash

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

.PHONY: linux-oldconfig
linux-oldconfig: image
	-docker rm $@
	docker run -ti --name $@ $(IMAGE_NAME) sh -c "cd /build/linux-rpi/ && make ARCH=arm oldconfig && cp .config linux.config"
	docker cp $@:/build/linux-rpi/linux.config .

# Use this target to extract the linux kernel
.PHONY: kernel
kernel: kernel-image
	-docker rm $(KERNEL_CONTAINER)
	docker run -ti --name $(KERNEL_CONTAINER) $(IMAGE_WITH_KERNAL_NAME) sh -x -c "echo test"
	docker cp $(KERNEL_CONTAINER):/build/linux-rpi/arch/arm/boot/zImage .

.PHONY: kernel-clean
kernel-clean:
	-docker rm $(KERNEL_CONTAINER)
