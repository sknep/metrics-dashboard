#!/bin/bash

if [[ -z $1 ]]; then
    echo "must specify \"allowed\" or \"blocked\" as first argument"
    exit 1;
fi

case $1 in
    "allowed")
        METRIC_NAME="AllowedRequests"
        ;;
    "blocked")
        METRIC_NAME="BlockedRequests"
        ;;
    *)
        echo "unexpected value: $1"
        exit 1
        ;;
esac

aws cloudwatch get-metric-statistics \
    --metric-name "$METRIC_NAME" \
    --namespace AWS/WAFV2 \
    --statistics Sum \
    --period=300 \
    --start-time 2022-11-25T03:30:00 \
    --end-time 2022-11-25T04:30:00 \
    --dimensions Name=Region,Value=us-gov-west-1 \
    Name=WebACL,Value=production-cf-uaa-waf-core \
    Name=Rule,Value=ALL