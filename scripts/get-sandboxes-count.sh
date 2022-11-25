#!/bin/bash

cf curl /v3/organizations?per_page=5000 | jq -r '.resources[] | .name' | grep -c "sandbox"