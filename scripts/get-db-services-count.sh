#!/bin/bash

DB_PLAN_NAMES=$(cf curl "/v3/service_plans?service_offering_names=aws-rds" | jq -r '.resources | map(.name) | join(",")')
cf curl "/v3/service_instances?service_plan_names=${DB_PLAN_NAMES}" | jq -r '.pagination.total_results'