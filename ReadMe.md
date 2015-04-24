A basic environment to cross-compile the Linux kernel for
the Raspberry Pi 2 based on Docker. The generated kernel
may also work for Raspberry Pi.

Requirements
============

You need a Docker installation of at least version 1.5 to
build the Raspberry Pi Linux kernel with this project.

Usage
=====

In order to build the kernel, enter

```
  $ make kernel
```

in the command prompt. This will first create a Docker
image that consists of a cross compiler environment
(based on crosstool-ng) suitable for cross compiling
the special Linux kernel for the Raspberry Pi 2. The
image also contains the source code of the Linux kernel
to take advantage of Docker's cache. The actual kernel,
however, is built as part of another image on top of the
first one. The ```zImage``` and ```modules.tar.gz``` are
extracted from that image.

To adjust the kernel configuration use

```
 $ make linux-menuconfig
```

in the command prompt.
