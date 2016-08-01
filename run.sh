#!/bin/bash

PILOT="/bin/amppilot/amp-pilot.alpine"

echo "Configured inputs:"
echo "Kafka:           $INPUT_KAFKA_ENABLED"
echo "CPU:             $INPUT_CPU_ENABLED"
echo "Disk:            $INPUT_DISK_ENABLED"
echo "Disk I/O:        $INPUT_DISKIO_ENABLED"
echo "Kernel:          $INPUT_KERNEL_ENABLED"
echo "Memory:          $INPUT_MEM_ENABLED"
echo "Process:         $INPUT_PROCESS_ENABLED"
echo "Swap:            $INPUT_SWAP_ENABLED"
echo "System:          $INPUT_SYSTEM_ENABLED"
echo "Docker:          $INPUT_DOCKER_ENABLED"

echo "Configured outputs:"
echo "InfluxDB:       $OUTPUT_INFLUXDB_ENABLED ($INFLUXDB_URL)"
echo "Cloudwatch:     $OUTPUT_CLOUDWATCH_ENABLED"
echo "Kafka:          $OUTPUT_KAFKA_ENABLED"
echo "File:           $OUTPUT_FILE_ENABLED ($OUTPUT_FILE_PATH)"

if [[ -f /etc/telegraf/telegraf.conf.tpl ]] ; then
    echo "Generating /etc/telegraf/telegraf.conf from template..."
    envtpl /etc/telegraf/telegraf.conf.tpl
else
    if [[ -f /etc/telegraf/telegraf.conf ]] ; then
        echo "/etc/telegraf/telegraf.conf already exists. Nothing to do."
    else
        echo "ERROR: No template or configuration file found: /etc/telegraf/telegraf.conf"
    fi
fi

CMD="/bin/telegraf"
CMDARGS="-config /etc/telegraf/telegraf.conf"
if [[ -n "$CONSUL" ]]; then
    i=0
    while [[ ! -x "$PILOT" ]]; do
        echo "WARNING - amp-pilot is not yet available, try again..."
        sleep 1
        ((i++))
        if [[ $i -ge 20 ]]; then
            echo "ERROR - can't find amp-pilot, abort"
            exit 1
        fi
    done
fi
  
if [[ -n "$CONSUL" && -x "$PILOT" ]]; then
    echo "registering in Consul with $PILOT"
    export AMPPILOT_LAUNCH_CMD="$CMD $CMDARGS"
    export DEPENDENCIES=${DEPENDENCIES:-influxdb}
    export AMPPILOT_REGISTEREDPORT=${AMPPILOT_REGISTEREDPORT:-8094}
    export SERVICE_NAME=${SERVICE_NAME:-telegraf}
    exec "$PILOT"
else
    exec "$CMD" $CMDARGS
fi
