A basic environment to cross-compile the Linux kernel for
the Raspberry Pi 2 based on Docker. The generated kernel
may also work for Raspberry Pi.

Requirements
============

You need a Docker installation to build the Raspberry Pi
Linux kernel with this project.

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
however, is built in a container.
