# docker-telegraf

[![Build Status](http://drone.amp.appcelerator.io:8000/api/badges/appcelerator/docker-telegraf/status.svg)](http://drone.amp.appcelerator.io:8000/appcelerator/docker-telegraf)

Docker Image for [InfluxData Telegraf](https://influxdata.com/time-series-platform/telegraf/).

## Run

You may need to replace the path to */var/run/docker.sock* depending on the location of your docker socket.

Most basic form:
```
docker run -t -v /var/run/docker.sock:/var/run/docker.sock:ro appcelerator/telegraf
```

Custom InfluxDB location and additional tags:
```
docker run -t -v /var/run/docker.sock:/var/run/docker.sock:ro -v /var/run/utmp:/var/run/utmp:ro -e INFLUXDB_URL=http://influxdb:8086 -e TAG_datacenter=eu-central-1 -e TAG_type=core appcelerator/telegraf
```

# Configuration (ENV, -e)
- HOSTNAME - To pass in the docker host's actual hostname
- TAG_<name> - Adds a tag with the given value to all measurements
- INTERVAL - Data collection interval, defaults to 10s
- ROUND_INTERVAL - Round collection interval, defaults to true
- COLLECTION_JITTER - Collection jitter by a random amount, defaults to 1s
- FLUSH_INTERVAL - Default flushing interval for all outputs, defaults to 10s
- FLUSH_JITTER - Jitter the flush interval by a random amount, defaults to 3s
- OUTPUT_INFLUXDB_ENABLED - enable InfluxDB Output, defaults to true
- OUTPUT_CLOUDWATCH_ENABLED - enable Amazon Cloudwatch Output, defaults to false
- OUTPUT_KAFKA_ENABLED - enable Kafka Output, defaults to false
- INPUT_KAFKA_ENABLED - enable Kafka Input, defaults to false
- INPUT_CPU_ENABLED - enable cpu metrics, defaults to false
- INPUT_DISK_ENABLED - enable disk metrics, defaults to false
- INPUT_DISKIO_ENABLED - enable disk I/O metrics, defaults to false
- INPUT_KERNEL_ENABLED - enable kernel metrics, defaults to false
- INPUT_MEM_ENABLED - enable mem metrics, defaults to false
- INPUT_PROCESS_ENABLED - enable process metrics, defaults to false
- INPUT_SWAP_ENABLED - enable swap metrics, defaults to false
- INPUT_SYSTEM_ENABLED - enable system metrics, defaults to false
- INPUT_DOCKER_ENABLED - enable Docker metrics, defaults to true
- INFLUXDB_URL - Where is your InfluxDB running? (default: http://localhost:8086) Note: No trailing slash!
- INFLUXDB_USER - InfluxDB username
- INFLUXDB_PASS - InfluxDB password, defaults to metrics
- INFLUXDB_TIMEOUT - InfluxDB timetout (in seconds), defaults to 5
- CLOUDWATCH_REGION - Amazon region, defaults to us-east-1
- CLOUDWATCH_NAMESPACE - Namespace, defaults to InfluxData/Telegraf
- OUTPUT_KAFKA_BROKER_URL - Kafka broker URL in output, defaults to localhost:9092
- OUTPUT_KAFKA_TOPIC - Kafka topic on which to write, defaults to telegraf
- INPUT_KAFKA_BROKER_URL - Kafka broker URL in input, defaults to localhost:9092
- INPUT_KAFKA_TOPIC - Kafka topic on which to read, defaults to telegraf
- INPUT_KAFKA_ZOOKEEPER_PEER - Zookeeper peers used by Kafka in input, defaults to zookeeper:2181
- KAFKA_DATA_FORMAT - Kafka data format, defaults to influx
- CONSUL - Consul URL for container pilot, example: consul:8500, disabled by default

## Tags

- latest
