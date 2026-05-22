MODULES := obdecho
obdecho-objs := echo_client.o debug.o
#obdecho-objs += echo.o

EXTRA_DIST = $(obdecho-objs:%.o=%.c) echo_internal.h
EXTRA_DIST += echo.c

include /root/lustre-Eurosys26/existing/lustre-existing/Rules
