#!/bin/sh

echo "Configured outputs:"
echo "InfluxDB:     $OUTPUT_INFLUXDB_ENABLED"
echo "Cloudwatch:   $OUTPUT_CLOUDWATCH_ENABLED"
echo "Kafka:        $OUTPUT_KAFKA_ENABLED"
envtpl /etc/telegraf/telegraf.conf.tpl

/bin/telegraf -config /etc/telegraf/telegraf.conf