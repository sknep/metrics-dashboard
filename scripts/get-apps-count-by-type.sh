#!/bin/bash

REQUEST_PATH="/v3/apps"

ORG_GUIDS_FILTER=""
if [ -n "$1" ]; then
    ORG_GUIDS_FILTER="organization_guids=$1"
    REQUEST_PATH="$REQUEST_PATH?$ORG_GUIDS_FILTER"
fi

TOTAL_PAGES=$(cf curl "$REQUEST_PATH" | jq -r '.pagination.total_pages')
TOTAL_RESULTS=$(cf curl "$REQUEST_PATH" | jq -r '.pagination.total_results')

DOCKER_COUNT=0
DOTNET_COUNT=0
APT_COUNT=0
BINARY_COUNT=0
GO_COUNT=0
NGINX_COUNT=0
NODEJS_COUNT=0
JAVA_COUNT=0
PHP_COUNT=0
PYTHON_COUNT=0
R_COUNT=0
RUBY_COUNT=0
STATICFILE_COUNT=0
OTHER_COUNT=0
NO_COUNT=0

for ((i=1;i <=TOTAL_PAGES ;i++)); do
    # echo "page: $i"
    if [[ $ORG_GUIDS_FILTER != "" ]]; then
        REQUEST_PATH="$REQUEST_PATH&page=$i"
    else
        REQUEST_PATH="$REQUEST_PATH?page=$i"
    fi
    while IFS= read -r resource; do
        LIFECYCLE_TYPE=$(echo "$resource" | jq -r '.lifecycle.type')
        if [[ $LIFECYCLE_TYPE == "docker" ]]; then
            DOCKER_COUNT=$(( DOCKER_COUNT + 1 ))
        else
            BUILDPACK_COUNT=$(echo "$resource" | jq -r '.lifecycle.data.buildpacks | length')
            if [ "$BUILDPACK_COUNT" -eq 0 ]; then
                NO_COUNT=$(( NO_COUNT + 1 ))
            else
                while IFS= read -r buildpack; do
                    case $buildpack in
                        "apt_buildpack" | *apt-buildpack*)
                            APT_COUNT=$(( APT_COUNT + 1 ))
                        ;;

                        "binary_buildpack" | *binary-buildpack*)
                            BINARY_COUNT=$(( BINARY_COUNT + 1 ))
                        ;;

                        "dotnet_core_buildpack" | *dotnet-core-buildpack*)
                            DOTNET_COUNT=$(( DOTNET_COUNT + 1 ))
                        ;;

                        "go_buildpack" | *go-buildpack*)
                            GO_COUNT=$(( GO_COUNT + 1 ))
                        ;;

                        "java_buildpack" | *java-buildpack*)
                            JAVA_COUNT=$(( JAVA_COUNT + 1 ))
                        ;;

                        "nginx_buildpack" | *nginx-buildpack*)
                            NGINX_COUNT=$(( NGINX_COUNT + 1 ))
                        ;;

                        "nodejs_buildpack" | *nodejs-buildpack*)
                            NODEJS_COUNT=$(( NODEJS_COUNT + 1 ))
                        ;;

                        "php_buildpack" | *php-buildpack*)
                            PHP_COUNT=$(( PHP_COUNT + 1 ))
                        ;;

                        "python_buildpack" | *python-buildpack*)
                            PYTHON_COUNT=$(( PYTHON_COUNT + 1 ))
                        ;;

                        "r_buildpack" | *r-buildpack*)
                            R_COUNT=$(( R_COUNT + 1 ))
                        ;;

                        "ruby_buildpack" | *ruby-buildpack*)
                            RUBY_COUNT=$(( RUBY_COUNT + 1 ))
                        ;;

                        "staticfile_buildpack" | *staticfile-buildpack*)
                            STATICFILE_COUNT=$(( STATICFILE_COUNT + 1 ))
                        ;;
                            
                        *)
                            echo "other buildpack: $buildpack"
                            OTHER_COUNT=$(( OTHER_COUNT + 1 ))
                        ;;
                    esac
                done < <( echo "$resource" | jq -cr '.lifecycle.data.buildpacks[]')
            fi
        fi
    done < <( cf curl "$REQUEST_PATH" | jq -c '.resources[]')
done;

echo "Total applications: $TOTAL_RESULTS"
echo "Total Docker apps: $DOCKER_COUNT"
echo "Total APT apps: $APT_COUNT"
echo "Total Binary apps: $BINARY_COUNT"
echo "Total .NET apps: $DOTNET_COUNT"
echo "Total Go apps: $GO_COUNT"
echo "Total Java apps: $JAVA_COUNT"
echo "Total NodeJS apps: $NODEJS_COUNT"
echo "Total Nginx apps: $NGINX_COUNT"
echo "Total PHP apps: $PHP_COUNT"
echo "Total R apps: $R_COUNT"
echo "Total Ruby apps: $RUBY_COUNT"
echo "Total Python apps: $PYTHON_COUNT"
echo "Total static apps: $STATICFILE_COUNT"
echo "Total apps using other buildpacks: $OTHER_COUNT"
echo "Total apps using no buildpacks: $NO_COUNT"
