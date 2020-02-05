#!/usr/bin/env bash

deregister_from_consul(){
  CONSUL_HTTP_ADDR="http://169.254.1.1:8500"

  # Query ECS metadata from file
  SERVICE_HOST=ip-$(jq -r '.HostPrivateIPv4Address' < ${ECS_CONTAINER_METADATA_FILE} | tr -s '.' '-')
  SERVICE_NAME=$(jq -r '.DockerContainerName | sub("/";"")' < ${ECS_CONTAINER_METADATA_FILE})
  SERVICE_PORTS=($(jq -r '.PortMappings[].ContainerPort' < ${ECS_CONTAINER_METADATA_FILE}))

  echo "[TERM] Service host ${SERVICE_HOST}"
  echo "[TERM] Service name ${SERVICE_NAME}"
  echo "[TERM] Service ports ${SERVICE_PORTS[@]}"

  for SERVICE_PORT in ${SERVICE_PORTS[@]}; do
    # https://github.com/gliderlabs/registrator/blob/v7/docs/user/services.md#unique-id
    SERVICE_ID="${SERVICE_HOST}:${SERVICE_NAME}:${SERVICE_PORT}"
    echo "[TERM] Deregistration of Service ID: ${SERVICE_ID}"
    curl -s -X PUT \
         --connect-timeout 3 \
         "${CONSUL_HTTP_ADDR}/v1/agent/service/deregister/${SERVICE_ID}"
  done
}

sigterm_handler(){
  echo "[TERM] Signal caught, starting deregistration from Consul..."
  deregister_from_consul
  echo "[TERM] Deregistration from Consul completed."
  echo "[TERM] Wait for Traefik to refresh the list of backends..."
  # TODO ?
  sleep 30
  echo "[TERM] Forwarding signal to application process -> $pid"
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# Only run deregistration when running on ECS
if [ ! -z ${ECS_CONTAINER_METADATA_FILE} ]; then
  trap "sigterm_handler" TERM
fi

nginx
pid=$(cat /var/run/nginx.pid)

echo "NGINX PID = ${pid}"

while true
do
  tail -f /dev/null & wait ${!}
done
