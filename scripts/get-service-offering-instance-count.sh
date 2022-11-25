#!/bin/bash

if [[ -z $1 ]]; then
    echo "service offering name is required as first argument"
    exit 1;
fi

PLAN_NAMES=$(cf curl "/v3/service_plans?service_offering_names=$1" | jq -r '.resources | map(.name) | join(",")')
cf curl "/v3/service_instances?service_plan_names=${PLAN_NAMES}" | jq -r '.pagination.total_results'