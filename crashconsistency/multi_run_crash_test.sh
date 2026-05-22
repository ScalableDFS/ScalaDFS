#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <password> <num_jobs>"
    exit 1
fi

PASSWORD=$1
NUM_JOBS=$2

HOSTS=(
    cluster1
    cluster2
    cluster3
    cluster4
    cluster5
    cluster6
    cluster7
    cluster8
    cluster9
    cluster10
)

RUN_ID=$(date +%Y%m%d_%H%M%S)

RESULT_DIR=/root/results/$RUN_ID

mkdir -p "$RESULT_DIR"

echo "RUN_ID=$RUN_ID"
echo "RESULT_DIR=$RESULT_DIR"
echo "NUM_JOBS=$NUM_JOBS"

echo "[1] start writers"

for ((i=0; i<NUM_JOBS; i++))
do
    FILE=/mnt/client/testfile_${RUN_ID}_$i
    LOG=$RESULT_DIR/fsync_$i.log

    ./write_test.sh "$FILE" "$LOG" 10000 \
        > "$RESULT_DIR/writer_$i.log" 2>&1 &

    PIDS[$i]=$!

    echo "writer=$i pid=${PIDS[$i]}"
done

echo "[2] wait before crash"

sleep 10

echo "[3] crash all OSS nodes"

for HOST in "${HOSTS[@]}"
do
    echo "crash $HOST"

    nohup sshpass -p "$PASSWORD" \
        ssh root@$HOST "/root/crash.sh" \
        >/dev/null 2>&1 &
done

echo "[4] wait reboot"

for HOST in "${HOSTS[@]}"
do
    echo "wait reboot: $HOST"

    while true
    do
        sshpass -p "$PASSWORD" \
            ssh -o ConnectTimeout=2 \
            root@$HOST "echo alive" \
            >/dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "$HOST ssh ready"
            break
        fi

        sleep 2
    done
done

echo "[5] enable lnet"

for HOST in "${HOSTS[@]}"
do
    echo "enable lnet: $HOST"

    sshpass -p "$PASSWORD" \
        ssh root@$HOST "/root/enablelnet.sh" \
        > "$RESULT_DIR/${HOST}_enablelnet.log" 2>&1
done

sleep 5

echo "[6] recovery mount"

for HOST in "${HOSTS[@]}"
do
    echo "recovery: $HOST"

    sshpass -p "$PASSWORD" \
        ssh root@$HOST "/root/recovery.sh" \
        > "$RESULT_DIR/${HOST}_recovery.log" 2>&1
done

echo "[7] wait recovery"

sleep 30

echo "[8] stop writers"

for PID in "${PIDS[@]}"
do
    kill -9 $PID 2>/dev/null
done

echo "[9] verify"

PASS_COUNT=0
FAIL_COUNT=0

for ((i=0; i<NUM_JOBS; i++))
do
    FILE=/mnt/client/testfile_${RUN_ID}_$i
    LOG=$RESULT_DIR/fsync_$i.log

    LAST=$(cat "$LOG" 2>/dev/null)

    if [ -z "$LAST" ]; then
        echo "[FAIL] writer=$i no fsync log"

        FAIL_COUNT=$((FAIL_COUNT+1))
        continue
    fi

    TARGET=$(printf "SEQ=%08d" $LAST)

    grep -a "$TARGET" "$FILE" \
        > "$RESULT_DIR/grep_$i.log"

    if [ $? -eq 0 ]; then
        echo "[PASS] writer=$i fsync=$LAST"

        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo "[FAIL] writer=$i fsync=$LAST"

        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
done

echo
echo "========== SUMMARY =========="
echo "PASS_COUNT=$PASS_COUNT"
echo "FAIL_COUNT=$FAIL_COUNT"
echo "RESULT_DIR=$RESULT_DIR"
echo "============================="
echo

echo "[10] save metadata"

ls -lh /mnt/client/testfile_${RUN_ID}_* \
    > "$RESULT_DIR/testfile_stat.log"

echo "DONE"
