# Telegraf Configuration
#
# Telegraf is entirely plugin driven. All metrics are gathered from the
# declared inputs, and sent to the declared outputs.
#
# Plugins must be declared in here to be active.
# To deactivate a plugin, comment out the name and any variables.
#
# Use 'telegraf -config telegraf.conf -test' to see what metrics a config
# file would generate.
#
# Environment variables can be used anywhere in this config file, simply prepend
# them with $. For strings the variable must be within quotes (ie, "$STR_VAR"),
# for numbers and booleans they should be plain (ie, $INT_VAR, $BOOL_VAR)


# Global tags can be specified here in key="value" format.
[global_tags]
  # dc = "us-east-1" # will tag all metrics with dc=us-east-1
  # rack = "1a"
  ## Environment variables can be used as tags, and throughout the config file
  # user = "$USER"
  {% for key, value in environment('TAG_') %}{{ key }}="{{ value }}"
  {% endfor %}


# Configuration for telegraf agent
[agent]
  ## Default data collection interval for all inputs
  interval = "{{ INTERVAL | default("10s") }}"
  ## Rounds collection interval to 'interval'
  ## ie, if interval="10s" then always collect on :00, :10, :20, etc.
  round_interval = {{ ROUND_INTERVAL | default("true") }}

  ## Telegraf will cache metric_buffer_limit metrics for each output, and will
  ## flush this buffer on a successful write.
  metric_buffer_limit = 1000
  ## Flush the buffer whenever full, regardless of flush_interval.
  flush_buffer_when_full = true

  ## Collection jitter is used to jitter the collection by a random amount.
  ## Each plugin will sleep for a random time within jitter before collecting.
  ## This can be used to avoid many plugins querying things like sysfs at the
  ## same time, which can have a measurable effect on the system.
  collection_jitter = "{{ COLLECTION_JITTER | default("1s") }}"

  ## Default flushing interval for all outputs. You shouldn't set this below
  ## interval. Maximum flush_interval will be flush_interval + flush_jitter
  flush_interval = "{{ FLUSH_INTERVAL | default("10s") }}"
  ## Jitter the flush interval by a random amount. This is primarily to avoid
  ## large write spikes for users running a large number of telegraf instances.
  ## ie, a jitter of 5s and interval 10s means flushes will happen every 10-15s
  flush_jitter = "{{ FLUSH_JITTER | default("3s") }}"

  ## Run telegraf in debug mode
  debug = false
  ## Run telegraf in quiet mode
  quiet = false
  ## Override default hostname, if empty use os.Hostname()
  hostname = "{{ HOSTNAME }}"
  ## If set to true, do no set the "host" tag in the telegraf agent.
  omit_hostname = false


###############################################################################
#                            OUTPUT PLUGINS                                   #
###############################################################################

# Configuration for influxdb server to send metrics to
{% if OUTPUT_INFLUXDB_ENABLED == "true" %}
[[outputs.influxdb]]
  ## The full HTTP or UDP endpoint URL for your InfluxDB instance.
  ## Multiple urls can be specified as part of the same cluster,
  ## this means that only ONE of the urls will be written to each interval.
  # urls = ["udp://localhost:8089"] # UDP endpoint example
  urls = ["{{ INFLUXDB_URL }}"] # required
  ## The target database for metrics (telegraf will create it if not exists).
  database = "telegraf" # required
  ## Retention policy to write to.
  retention_policy = "default"
  ## Precision of writes, valid values are "ns", "us", "ms", "s", "m", "h".
  ## note: using "s" precision greatly improves InfluxDB compression.
  precision = "s"

  ## Write timeout (for the InfluxDB client), formatted as a string.
  ## If not provided, will default to 5s. 0s means no timeout (not recommended).
  timeout = "{{ INFLUXDB_TIMEOUT | default("5") }}s"
  {% if INFLUXDB_USER is defined %}
  username = "{{ INFLUXDB_USER }}"
  password = "{{ INFLUXDB_PASS | default("metrics") }}"
  {% endif %}
  ## Set the user agent for HTTP POSTs (can be useful for log differentiation)
  # user_agent = "telegraf"
  ## Set UDP payload size, defaults to InfluxDB UDP Client default (512 bytes)
  # udp_payload = 512
{% else %}
# InfluxDB output is disabled
{% endif %}

# Configuration for AWS CloudWatch output.
{% if OUTPUT_CLOUDWATCH_ENABLED == "true" %}
[[outputs.cloudwatch]]
  ## Amazon REGION
  region = '{{ CLOUDWATCH_REGION | default("us-east-1") }}'

  ## Namespace for the CloudWatch MetricDatums
  namespace = '{{ CLOUDWATCH_NAMESPACE | default("InfluxData/Telegraf") }}'
{% else %}
# Cloudwatch output is disabled
{% endif %}

# # Configuration for the Kafka server to send metrics to
{% if OUTPUT_KAFKA_ENABLED == "true" %}
[[outputs.kafka]]
  ## URLs of kafka brokers
  brokers = ["{{ OUTPUT_KAFKA_BROKER_URL | default("localhost:9092") }}"]
  ## Kafka topic for producer messages
  topic = "{{ OUTPUT_KAFKA_TOPIC | default("telegraf") }}"
  ## Telegraf tag to use as a routing key
  ##  ie, if this tag exists, it's value will be used as the routing key
  routing_tag = "host"

  ## CompressionCodec represents the various compression codecs recognized by
  ## Kafka in messages.
  ##  0 : No compression
  ##  1 : Gzip compression
  ##  2 : Snappy compression
  compression_codec = 0

  ##  RequiredAcks is used in Produce Requests to tell the broker how many
  ##  replica acknowledgements it must see before responding
  ##   0 : the producer never waits for an acknowledgement from the broker.
  ##       This option provides the lowest latency but the weakest durability
  ##       guarantees (some data will be lost when a server fails).
  ##   1 : the producer gets an acknowledgement after the leader replica has
  ##       received the data. This option provides better durability as the
  ##       client waits until the server acknowledges the request as successful
  ##       (only messages that were written to the now-dead leader but not yet
  ##       replicated will be lost).
  ##   -1: the producer gets an acknowledgement after all in-sync replicas have
  ##       received the data. This option provides the best durability, we
  ##       guarantee that no messages will be lost as long as at least one in
  ##       sync replica remains.
  required_acks = -1

  ##  The total number of times to retry sending a message
  max_retry = 3

  ## Optional SSL Config
  # ssl_ca = "/etc/telegraf/ca.pem"
  # ssl_cert = "/etc/telegraf/cert.pem"
  # ssl_key = "/etc/telegraf/key.pem"
  ## Use SSL but skip chain & host verification
  # insecure_skip_verify = false

  ## Data format to output.
  ## Each data format has it's own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_OUTPUT.md
  data_format = "{{ KAFKA_DATA_FORMAT | default("influx") }}"
{% else %}
# Kafka output is disabled
{% endif %}
###############################################################################
#                            INPUT PLUGINS                                    #
###############################################################################

# Read metrics about cpu usage
{% if INPUT_CPU_ENABLED == "true" %}
[[inputs.cpu]]
  ## Whether to report per-cpu stats or not
  percpu = true
  ## Whether to report total system cpu stats or not
  totalcpu = true
  ## Comment this line if you want the raw CPU time metrics
  fielddrop = ["time_*"]
{% else %}
  # CPU input is disabled
{% endif %}

# Read metrics about disk usage by mount point
{% if INPUT_DISK_ENABLED == "true" %}
[[inputs.disk]]
  ## By default, telegraf gather stats for all mountpoints.
  ## Setting mountpoints will restrict the stats to the specified mountpoints.
  # mount_points = ["/"]

  ## Ignore some mountpoints by filesystem type. For example (dev)tmpfs (usually
  ## present on /run, /var/run, /dev/shm or /dev).
  ignore_fs = ["tmpfs", "devtmpfs"]
{% else %}
  # Disk input is disabled
{% endif %}

# Read metrics about disk IO by device
{% if INPUT_DISKIO_ENABLED == "true" %}
[[inputs.diskio]]
  ## By default, telegraf will gather stats for all devices including
  ## disk partitions.
  ## Setting devices will restrict the stats to the specified devices.
  # devices = ["sda", "sdb"]
  ## Uncomment the following line if you do not need disk serial numbers.
  # skip_serial_number = true
{% else %}
  # Disk IO input is disabled
{% endif %}

# Get kernel statistics from /proc/stat
{% if INPUT_KERNEL_ENABLED == "true" %}
[[inputs.kernel]]
  # no configuration
{% else %}
  # Kernel input is disabled
{% endif %}

# Read metrics about memory usage
{% if INPUT_MEM_ENABLED == "true" %}
[[inputs.mem]]
  # no configuration
{% else %}
  # Memory input is disabled
{% endif %}

# Get the number of processes and group them by status
{% if INPUT_PROCESS_ENABLED == "true" %}
[[inputs.processes]]
  # no configuration
{% else %}
  # Process input is disabled
{% endif %}

# Read metrics about swap memory usage
{% if INPUT_SWAP_ENABLED == "true" %}
[[inputs.swap]]
  # no configuration
{% else %}
  # Swap input is disabled
{% endif %}

# Read metrics about system load & uptime
{% if INPUT_SYSTEM_ENABLED == "true" %}
[[inputs.system]]
  # no configuration
{% else %}
  # System input is disabled
{% endif %}

# Read metrics about docker containers
{% if INPUT_DOCKER_ENABLED == "true" %}
[[inputs.docker]]
  ## Docker Endpoint
  ##   To use TCP, set endpoint = "tcp://[ip]:[port]"
  ##   To use environment variables (ie, docker-machine), set endpoint = "ENV"
  endpoint = "unix:///var/run/docker.sock"
  ## Only collect metrics for these containers, collect all if empty
  container_names = []
{% else %}
  # Docker input is disabled
{% endif %}

# # Read metrics from one or more commands that can output to stdout
# [[inputs.exec]]
#   ## Commands array
#   commands = ["/tmp/test.sh", "/usr/bin/mycollector --foo=bar"]
#
#   ## measurement name suffix (for separating different commands)
#   name_suffix = "_mycollector"
#
#   ## Data format to consume.
#   ## Each data format has it's own unique set of configuration options, read
#   ## more about them here:
#   ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
#   data_format = "influx"


# # Read TCP metrics such as established, time wait and sockets counts.
# [[inputs.netstat]]
#   # no configuration

# Read metrics from Kafka topic(s)
{% if INPUT_KAFKA_ENABLED == "true" %}
[[inputs.kafka_consumer]]
  ## topic(s) to consume
  topics = [ "{{ INPUT_KAFKA_TOPIC | default("telegraf") }}" ]
  ## an array of Zookeeper connection strings
  zookeeper_peers = ["{{ INPUT_KAFKA_ZOOKEEPER_PEER | default("zookeeper:2181") }}"]
  ## the name of the consumer group
  consumer_group = "telegraf_metrics_consumers"
  ## Maximum number of metrics to buffer between collection intervals
  metric_buffer = 100000
  ## Offset (must be either "oldest" or "newest")
  offset = "oldest"

  ## Data format to consume.

  ## Each data format has it's own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  data_format = "{{ KAFKA_DATA_FORMAT | default("influx") }}"
{% else %}
  # Kafka input is disabled
{% endif %}
