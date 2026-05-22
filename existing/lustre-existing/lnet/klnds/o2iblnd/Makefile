MODULES := ko2iblnd
ko2iblnd-objs := o2iblnd.o o2iblnd_cb.o o2iblnd_modparams.o

# Need to make sure that an external OFED source pool overrides
# any in-kernel OFED sources
NOSTDINC_FLAGS +=   -I/root/lustre-Eurosys26/existing/linux-kernel/include -I/root/lustre-Eurosys26/existing/linux-kernel/include/uapi

include /root/lustre-Eurosys26/existing/lustre-existing/Rules
