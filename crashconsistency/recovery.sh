#!/bin/bash

echo "Mount existing Lustre OSTs"

mount -t lustre -O nochecksum -o writeconf /dev/nvme0n1 /mnt/test/
mount -t lustre -O nochecksum -o writeconf /dev/nvme1n1 /mnt/test1/

echo "Done"

df -ht lustre
