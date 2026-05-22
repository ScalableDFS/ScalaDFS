#!/bin/bash

FILE=${1:-/mnt/client/testfile}
FSYNC_LOG=${2:-/root/fsync.log}
FSYNC_INTERVAL=${3:-10000}

rm -f "$FILE"
rm -f "$FSYNC_LOG"

python3 - "$FILE" "$FSYNC_LOG" "$FSYNC_INTERVAL" <<'EOF'
import os
import sys

file_path = sys.argv[1]
fsync_log = sys.argv[2]
fsync_interval = int(sys.argv[3])

fd = os.open(file_path, os.O_CREAT | os.O_WRONLY)

for i in range(1, 1000000):
    data = f"SEQ={i:08d}\n".encode()
    data = data.ljust(4096, b'x')

    os.write(fd, data)

    if i % fsync_interval == 0:
        os.fsync(fd)

        with open(fsync_log, "w") as f:
            f.write(str(i))

os.close(fd)
EOF
