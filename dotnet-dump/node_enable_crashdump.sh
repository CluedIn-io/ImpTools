#!/bin/sh

# run as root on the node that is running the pod you wish to perform crashdumps on
# https://www.kernel.org/doc/Documentation/security/Yama.txt
echo 0 > /proc/sys/kernel/yama/ptrace_scope