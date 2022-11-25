#!/bin/bash

cf curl '/v3/apps' | jq -r '.pagination.total_results'