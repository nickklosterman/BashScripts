#!/bin/bash
TransmissionPID=$(ps ax | grep -v grep | grep transmission | awk '{ print $1 }' )
bash KillPIDIfDiskSpaceBelowLimit.sh ${TransmissionPID} 200