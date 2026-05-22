MODULES := ofd

ofd-objs := ofd_dev.o ofd_obd.o ofd_fs.o ofd_trans.o ofd_objects.o ofd_io.o
ofd-objs += lproc_ofd.o ofd_dlm.o ofd_lvb.o ofd_access_log.o

EXTRA_DIST = $(ofd-objs:%.o=%.c) ofd_internal.h

include /root/lustre-Eurosys26/existing/lustre-existing/Rules
