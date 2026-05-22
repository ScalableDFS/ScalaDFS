# Crash Consistency Experiment Framework

This directory contains the scripts used for distributed crash consistency experiments in the DNS environment.

## Overview

The experiment continuously performs parallel write and fsync workloads from client nodes while forcibly rebooting multiple OSS nodes without clean shutdown.

After OSS recovery and filesystem reconnection, the framework verifies whether the data ranges for which fsync() successfully returned before the crash are correctly persisted.

Each writer process records the latest successfully completed fsync sequence number, and the recovered file contents are checked to confirm that the corresponding sequence data exists.

## Files

### `write_test.sh`

Generates continuous write and periodic fsync workloads.

- 4KB write workload
- Periodic fsync every 10,000 writes
- Records the latest completed fsync sequence number

### `crash.sh`

Forcibly reboots the target OSS node without clean shutdown.

### `recovery.sh`

Reconnects and remounts Lustre OSTs after OSS reboot.

### `multi_run_crash_test.sh`

Main orchestration script for the crash consistency experiment.

Functions:
- Starts multiple parallel writer processes
- Forces simultaneous OSS crashes
- Waits for OSS reboot and recovery
- Verifies fsync persistence after recovery

## Usage

Example:

```bash
./multi_run_crash_test.sh <password> <num_jobs>
