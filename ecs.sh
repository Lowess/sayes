#!/usr/bin/env bash

ECS_CLUSTER=${ECS_CLUSTER:-default}
ecs-cli compose --file docker-compose.yml \
        --project-name nginx-sayes \
        service up \
        --deployment-min-healthy-percent 100 \
        --deployment-max-percent 200 \
        --cluster ${ECS_CLUSTER} \
        --region us-east-1 \
        --force-deployment
