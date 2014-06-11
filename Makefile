#
# DKMS configuration for VMware Workstation kernel dependencies.
# by Damien Dejean <djod4556@yahoo.fr>
#
# Makefile wrapper to allow DKMS to use the VMware proprietary tool to build and
# install kernel modules.
#

KERNEL := $(KERNELRELEASE)
HEADERS := $(shell dir /usr/src/linux-$(KERNEL)/include >/dev/null 2>/dev/null && echo /usr/src/linux-$(KERNEL)/include || echo /usr/lib/modules/$(KERNEL)/build/include)
GCC := $(shell vmware-modconfig --console --get-gcc)
DEST := /lib/modules/$(KERNEL)/vmware

TARGETS := vmmon vmnet vmblock vmci vsock

LOCAL_MODULES := $(addsuffix .ko, $(TARGETS))

all: $(LOCAL_MODULES)
	mkdir -p modules/
	mv *.ko modules/
	rm -rf $(DEST)
	depmod

$(HEADERS)/linux/version.h:
	ln -s $(HEADERS)/generated/uapi/linux/version.h $(HEADERS)/linux/version.h

%.ko: $(HEADERS)/linux/version.h
	vmware-modconfig --console --build-mod -k $(KERNEL) $* $(GCC) $(HEADERS) vmware/
	cp -f $(DEST)/$@ .

clean:
	rm -rf modules/
