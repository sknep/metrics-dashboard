#!/bin/bash

cf curl '/v3/apps?per_page=5000' | jq -r '.pagination.total_results'