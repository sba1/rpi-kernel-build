FROM debian:jessie

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	bc \
	binutils \
	bison \
	bzip2 \
	ca-certificates \
	flex \
	g++ \
	gawk \
	gcc \
	git \
	gperf \
	libtool-bin \
	make \
	ncurses-dev \
	openssl \
	patch \
	texinfo \
	wget

RUN mkdir /build
WORKDIR /build

# Add a build user and change to it
RUN useradd build -m
RUN chown build .
USER build

RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.20.0.tar.bz2
RUN tar xjf crosstool-ng-1.20.0.tar.bz2

WORKDIR /build/crosstool-ng-1.20.0

RUN ./configure --prefix=/build/crosstool-bin
RUN make install

# Create the directory in which cross tool building will take place
# and copy the configuration
RUN mkdir /build/crosstool-arm-build
WORKDIR /build/crosstool-arm-build
COPY crosstool.config /build/crosstool-arm-build/.config

# Now build the cross compiler
RUN /build/crosstool-bin/bin/ct-ng build

# Now download recent linux source. It will be part
# of the image. We download the complete one
WORKDIR /build
RUN git clone --verbose --progress --branch rpi-3.18.y --depth 5 https://github.com/raspberrypi/linux.git linux-rpi 
WORKDIR /build/linux-rpi

ENV PATH /home/build/x-tools/armeb-unknown-eabi/bin/:$PATH
ENV CCPREFIX /home/build/x-tools/armeb-unknown-eabi/bin/armeb-unknown-eabi-
COPY linux.config /build/linux-rpi/.config
