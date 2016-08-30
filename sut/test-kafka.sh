#!/bin/bash

DATA_DIR=/var/data
OUTPUT_FILE=$DATA_DIR/output.dat
DOCKER_SOCKET=/var/run/docker-host.sock

_docker_logs(){
  ct=$(docker --host=unix://$DOCKER_SOCKET ps | grep /telegraf | awk '{print $1}')
  for c in $ct; do
    echo "logs from telegraf agent $ct:"
    docker --host=unix://$DOCKER_SOCKET logs $ct
  done
}

# cleanup
if [[ -f "$OUTPUT_FILE" ]]; then
  echo "INFO - resetting the test file"
  > "$OUTPUT_FILE"
else
  echo "INFO - no test file found, yet"
fi

echo -n "test output file...                      "
r="false"
i=0
while [[ "x$r" != "xtrue" ]]; do
  sleep 1
  if [[ -f "$OUTPUT_FILE" ]]; then
    grep -q "docker" "$OUTPUT_FILE"
    if [[ $? -eq 0 ]]; then
      r="true"
    fi
  fi
  ((i++))
  if [[ $i -gt 40 ]]; then break; fi
done
if [[ "x$r" != "xtrue" ]]; then
  echo
  echo "telegraf didn't write anything"
  exit 1
fi
echo "[OK]"

echo -n "test docker measurement...               "
sleep 1
grep -q "^docker," "$OUTPUT_FILE"
if [[ $? -ne 0 ]]; then
  echo
  echo "failed"
  exit 1
fi
echo "[OK]"
sleep 1
echo -n "test docker_container_cpu measurement... "
grep -q "^docker_container_cpu," "$OUTPUT_FILE"
if [[ $? -ne 0 ]]; then
  echo
  echo "failed"
  exit 1
fi
echo "[OK]"
echo -n "test docker_container_mem measurement... "
grep -q "^docker_container_mem," "$OUTPUT_FILE"
if [[ $? -ne 0 ]]; then
  echo
  echo "failed"
  exit 1
fi
echo "[OK]"
echo -n "test docker_container_net measurement... "
grep -q "^docker_container_net," "$OUTPUT_FILE"
if [[ $? -ne 0 ]]; then
  echo
  echo "failed"
  exit 1
fi
echo "[OK]"

echo "cleaning up output file"
> "$OUTPUT_FILE"
rm "$OUTPUT_FILE"

echo "all tests passed successfully"
