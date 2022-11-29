#!/bin/bash

REQUEST_PATH="/v3/service_instances"

ORG_GUIDS_FILTER=""
if [ -n "$1" ]; then
    ORG_GUIDS_FILTER="organization_guids=$1"
    REQUEST_PATH="$REQUEST_PATH?$ORG_GUIDS_FILTER"
fi

TOTAL_PAGES=$(cf curl "$REQUEST_PATH" | jq -r '.pagination.total_pages')
TOTAL_RESULTS=$(cf curl "$REQUEST_PATH" | jq -r '.pagination.total_results')

ALL_PLAN_INFO_MAP="{}"
ALL_OFFERING_NAMES_MAP="{}"
MANAGED_COUNTS_BY_TAG="{}"

USER_PROVIDED_COUNT=0
MANAGED_COUNT=0

function get_service_info {
    SERVICE_PLAN_INFO=$(echo $ALL_PLAN_INFO_MAP | jq -r --arg service_plan_guid "$1" '.[$service_plan_guid] // empty')

    if [ -z "$SERVICE_PLAN_INFO" ]
    then
        # echo "looking up plan: $SERVICE_PLAN_GUID"
        SERVICE_PLAN_RESPONSE=$(cf curl "/v3/service_plans/$SERVICE_PLAN_GUID")
        
        SERVICE_PLAN_NAME=$(echo "$SERVICE_PLAN_RESPONSE" | jq -r '.name')
        SERVICE_OFFERING_GUID=$(echo "$SERVICE_PLAN_RESPONSE" | jq -r '.relationships.service_offering.data.guid')

        PLAN_INFO_MAP=$(jq -n \
                --arg service_plan_guid "$SERVICE_PLAN_GUID" \
                --arg service_plan_name "$SERVICE_PLAN_NAME" \
                --arg service_offering_guid "$SERVICE_OFFERING_GUID" \
                '.[$service_plan_guid] += { "name": $service_plan_name, "offering_guid": $service_offering_guid }' )
        ALL_PLAN_INFO_MAP=$(jq -n "$ALL_PLAN_INFO_MAP + $PLAN_INFO_MAP")
    else
        SERVICE_PLAN_NAME=$(echo "$SERVICE_PLAN_INFO" | jq -r '.name')
        SERVICE_OFFERING_GUID=$(echo "$SERVICE_PLAN_INFO" | jq -r '.offering_guid')
    fi
    
    SERVICE_OFFERING_NAME=$(echo $ALL_OFFERING_NAMES_MAP | jq -r --arg service_offering_guid "$SERVICE_OFFERING_GUID" '.[$service_offering_guid] // empty')

    if [ -z "$SERVICE_OFFERING_NAME" ]
    then
        # echo "looking up offering: $SERVICE_OFFERING_GUID"
        SERVICE_OFFERING_NAME=$(cf curl "/v3/service_offerings/$SERVICE_OFFERING_GUID" | jq -r '.name // empty')
        
        OFFERING_NAMES_MAP=$(jq -n \
                --arg service_offering_guid "$SERVICE_OFFERING_GUID" \
                --arg service_offering_name "$SERVICE_OFFERING_NAME" \
                '.[$service_offering_guid] += $service_offering_name' )
        ALL_OFFERING_NAMES_MAP=$(jq -n "$ALL_OFFERING_NAMES_MAP + $OFFERING_NAMES_MAP")
    fi
}

for ((i=1;i <=TOTAL_PAGES ;i++)); do
    if [[ $ORG_GUIDS_FILTER != "" ]]; then
        REQUEST_PATH="$REQUEST_PATH&page=$i"
    else
        REQUEST_PATH="$REQUEST_PATH?page=$i"
    fi
    while IFS= read -r resource; do
        SERVICE_TYPE=$(echo "$resource" | jq -r '.type')
        if [[ $SERVICE_TYPE == 'user-provided' ]]; then
            USER_PROVIDED_COUNT=$(( USER_PROVIDED_COUNT + 1 ))
        else
            MANAGED_COUNT=$(( MANAGED_COUNT + 1))
            SERVICE_PLAN_GUID=$(echo "$resource" | jq -r '.relationships.service_plan.data.guid')

            get_service_info "$SERVICE_PLAN_GUID"

            SERVICE_TAG_NAME="$SERVICE_OFFERING_NAME - $SERVICE_PLAN_NAME"
            
            MANAGED_COUNTS_BY_TAG=$(echo "$MANAGED_COUNTS_BY_TAG" | jq --arg service_tag_name "$SERVICE_TAG_NAME" '.[$service_tag_name] += 1')
        fi
    done < <( cf curl "$REQUEST_PATH" | jq -c '.resources[]')
done;

TOTALS=$(jq -n \
    --arg total_results "$TOTAL_RESULTS" \
    --arg user_provided_total "$USER_PROVIDED_COUNT" \
    --arg managed_total "$MANAGED_COUNT" \
    '{ "totals": { "all": $total_results, "user-provided":  $user_provided_total, "managed": $managed_total}}')

MANAGED_RESULTS="{\"managed\":$MANAGED_COUNTS_BY_TAG}"
jq -n "$TOTALS + $MANAGED_RESULTS"