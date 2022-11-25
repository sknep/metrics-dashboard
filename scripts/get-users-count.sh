#!/bin/bash

cf curl '/v3/users' | jq -r '.pagination.total_results'